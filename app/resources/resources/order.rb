class Resources::Order < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.to_remote(record)
    items = []

    record.rows.each_with_index do |row, index|
      item = OpenStruct.new
      item.TaxCode = row.sales_quote_row.taxation.to_remote_s # hardcode Code? Comes from Tax Label IG  = IGST ------------
      item.BaseType = SAP.draft_base_type # hardcode For SAP Type Use 17 for Live SAP
      item.BaseLine = row.remote_uid # row.try(:sr_no) #row.sales_quote_row.sr_no #sale_order_row.sales_quote.line_num -----
      item.BaseEntry = record.sales_quote.remote_uid # record.sales_quote.quotation_uid # $quote['doc_entry']; -----
      item.Quantity = row.quantity # Quantity
      item.UnitPrice = row.sales_quote_row.unit_selling_price # Row Unit Price
      items.push(item.marshal_dump)
    end

    company_contact = record.inquiry.company.company_contacts.joins(:contact).where('contacts.email = ?', record.inquiry.contact.email).first
    company_shipping_contact = record.inquiry.company.company_contacts.joins(:contact).where('contacts.email = ?', record.inquiry.shipping_contact.email).first

    {
        HandWritten: "tYES",
        DocNum: record.order_number,
        AttachmentEntry: record.inquiry.attachment_uid, # 6383, #$quote['attachment_entry'] ------------
        BPL_IDAssignedToInvoice: record.inquiry.bill_from.remote_branch_code, # record.inquiry.bill_from.remote_uid, #record.warehouser.remote_branch_code ----------
        CardCode: record.inquiry.company.remote_uid, # record.inquiry.contact.remote_uid, #customer_id ------
        CntctCode: record.inquiry.contact.full_name,
        ContactPersonCode: company_contact.present? ? company_contact.remote_uid : nil,
        DiscountPercent: 0, # hardcode
        DocDueDate: record.inquiry.customer_committed_date.present? ? record.inquiry.customer_committed_date.strftime('%Y-%m-%d') : nil, # estimated_shipping_date
        DocumentsOwner: record.inquiry.outside_sales_owner.employee_uid,
        DocCurrency: 'INR', # record.inquiry.inquiry_currency.currency.name
        DocDate: record.created_date, # created_at
        DocRate: record.conversion_rate.to_s,
        DocObjectCode: SAP.draft_doc_object_code, # hardcode
        DocumentLines: items,
        NumAtCard: record.inquiry.customer_po_number,
        PayToCode: record.inquiry.billing_address.remote_uid, # record.inquiry.billing_address.legacy_id, -----
        PaymentGroupCode: record.inquiry.payment_option.remote_uid,
        ProjectCode: record.inquiry.project_uid, # increment_id inq
        ShipToCode: record.inquiry.remote_shipping_address_uid, # record.inquiry.shipping_address.legacy_id, ------
        SalesPersonCode: record.inquiry.inside_sales_owner.salesperson_uid,
        U_CustComDt: record.inquiry.expected_closing_date.present? ? record.inquiry.expected_closing_date.strftime('%Y-%m-%d') : nil, # not
        U_SalesMgr: record.inquiry.sales_manager.try(:full_name), # record.inquiry.sales_manager.full_name,
        U_ConsigneeAddr: record.inquiry.shipping_address.remote_uid,
        U_Freight_Cost: record.inquiry.freight_cost,
        U_CnfrmAddB: 'A', # hardcode
        U_Cnfrm_GSTIN: 'A', # hardcode
        U_Cnfrm_PayTerm: 'A', # hardcode
        U_CnfrmAddS: 'A', # hardcode
        U_CnfirmQty: 'A', # hardcode
        U_CnfrmRate: 'A', # hardcode
        U_CnfrmTax: 'A', # hardcode
        U_SO_Status: record.set_so_status_value, # hardcode
        U_CnfrmGross: 'A', # hardcode
        U_MgntDocID: record.id,
        U_Rate_Rmks: '', # hardcode
        U_Qty_Rmks: '', # hardcode
        U_Tax_Rmks: '', # hardcode
        U_Total_Rmks: '', # hardcode
        U_Ship_Rmks: '', # hardcode
        U_Bill_Rmks: '', # hardcode
        U_PostBy: 'Magento', # hardcode
        U_PostMagento: 'Y', # hardcode
        BPChannelCode: record.inquiry.remote_shipping_company_uid,
        U_Ovr_Margin: record.calculated_total_margin_percentage,
        U_Over_Marg_Amnt: record.calculated_total_margin,
        BPChannelContact: company_shipping_contact.present? ? company_shipping_contact.remote_uid : nil,
    }
  end
end
