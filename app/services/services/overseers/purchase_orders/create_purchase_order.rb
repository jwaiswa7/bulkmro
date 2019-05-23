class Services::Overseers::PurchaseOrders::CreatePurchaseOrder < Services::Shared::BaseService
  def initialize(po_request, params)
    @po_request = po_request
    @params = params
  end

  def call
    @purchase_order = PurchaseOrder.new
    purchase_order.assign_attributes(set_attributes(po_request))
    if purchase_order.save
      po_request_params = { purchase_order_id: purchase_order.id, status: PoRequest.statuses.key(20) }
      po_request.update_attributes(po_request_params)
      doc_num = ::Resources::PurchaseOrder.create(purchase_order)
      if doc_num.present?
        series = set_purchase_order_number(po_request)
        series.increment_last_number
      end
      po_request.rows.each do |row|
        row_params = { metadata: set_product(row), created_by_id: params[:overseer].id, updated_by_id: params[:overseer].id }
        row = purchase_order.rows.build(row_params)
        row.save!
      end
      purchase_order
    end

  end

  def set_attributes(po_request)
    {
        inquiry_id: po_request.inquiry.id,
        po_number: set_purchase_order_number(po_request).last_number + 1,
        #metadata: set_metadata(po_request),
        metadata: {},
        created_by_id: params[:overseer].id,
        updated_by_id: params[:overseer].id,
        status: PurchaseOrder.statuses.key(35),
        payment_option_id: po_request.payment_option.present? ? po_request.payment_option.id : nil,
        logistics_owner_id: params[:overseer].id,
        company_id: po_request.supplier_id,
        is_partial: false
    }
  end

  def set_metadata(po_request)
    {
       PoDate: Time.now.strftime('%Y-%m-%d'),
       PoStatus: "63",
       DocNum: set_purchase_order_number(po_request).last_number + 1,
       PoSupNum: "",
       PoSupBillFrom: po_request.supplier.billing_address.remote_uid,
       PoSupShipFrom: po_request.supplier.shipping_address.remote_uid,
       PoShippingCost: "0",
       PoTargetWarehouse: po_request.ship_to.remote_uid,
       DocumentLines: [],
       BPL_IDAssignedToInvoice: po_request.bill_to.remote_branch_code, #warehouse Id
       Project: po_request.inquiry.inquiry_number,
       CardCode: po_request.supplier.remote_uid,
       CardName: po_request.supplier.to_s,
       DocDate: Time.now.strftime('%Y-%m-%d'),
       Series: "134",
       ProjectCode: 16562,
       NumAtCard: "123478",
       DocCurrency: "INR",
       TaxDate: "2019-05-14",
       DocDueDate: "2019-05-25"
    }
  end

  def item_line_json
    rows_array = []
    po_request.rows.each do |row|
      rows_array << set_product(row)
    end
    rows_array
  end

  def set_purchase_order_number(po_request)
    warehouse = Warehouse.where(id: po_request.bill_to.id)
    series = Series.where(document_type: 'Purchase Order', series_name: warehouse.last.series_code + ' 2019').last
    series
  end

  def set_product(row)
    {
        'PopHsn': row.product.sku,
        'PopNum': '',
        'Linenum': '0',
        'PopQty': row.quantity.to_f,
        'OcrCode': '',
        'SlpCode': '79',
        'UnitMsr': 'Manual',
        'WhsCode': '2',
        'OcrCode2': '',
        'OcrCode3': '',
        'OcrCode4': '',
        'OcrCode5': '',
        'PopEcoTax': '0.0000',
        'PopWeight': '0',
        'PopPriceHt': '1580',
        'PopTaxRate': row.tax_rate.to_s.gsub('.0%', '').gsub('GST ', 'CSG@'),
        'PriceBefDi': '1580',
        'PopDiscount': '0',
        'PopOrderNum': '402000311',
        'PopProductId': row.product.sku,
        'PopEcoTaxBase': '0.0000',
        'PopPackagingId': '',
        'PopPriceHtBase': '1580',
        'PopProductName': row.product.name,
        'PopSuppliedQty': '650',
        'PopSupplierRef': '',
        'PopDeliveryDate': '2019-04-27',
        'PopExtendedCosts': '0.000',
        'PopPackagingName': '',
        'PopPackagingValue': '',
        'PopExtendedCostsBase': '0.000'
    }
  end

  attr_accessor :po_request, :params, :purchase_order
end

