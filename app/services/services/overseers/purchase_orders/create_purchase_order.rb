class Services::Overseers::PurchaseOrders::CreatePurchaseOrder < Services::Shared::BaseService
  def initialize(po_request, params)
    @po_request = po_request
    @params = params
  end

  def call
    @purchase_order = PurchaseOrder.new
    warehouse = Warehouse.where(id: po_request.bill_to.id)
    series = Series.where(document_type: 'Purchase Order', series_name: warehouse.last.series_code + ' ' + Date.today.year.to_s).last

    purchase_order.assign_attributes(set_attributes(po_request, series.last_number))
    if purchase_order.save
      series.increment_last_number
      doc_num = ::Resources::PurchaseOrder.create(purchase_order, po_request)
      last_remote_request_status = RemoteRequest.where(subject_type: 'PurchaseOrder', subject_id: purchase_order.id).last.status
      if last_remote_request_status == "success"
        @metadata = ::Resources::PurchaseOrder.custom_find(purchase_order.po_number)
      else
        purchase_order.update_attributes(sap_sync: 20)
      end
      if doc_num.present?
        po_request_params = {status: PoRequest.statuses.key(20)}
        po_request.update_attributes(po_request_params)
          purchase_order.remote_uid = doc_num
          purchase_order.metadata = ::Resources::PurchaseOrder.build_metadata(@metadata) if @metadata.present?
        purchase_order.save!
      end
      po_request.rows.each_with_index do |row, index|
        row_params = {metadata: purchase_order.metadata['ItemLine'][index], created_by_id: params[:overseer].id, updated_by_id: params[:overseer].id, product_id: row.product_id, po_request_row_id: row.id}
        new_row = purchase_order.rows.build(row_params)
        new_row.save!
      end
      binding.pry
      PurchaseOrdersIndex::PurchaseOrder.import purchase_order
      po_request_params = {purchase_order_id: purchase_order.id, status: PoRequest.statuses.key(20)}
      po_request.update_attributes(po_request_params)
      purchase_order
    end
  end

  def set_attributes(po_request, series_number)
    {
        inquiry_id: po_request.inquiry.id,
        po_number: series_number, # set_purchase_order_number(po_request).last_number + 1,
        created_by_id: params[:overseer].id,
        updated_by_id: params[:overseer].id,
        status: PurchaseOrder.statuses.key(35),
        payment_option_id: po_request.payment_option.present? ? po_request.payment_option.id : nil,
        logistics_owner_id: params[:overseer].id,
        company_id: po_request.supplier_id,
        is_partial: false
    }
  end

=begin
  def set_metadata(po_request, series_number)
    {
        PoNum: series_number,
        PoDate: Time.now.strftime('%Y-%m-%d'),
        PoType: 'Manual',
        PoStatus: '63',
        ItemLine: item_line_json,
        PoSupNum: '',
        PoSupBillFrom: po_request.supplier.billing_address.remote_uid,
        PoSupShipFrom: po_request.supplier.shipping_address.remote_uid,
        PoShippingCost: '0',
        PoPaymentTerms: po_request.payment_option.name,
        PoEnquiryId: po_request.inquiry.inquiry_number,
        PoTargetWarehouse: po_request.ship_to.remote_uid,
        DocumentLines: [],
        BPL_IDAssignedToInvoice: po_request.bill_to.remote_branch_code, # warehouse Id
        Project: po_request.inquiry.inquiry_number,
        CardCode: po_request.supplier.remote_uid,
        CardName: po_request.supplier.to_s,
        DocDate: Time.now.strftime('%Y-%m-%d'),
        Series: '134',
        ProjectCode: 16562,
        DocCurrency: po_request.sales_order.currency.name,
        TaxDate: '2019-05-14',
        DocDueDate: po_request.inquiry.customer_committed_date
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
        UnitMsr: 'Manual',
        WhsCode: row.po_request.bill_to.remote_uid,
        PopPriceHt: '0.0',
        PopTaxRate: '0.0',
        PopNum: '',
        OcrCode: '',
        SlpCode: '79',

        WhsCode: '2',
        OcrCode2: '',
        OcrCode3: '',
        OcrCode4: '',
        OcrCode5: '',
        PopEcoTax: '0.0000',
        PopWeight: '0',
        PopPriceHt: '1580',
        PopTaxRate: row.tax_rate.to_s.gsub('.0%', '').gsub('GST ', 'CSG@'),
        PriceBefDi: '1580',
        PopDiscount: '0',
        PopOrderNum: '402000311',
        PopProductId: row.product.sku,
        PopEcoTaxBase: '0.0000',
        PopPackagingId: '',
        PopPriceHtBase: '1580',
        PopProductName: row.product.name,
        PopSuppliedQty: '650',
        PopSupplierRef: '',
        PopDeliveryDate: '2019-04-27',
        PopExtendedCosts: '0.000',
        PopPackagingName: '',
        PopPackagingValue: '',
        PopExtendedCostsBase: '0.000'
    }
  end
=end

  attr_accessor :po_request, :params, :purchase_order
end
