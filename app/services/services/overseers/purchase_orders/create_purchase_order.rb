class Services::Overseers::PurchaseOrders::CreatePurchaseOrder < Services::Shared::BaseService
  def initialize(po_request, params)
    @po_request = po_request
    @params = params
  end

  def call
    warehouse = Warehouse.where(id: po_request.bill_to.id)
    series = Series.where(document_type: 'Purchase Order', series_name: warehouse.last.series_code + ' ' + Date.today.year.to_s).last
    @purchase_order = PurchaseOrder.where(po_number: series.last_number).first_or_create! do |purchase_order|
      purchase_order_params = assign_purchase_order_attributes(series.last_number)
      purchase_order.assign_attributes(purchase_order_params)
      purchase_order.assign_attributes(logistics_owner: purchase_order.inquiry.company.logistics_owner)
      purchase_order.assign_attributes(payment_option: po_request.payment_option)
      purchase_order.assign_attributes(sap_sync: 'Not Sync')
    end
    po_request.rows.each_with_index do |row, index|
      purchase_order.rows.where(product_id: row.product_id).first_or_create! do |po_row|
        po_row.assign_attributes(
            metadata: set_product(row, index)
        )
        po_row.assign_attributes(
            product: row.product_id
        )
      end
    end
    if @purchase_order.save_and_sync(po_request)
      series.increment_last_number
    end
    @purchase_order
  end

  def assign_purchase_order_attributes(series_number)
    {
        inquiry_id: po_request.inquiry.id,
        po_number: series_number, # set_purchase_order_number(po_request).last_number + 1,
        created_by_id: params[:overseer].id,
        updated_by_id: params[:overseer].id,
        status: PurchaseOrder.statuses.key(35),
        payment_option_id: po_request.payment_option.present? ? po_request.payment_option.id : nil,
        logistics_owner_id: params[:overseer].id,
        company_id: po_request.supplier_id,
        is_partial: false,
        metadata: get_metadata(series_number)
    }
  end

  def get_metadata(series_number)
    {
        PoNum: series_number,
        PoDate: Time.now.strftime('%Y-%m-%d'),
        PoType: 'Manual',
        PoStatus: '63',
        ItemLine: item_line_json,
        PoSupNum: po_request.supplier.remote_uid,
        PoSupBillFrom: po_request.supplier.billing_address.remote_uid,
        PoSupShipFrom: po_request.supplier.shipping_address.remote_uid,
        #PoShippingCost: '0',
        PoPaymentTerms: po_request.payment_option.remote_uid,
        PoEnquiryId: po_request.inquiry.inquiry_number,
        PoTargetWarehouse: po_request.bill_to.remote_uid,
        po_sales_manager: po_request.inquiry.sales_manager.to_s,
        PoBillingAddress: po_request.bill_from.remote_uid,
        po_overall_margin: po_request.po_margin_percentage,
        PoCurrencyChangeRate: po_request.sales_order.inquiry_currency.conversion_rate,
        PoCurrency: po_request.sales_order.currency.name,
        PoCommittedDate: Time.now.strftime('%Y-%m-%d'),
        PoShipWarehouse: po_request.ship_to.remote_uid,
        PoComments: "Purchase Order Against Sales Order #{po_request.sales_order.order_number}",
        PoOrderId: po_request.sales_order.order_number,
        PoFreight: '',
        PoRemarks: '',
        PoTaxRate: '',
        PoUpdatedAt: '',
        PoSupplyDate: '',
        PoInvoiceDate: '',
        PoPaymentDate: '',
        PoPaymentType: '',
        PoDeliveryTerms: '',
        PoModeOfTrasport: '',
        PoPackingForwarding: '',
        DocumentLines: item_line_json,
        #Project: po_request.inquiry.inquiry_number,
        #CardCode: po_request.supplier.remote_uid,
        #CardName: po_request.supplier.to_s,
        #DocDate: Time.now.strftime('%Y-%m-%d'),
        #Series: '134',
        #ProjectCode: 16562,
        #DocCurrency: po_request.sales_order.currency.name,
        #TaxDate: '2019-05-14',
        #DocDueDate: po_request.inquiry.customer_committed_date
    }
  end

  def item_line_json
    rows_array = []
    po_request.rows.each_with_index do |row, index|
      rows_array << set_product(row, index + 1)
    end
    rows_array
  end


  def set_product(row, index)
    {
        PopHsn: row.product.sku,
        PopQty: row.quantity.to_f,
        Linenum: index,
        UnitMsr: row.measurement_unit.name,
        WhsCode: row.po_request.bill_to.remote_uid,
        PopPriceHt: row.unit_price.to_f,
        PopTaxRate: row.tax_rate.to_s.gsub('.0%', '').gsub('GST ', 'CSG@'),
        PopDiscount: row.discount_percentage,
        PriceBefDi: 0.0,
        PopOrderNum: po_request.sales_order.order_number,
        PopProductId: row.id,
        PopPriceHtBase: row.unit_price.to_f,
        PopProductName: row.to_s,
        PopSuppliedQty: row.quantity,
        PopDeliveryDate: ""
    }
  end


  attr_accessor :po_request, :params, :purchase_order
end
