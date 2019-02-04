class Services::Callbacks::PurchaseOrders::Create < Services::Callbacks::Shared::BaseCallback

  def call
    inquiry = Inquiry.find_by_inquiry_number(params['PoEnquiryId'])
    payment_option = PaymentOption.find_by_name(params['PoPaymentTerms'].to_s.strip)
    begin
      if inquiry.present? && inquiry.final_sales_quote.present?
        if params['PoNum'].present? && !PurchaseOrder.find_by_po_number(params['PoNum']).present?
          inquiry.purchase_orders.where(po_number: params['PoNum']).first_or_create! do |purchase_order|
            purchase_order.assign_attributes(:metadata => params)
            purchase_order.assign_attributes(:material_status => "Material Readiness Follow-Up")
            purchase_order.assign_attributes(:logistics_owner => Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(purchase_order).call)
            if payment_option.present?
              purchase_order.assign_attributes(:payment_option => payment_option)
            end
            params['ItemLine'].each do |remote_row|
              purchase_order.rows.build do |row|
                row.assign_attributes(
                    metadata: remote_row
                )
              end
            end

            if purchase_order.po_request.present? && purchase_order.po_request.payment_request.blank?
              create_payment_request = Services::Overseers::PaymentRequests::Create.new(purchase_order.po_request)
              create_payment_request.call
            end
          end
          return_response("Purchase Order created successfully.")
        else
          purchase_order = PurchaseOrder.find_by_po_number(params['PoNum'])
          if purchase_order.present?
            purchase_order.assign_attributes(:metadata => params)
            if payment_option.present?
              purchase_order.assign_attributes(:payment_option => payment_option)
            end
            params['ItemLine'].each do |remote_row|
              product = Product.find_by_legacy_id(remote_row['PopProductId'].to_i) || Product.find(remote_row['PopProductId'])
              row = purchase_order.rows.select {|por| por.sku == product.sku}.first

              if row.present?
                row.assign_attributes(
                    metadata: remote_row
                )
              else
                new_row = purchase_order.rows.build do |row|
                  row.assign_attributes(
                      metadata: remote_row
                  )
                end
                new_row.save
              end
            end
            purchase_order.save!
          end

          return_response("Purchase Order updated successfully.")
        end
      else
        return_response("Inquiry #{params['PoEnquiryId']} or Quotation not found.", 0)
      end
    rescue => e
      return_response(e.message, 0)
    end
  end

  attr_accessor :params
end

