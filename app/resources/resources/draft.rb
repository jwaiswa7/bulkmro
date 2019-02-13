class Resources::Draft < Resources::ApplicationResource
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
      item.BaseEntry = record.sales_quote.inquiry.quotation_uid # record.sales_quote.quotation_uid # $quote['doc_entry']; -----
      item.Quantity = row.quantity # Quantity
      item.UnitPrice = row.sales_quote_row.unit_selling_price # Row Unit Price
      items.push(item.marshal_dump)
    end

    company_contact = record.inquiry.company.company_contacts.joins(:contact).where("contacts.email = ?", record.inquiry.contact.email).first
    company_shipping_contact = record.inquiry.company.company_contacts.joins(:contact).where("contacts.email = ?", record.inquiry.shipping_contact.email).first

    {
        AttachmentEntry: record.inquiry.attachment_uid, # 6383, #$quote['attachment_entry'] ------------
        BPL_IDAssignedToInvoice: record.inquiry.bill_from.remote_branch_code, # record.inquiry.bill_from.remote_uid, #record.warehouser.remote_branch_code ----------
        CardCode: record.inquiry.company.remote_uid, # record.inquiry.contact.remote_uid, #customer_id ------
        CntctCode: record.inquiry.contact.full_name,
        ContactPersonCode: company_contact.present? ? company_contact.remote_uid : nil,
        DiscountPercent: 0, # hardcode
        DocDueDate: record.inquiry.customer_committed_date.present? ? record.inquiry.customer_committed_date.strftime("%Y-%m-%d") : nil, # estimated_shipping_date
        DocumentsOwner: record.inquiry.outside_sales_owner.employee_uid,
        DocCurrency: "INR", # record.inquiry.inquiry_currency.currency.name
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
        U_CustComDt: record.inquiry.expected_closing_date.present? ? record.inquiry.expected_closing_date.strftime("%Y-%m-%d") : nil, # not
        U_SalesMgr: record.inquiry.sales_manager.try(:full_name), # record.inquiry.sales_manager.full_name,
        U_ConsigneeAddr: record.inquiry.shipping_address.remote_uid,
        U_Freight_Cost: record.inquiry.freight_cost,
        U_CnfrmAddB: "P", # hardcode
        U_Cnfrm_GSTIN: "P", # hardcode
        U_Cnfrm_PayTerm: "P", # hardcode
        U_CnfrmAddS: "P", # hardcode
        U_CnfirmQty: "P", # hardcode
        U_CnfrmRate: "P", # hardcode
        U_CnfrmTax: "P", # hardcode
        U_SO_Status: 32, # hardcode
        U_CnfrmGross: "P", # hardcode
        U_MgntDocID: record.id,
        U_Rate_Rmks: "", # hardcode
        U_Qty_Rmks: "", # hardcode
        U_Tax_Rmks: "", # hardcode
        U_Total_Rmks: "", # hardcode
        U_Ship_Rmks: "", # hardcode
        U_Bill_Rmks: "", # hardcode
        U_PostBy: "Magento", # hardcode
        U_PostMagento: "Y", # hardcode
        BPChannelCode: record.inquiry.remote_shipping_company_uid,
        U_Ovr_Margin: record.calculated_total_margin_percentage,
        U_Over_Marg_Amnt: record.calculated_total_margin,
        BPChannelContact: company_shipping_contact.present? ? company_shipping_contact.remote_uid : nil,
    }
  end
end


=begin
    {
        AttachmentEntry: record.inquiry.attachment_uid,
        BPL_IDAssignedToInvoice: 1,
        CardCode: "3",
        CntctCode: "Alok Jha",
        ContactPersonCode: 22978,
        DiscountPercent: 0,
        DocCurrency: "INR",
        DocDate: "2018-08-30",
        DocDueDate: "2018-08-29",
        DocObjectCode: "17",
        DocRate: 1,
        DocumentLines: [
            {
                BaseEntry: 3503,
                BaseLine: 2,
                BaseType: 23,
                Quantity: 140,
                UnitPrice: "1423.53"
            }
        ],
        DocumentsOwner: 121,
        NumAtCard: "PO8887",
        PaymentGroupCode: 8,
        PayToCode: "1441",
        SalesPersonCode: 151,
        ShipToCode: "1458",
        U_Bill_Rmks: "",
        U_CnfirmQty: "P",
        U_Cnfrm_GSTIN: "P",
        U_Cnfrm_PayTerm: "P",
        U_CnfrmAddB: "P",
        U_CnfrmAddS: "P",
        U_CnfrmGross: "P",
        U_CnfrmRate: "P",
        U_CnfrmTax: "P",
        U_ConsigneeAddr: "1458",
        U_CustComDt: "2018-08-29",
        U_Freight_Cost: 0,
        U_MgntDocID: 2779,
        U_Over_Marg_Amnt: 150,
        U_Ovr_Margin: 31.63,
        U_PostBy: "",
        U_PostMagento: "Y",
        U_Qty_Rmks: "",
        U_Rate_Rmks: "",
        U_SalesMgr: "Jeetendra Sharma",
        U_Ship_Rmks: "",
        U_SO_Status: "32",
        U_Tax_Rmks: "",
        U_Total_Rmks: ""
    }
=end
