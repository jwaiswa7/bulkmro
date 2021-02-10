class Services::Overseers::PurchaseOrders::CreatePurchaseOrder < Services::Shared::BaseService
  def initialize(po_request, params, notification)
    @po_request = po_request
    @params = params
    @is_stock = params['is_stock'].present? ? params['is_stock'] : 'no'
    @notification = notification
  end

  def create
    ActiveRecord::Base.transaction do
      warehouse = Warehouse.where(id: po_request.bill_to.id)
      date = Date.today
      year = date.year
      year = year - 1 if date.month < 4
      series = Series.where(document_type: 'Purchase Order', series_name: warehouse.last.series_code + ' ' + year.to_s).last
      @purchase_order = PurchaseOrder.where(po_number: series.last_number).first_or_create! do |purchase_order|
        purchase_order_params = assign_purchase_order_attributes(series.last_number)
        # purchase_order.update_attributes(purchase_order_params)
        purchase_order.update_attributes(
          purchase_order_params.merge(
            logistics_owner: po_request.inquiry.company.logistics_owner,
            payment_option: po_request.payment_option,
            sap_sync: 'Not Sync',
            created_by_id: params[:overseer].id,
            transport_mode: po_request.transport_mode,
            delivery_type: po_request.delivery_type
          )
        )
      end
      po_request.rows.each_with_index do |row, index|
        @purchase_order.rows.where(product_id: row.product_id).first_or_create! do |po_row|
          po_row.update_attributes(
            metadata: set_product_data(row, index),
            product: row.product,
            created_by_id: params[:overseer].id,
            updated_by_id: params[:overseer].id,
            po_request_row_id: row.id
          )
          if po_row.po_request_row.inquiry_product_supplier.present? && po_row.po_request_row.inquiry_product_supplier.supplier_rfq.present?
            po_row.po_request_row.inquiry_product_supplier.supplier_rfq.update_column(:status, 'PO Issued')
            SupplierRfqsIndex::SupplierRfq.import([po_row.po_request_row.inquiry_product_supplier.supplier_rfq.id])
          end
        end
      end
      po_request.update_attributes(
        status: 'Supplier PO: Created Not Sent',
        purchase_order: @purchase_order
      )
      if @purchase_order.save_and_sync(po_request)
        comments = po_request.comments.build(created_by_id: params[:overseer].id, updated_by_id: params[:overseer].id)
        comments.message = "Purchase Order ##{@purchase_order.po_number} Approved by #{params[:overseer].to_s}"
        comments.save!
        inquiry = po_request.inquiry
        @notification.po_created(
          'create',
            @purchase_order,
            Rails.application.routes.url_helpers.overseers_inquiry_purchase_order_path(inquiry, @purchase_order),
            inquiry
        )
        series.increment_last_number
        # tcs_for_po
        # company = @purchase_order&.company
        # if company
        #   company_po_amount = company.company_transactions_amounts.where(financial_year: Company.current_financial_year).last
        #   company_po_amount.increment_total_amount(@purchase_order.calculated_total_with_tax_with_or_without_tcs) if company_po_amount.present?
        # end
      end
    end
    @purchase_order
  end

  def update
    @purchase_order = po_request.purchase_order
    if @purchase_order.present?
      purchase_order.rows.where(po_request_row_id: nil).delete_all
      purchase_order_params = assign_purchase_order_attributes(@purchase_order.po_number)
      purchase_order.update_attributes(purchase_order_params)
      po_request.rows.each_with_index do |row, index|
        purchase_order_row = purchase_order.rows.where(product_id: row.product.id)
        if purchase_order_row.present?
          purchase_order_row.last.update_attributes(
            metadata: set_product_data(row, index),
            updated_by_id: params[:overseer].id
          )
        else
          po_row = PurchaseOrderRow.new
          po_row.purchase_order_id = @purchase_order.id
          po_row.product = row.product
          po_row.po_request_row_id = row.id
          po_row.metadata = set_product_data(row, index)
          po_row.save!
        end
      end
      @purchase_order.save_and_sync(po_request)
      if @is_stock == 'no'
        po_request.update_attributes(status: 'Supplier PO: Amended')
      else
        po_request.update_attributes(stock_status: 'Supplier Stock PO: Amended')
      end

      @purchase_order.update_attributes(material_status: nil)
      comments = po_request.comments.build(created_by_id: params[:overseer].id, updated_by_id: params[:overseer].id)
      comments.message = "Status Changed: #{po_request.status}"
      comments.save!
    end
  end

  def assign_purchase_order_attributes(series_number)
    {
        inquiry_id: po_request.inquiry.id,
        po_number: series_number, # set_purchase_order_number(po_request).last_number + 1,
        updated_by_id: params[:overseer].id,
        status: PurchaseOrder.statuses.key(35),
        payment_option_id: po_request.payment_option.present? ? po_request.payment_option.id : nil,
        logistics_owner_id: po_request.inquiry.company.logistics_owner_id.present? ? po_request.inquiry.company.logistics_owner_id : nil,
        company_id: po_request.supplier_id,
        is_partial: false,
        metadata: get_metadata(series_number),
        transport_mode: po_request.transport_mode,
        delivery_type: po_request.delivery_type
    }
  end

  def get_metadata(series_number)
    product_ids = Product.where(sku: Settings.product_specific.freight).last.id
    {
        PoNum: series_number,
        PoDate: po_request.purchase_order.present? ? po_request.purchase_order.created_at.strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        PoType: 'Manual',
        PoStatus: '63',
        ItemLine: item_line_json,
        PoSupNum: po_request.supplier.remote_uid,
        PoSupBillFrom: po_request.bill_from.remote_uid,
        PoSupShipFrom: po_request.ship_from.remote_uid,
        # PoShippingCost: '0',
        PoPaymentTerms: po_request.payment_option.remote_uid,
        PoEnquiryId: po_request.inquiry.inquiry_number,
        PoTargetWarehouse: po_request.bill_to.remote_uid,
        po_sales_manager: po_request.inquiry.sales_manager.to_s,
        PoBillingAddress: po_request.bill_from.remote_uid,
        po_overall_margin: po_request.po_margin_percentage,
        PoCurrencyChangeRate: po_request.inquiry.inquiry_currency.conversion_rate,
        PoCurrency: po_request.inquiry.currency.name,
        PoCommittedDate: po_request.rows.present? ? po_request.rows.maximum(:lead_time).strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        PoShipWarehouse: po_request.ship_to.remote_uid,
        PoComments: po_request.sales_order.present? ? "Purchase Order Against Sales Order #{po_request.sales_order.order_number}" : "Purchase Order Against For stock Inquiry Number #{po_request.inquiry.inquiry_number}",
        PoOrderId: (po_request.sales_order.present? ? po_request.sales_order.order_number : ''),
        PoFreight: po_request.rows.pluck(:product_id).include?(product_ids) ? 'Excluded' : 'Included',
        U_Frghtterm: po_request.rows.pluck(:product_id).include?(product_ids) ? 'Excluded' : 'Included',
        PoRemarks: '',
        PoTaxRate: '',
        PoUpdatedAt: '',
        PoSupplyDate: po_request.rows.present? ? po_request.rows.maximum(:lead_time).strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d'),
        PoInvoiceDate: '',
        PoPaymentDate: '',
        PoPaymentType: '',
        PoDeliveryTerms: po_request.delivery_type.present? ? po_request.delivery_type : 'Door delivery',
        PoModeOfTrasport: po_request.transport_mode.present? ? po_request.transport_mode : 'Road',
        PoPackingForwarding: '',
        DocumentLines: item_line_json,
        DocDueDate: po_request.rows.present? ? po_request.rows.maximum(:lead_time).strftime('%Y-%m-%d') : Time.now.strftime('%Y-%m-%d')
      # Project: po_request.inquiry.inquiry_number,
      # CardCode: po_request.supplier.remote_uid,
      # CardName: po_request.supplier.to_s,
      # DocDate: Time.now.strftime('%Y-%m-%d'),
      # Series: '134',
      # ProjectCode: 16562,
      # DocCurrency: po_request.sales_order.currency.name,
      # TaxDate: '2019-05-14',
      # DocDueDate: po_request.inquiry.customer_committed_date
    }
  end

  def item_line_json
    rows_array = []
    po_request.rows.each_with_index do |row, index|
      rows_array << set_product_data(row, index + 1)
    end
    rows_array
  end


  def set_product_data(row, index)
    {
        PopHsn: row.tax_code.chapter.present? ? row.tax_code.chapter : row.tax_code.code[0..3],
        PopQty: row.quantity.to_f,
        Linenum: index,
        UnitMsr: row.measurement_unit.name,
        WhsCode: row.po_request.ship_to.remote_uid,
        PopPriceHt: row.unit_price.to_f,
        PopTaxRate: row.taxation.to_remote_s,
        PopDiscount: row.discount_percentage,
        PriceBefDi: 0.0,
        PopOrderNum: po_request.sales_order.present? ? po_request.sales_order.order_number : '',
        PopProductId: row.id,
        PopPriceHtBase: row.unit_price.to_f,
        PopProductName: row.to_s,
        PopSuppliedQty: row.quantity,
        PopDeliveryDate: ''
    }
  end


  attr_accessor :po_request, :params, :purchase_order
end