# {
#     "DocEntry": "500",
#     "PoNum": "40210162",
#     "PoDate": "2018-02-05",
#     "PoOrderId": "40210162",
#     "PoSupNum": "SC-8246",
#     "PoCarrier": "",
#     "PoPaymentType": "",
#     "PoCst": "0",
#     "PoCurrency": "INR",
#     "PoInvoiceDate": "2018-02-05",
#     "PoSupplyDate": "2018-02-05",
#     "PoInvoiceRef": "",
#     "PoPaid": "0",
#     "PoSent": "0",
#     "PoCurrencyChangeRate": "1",
#     "PoShippingCost": "0",
#     "PoShippingCostBase": "0",
#     "PoZollCost": "0.00",
#     "PoZollCostBase": "0.00",
#     "PoFinished": "0",
#     "PoTaxRate": "CSG@18",
#     "PoMediaboxNum": "",
#     "PoComments": "",
#     "PoPaymentDate": "2018-02-05",
#     "PoSupplierOrderRef": "OpenPO",
#     "PoStatus": "cancelled",
#     "PoDeliveryPercent": "0",
#     "PoSupplierNotificationDate": null,
#     "PoMissingPrice": "0",
#     "PoExternalExtendedCost": "0",
#     "PoDataVerified": "0",
#     "PoTargetWarehouse": "",
#     "PoIsLocked": "0",
#     "PoLastNotifyText": null,
#     "PoDefaultProductDiscount": "0.00",
#     "PoUpdatedAt": "2018-06-12",
#     "PoTrackingid": "",
#     "PoBillingAddress": "8816",
#     "PoModeOfTrasport": "",
#     "PoDeliveryTerms": "",
#     "PoFreight": "",
#     "PoPaymentTerms": "Net-30",
#     "PoPackingForwarding": "",
#     "PoEndDestination": null,
#     "PoEnquiryId": "10097",
#     "PoRemarks": "",
#     "PoSupBillFrom": "8816",
#     "PoSupShipFrom": "8816",
#     "U_LogoPerson": "0",
#     "U_LogoMgr": "0",
#     "PoFollowUpDate": "",
#     "PoSupplierInvoiceDate": "",
#     "PoSupplierInvoiceNumber": null,
#     "PoAdditionalPdf": null,
#     "PoCommittedDate": "2018-02-05",
#     "PoCustCom": null,
#     "PoCustStadd": null,
#     "PoCustCity": null,
#     "PoCustState": null,
#     "PoCustCount": null,
#     "PoCustZip": null,
#     "PoAccessDuties": "",
#     "PoAdditionalPdf1": null,
#     "PoAdditionalPdf2": null,
#     "PoShipWarehouse": "2",
#     "PoDestination": "BulkMRO",
#     "PoShipper": "",
#     "PoRcm": "Regular",
#     "PoType": "MovementofGoods",
#     "PoCustName": "20517",
#     "PoCustGst": null,
#     "DocType": null,
#     "JrnlMemo": null,
#     "SlpCode": null,
#     "Series": null,
#     "ObjType": null,
#     "ShipToCode": null,
#     "ReqDate": "",
#     "PaymentDueDate": "",
#     "po_sales_manager": "",
#     "po_vessel_name": "",
#     "po_port_of_loading": "",
#     "po_import_port": "",
#     "po_terms_of_delivery_payment": "",
#     "po_LR_date": "",
#     "po_insurance": "",
#     "po_vehicle_num": "",
#     "po_eway_bill_num": "",
#     "po_LR_num": "",
#     "po_port_of_discharge": "",
#     "po_overall_margin": "0",
#     "po_type": "",
#     "po_additional_pdf1": "",
#     "po_shipping_name": "",
#     "po_shipping_cost": "",
#     "po_shipping_tax": "",
#     "po_shipping_name_2": "",
#     "po_shipping_cost_2": "",
#     "po_shipping_tax_2": "",
#     "po_shipping_name_3": "",
#     "po_shipping_cost_3": "",
#     "po_shipping_tax_3": "",
#     "ItemLine": [{
#                      "PopNum": null,
#                      "PopOrderNum": "40210162",
#                      "PopProductId": "757048",
#                      "PopProductName": "AlcoholBreathAnalyzerCitizenModel-ABACitizen",
#                      "PopQty": "2",
#                      "PopSuppliedQty": "2",
#                      "PopPriceHt": "5000",
#                      "PopPriceHtBase": "5000",
#                      "PopSupplierRef": null,
#                      "PopEcoTax": "0.0000",
#                      "PopEcoTaxBase": "0.0000",
#                      "PopExtendedCosts": "0.000",
#                      "PopExtendedCostsBase": "0.000",
#                      "PopTaxRate": "CSG@18",
#                      "PopPackagingId": null,
#                      "PopPackagingValue": null,
#                      "PopPackagingName": null,
#                      "PopWeight": "0",
#                      "PopDiscount": "0",
#                      "PopDeliveryDate": "2018-02-05",
#                      "Linenum": "0",
#                      "WhsCode": "2",
#                      "SlpCode": "-1",
#                      "OcrCode": null,
#                      "UnitMsr": "Manual",
#                      "PriceBefDi": "5000",
#                      "OcrCode2": null,
#                      "OcrCode3": null,
#                      "OcrCode4": null,
#                      "OcrCode5": null,
#                      "PopHsn": "9027"
#                  }]
# }