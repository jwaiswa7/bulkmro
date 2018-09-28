class Resources::Draft < Resources::ApplicationResource
  def self.identifier
    :DocNum
  end
  def self.to_remote(record)
    items = []

    record.rows.each_with_index do |row, index|
      item = OpenStruct.new
      item.TaxCode = "IG@28" #hardcode Code? Comes from Tax Label IG  = IGST ------------
      item.BaseType = 17 #hardcode
      item.BaseLine = 0, #row.sales_quote_row.sr_no #sale_order_row.sales_quote.line_num -----
      item.BaseEntry = 36 #record.sales_quote.quotation_uid # $quote['doc_entry']; -----
      item.Quantity = row.quantity # Quantity
      item.UnitPrice = row.sales_quote_row.unit_selling_price # Row Unit Price
      items.push(item.marshal_dump)

      # $grossSelling +=  $quoteItem['price_ht'];
      # $grossCost += $quoteItem['cost'];
      # $marginAmount += ($grossSelling  - $grossCost);

    end


    {
        "DocDueDate": record.inquiry.expected_closing_date.to_s, #estimated_shipping_date
        "U_CustComDt": record.inquiry.expected_closing_date.to_s, #not
        "SalesPersonCode": record.inquiry.inside_sales_owner.salesperson_uid,
        "OwnerCode": record.inquiry.outside_sales_owner.employee_uid,
        "U_SalesMgr": "Lavanya Jamma",#record.inquiry.sales_manager.full_name,
        "AttachmentEntry": 1, #6383, #$quote['attachment_entry'] ------------
        "BPL_IDAssignedToInvoice": 8, #record.warehouser.remote_branch_code ----------
        "ContactPersonCode": record.inquiry.contact.remote_uid, #22537, #
        "PaymentGroupCode": record.inquiry.payment_option.remote_uid,
        "U_CnfrmAddB": "P", #hardcode
        "U_Cnfrm_GSTIN": "P", #hardcode
        "U_Cnfrm_PayTerm": "P", #hardcode
        "U_CnfrmAddS": "P", #hardcode
        "U_CnfirmQty": "P", #hardcode
        "U_CnfrmRate": "P", #hardcode
        "U_CnfrmTax": "P", #hardcode
        "U_SO_Status": 32, #hardcode
        "U_CnfrmGross": "P", #hardcode
        "DocDate": record.created_date, #created_at
        "CardCode": "SC-01907", #record.inquiry.contact.remote_uid, #customer_id ------
        "NumAtCard": record.inquiry.customer_po_number,
        "CntctCode": record.inquiry.contact.full_name,
        "DocRate": record.conversion_rate.to_s,
        "DiscPrcnt": 0, #hardcode
        "ProjectCode": record.inquiry.project_uid, #increment_id inq
        "DocObjectCode": 22,  #hardcode
        "U_MgntDocID": record.id,
        "U_Rate_Rmks": "", #hardcode
        "U_Qty_Rmks": "", #hardcode
        "U_Tax_Rmks": "", #hardcode
        "U_Total_Rmks": "", #hardcode
        "U_Ship_Rmks": "", #hardcode
        "U_Bill_Rmks": "", #hardcode
        "U_PostBy": "Magento", #hardcode
        "U_PostMagento": "Y", #hardcode
        "ShipToCode": 4164, #record.inquiry.shipping_address.legacy_id, ------
        "PayToCode": 4164, #record.inquiry.billing_address.legacy_id, -----
        "Ovr_Margin": record.calculated_total_margin_percentage,
        "U_Over_Marg_Amnt": record.calculated_total_margin,
        "DocumentLines": items
    }

  end

end