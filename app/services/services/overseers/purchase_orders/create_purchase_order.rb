class Services::Overseers::PurchaseOrders::CreatePurchaseOrder < Services::Shared::BaseService
  def initialize(po_request, params)
    @po_request = po_request
    @params = params
  end

  def call
    purchase_order = PurchaseOrder.new
    purchase_order.assign_attributes(set_attributes)
    purchase_order.save!
    po_request.rows.each do |row|
      row_params = { metadata: set_product(row), created_by_id: params[:overseer].id, updated_by_id: params[:overseer].id }
      row = purchase_order.rows.build(row_params)
      row.save!
    end
    po_request_params = { purchase_order_id: purchase_order.id, status: PoRequest.statuses.key(20) }
    po_request.update_attributes(po_request_params)
  end

  def set_attributes
    {
        inquiry_id: po_request.inquiry.id,
        po_number: set_purchase_order_number,
        metadata: set_metadata,
        created_by_id: params[:overseer].id,
        updated_by_id: params[:overseer].id,
        status: PurchaseOrder.statuses.key(35),
        payment_option_id: po_request.payment_option.present? ? po_request.payment_option.id : nil,
        logistics_owner_id: params[:overseer].id,
        company_id: po_request.supplier_id,
        is_partial: false
    }
  end

  def set_metadata
    {
        'PoCst': '0',
        'PoNum': set_purchase_order_number,
        'PoRcm': 'Regular',
        'PoDate': Time.now.strftime('%Y-%m-%d'),
        'PoPaid': '0',
        'PoSent': '0',
        'PoType': 'Movement of Goods',
        'Series': '',
        'action': 'create',
        'DocType': '',
        'ObjType': '',
        'ReqDate': '',
        'SlpCode': '',
        'po_type': '',
        'DocEntry': '13564',
        'ItemLine': item_line_json,
        'JrnlMemo': '',
        'PoStatus': '63',
        'PoSupNum': po_request.supplier.remote_uid,
        'PoCarrier': '',
        'PoCustCom': '',
        'PoCustGst': '',
        'PoCustZip': '',
        'PoFreight': 'Extra',
        'PoOrderId': '402000311',
        'PoRemarks': '',
        'PoShipper': '',
        'PoTaxRate': 'CSG@18',
        'U_LogoMgr': '0',
        'po_LR_num': '',
        'PoComments': '',
        'PoCurrency': po_request.sales_order.currency.name,
        'PoCustCity': '',
        'PoCustName': '28788',
        'PoFinished': '0',
        'PoIsLocked': '0',
        'PoZollCost': '0.00',
        'ShipToCode': '',
        'controller': 'callbacks/purchase_orders',
        'po_LR_date': '',
        'PoCustCount': '',
        'PoCustStadd': '',
        'PoCustState': '',
        'PoEnquiryId': '33462',
        'PoUpdatedAt': '2019-04-27',
        'PoInvoiceRef': ' ',
        'PoSupplyDate': '2019-04-27',
        'PoTrackingid': '',
        'U_LogoPerson': '0',
        'po_insurance': '',
        'PoDestination': 'Bulk MRO',
        'PoInvoiceDate': '2019-04-27',
        'PoMediaboxNum': '',
        'PoPaymentDate': '2019-04-27',
        'PoPaymentType': '',
        'PoSupBillFrom': 'A218432',
        'PoSupShipFrom': 'A218432',
        'PaymentDueDate': '',
        'PoAccessDuties': '',
        'PoDataVerified': '0',
        'PoFollowUpDate': '',
        'PoMissingPrice': '0',
        'PoPaymentTerms': '20% Advance and 80% before dispatch',
        'PoShippingCost': '0',
        'PoZollCostBase': '0.00',
        'po_import_port': '',
        'po_vehicle_num': '',
        'po_vessel_name': '',
        'purchase_order': {},
        'PoAdditionalPdf': '',
        'PoCommittedDate': '2019-04-27',
        'PoDeliveryTerms': 'EXW',
        'PoShipWarehouse': '2',
        'po_shipping_tax': '',
        'PoAdditionalPdf1': '',
        'PoAdditionalPdf2': '',
        'PoBillingAddress': 'A218432',
        'PoEndDestination': '',
        'PoLastNotifyText': '',
        'PoModeOfTrasport': 'Road',
        'po_eway_bill_num': '',
        'po_sales_manager': '',
        'po_shipping_cost': '',
        'po_shipping_name': '',
        'PoDeliveryPercent': '0',
        'PoTargetWarehouse': '2',
        'po_overall_margin': '0',
        'po_shipping_tax_2': '',
        'po_shipping_tax_3': '',
        'PoShippingCostBase': '0.00',
        'PoSupplierOrderRef': '',
        'po_additional_pdf1': '',
        'po_port_of_loading': '',
        'po_shipping_cost_2': '',
        'po_shipping_cost_3': '',
        'po_shipping_name_2': '',
        'po_shipping_name_3': '',
        'PoPackingForwarding': '',
        'PoCurrencyChangeRate': '1',
        'po_port_of_discharge': '',
        'PoSupplierInvoiceDate': '',
        'PoExternalExtendedCost': '0',
        'PoSupplierInvoiceNumber': '',
        'PoDefaultProductDiscount': '0.00',
        'PoSupplierNotificationDate': '',
        'po_terms_of_delivery_payment': ''
    }
  end

  def item_line_json
    rows_array = []
    po_request.rows.each do |row|
      rows_array << set_product(row)
    end
    rows_array
  end

  def set_purchase_order_number
    rand(9**7).to_s
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
        'PopProductId': '2ruLYk',
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

  attr_accessor :po_request, :params
end
