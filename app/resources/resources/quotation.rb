class Resources::Quotation < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.to_remote(record)
    items = []


    record.rows.each_with_index do |row, index|
      item = OpenStruct.new
      item.DiscountPercent = 0
      item.ItemCode = row.product.sku
      item.ItemDescription = row.product.name # Product Desc / NAME
      item.Quantity = row.quantity # Quantity
      item.ProjectCode = record.inquiry.project_uid # Project Code
      item.LineNum = index # Row Number
      item.MeasureUnit = row.product.measurement_unit.name # Unit of measure?
      item.U_MPN = row.inquiry_product_supplier.bp_catalog_sku
      item.U_LeadTime = row.lead_time_option.name # Lead time ?
      item.Comments = nil # Inquiry COmment
      item.UnitPrice = row.unit_cost_price # Row Unit Price
      item.Currency = "INR" # Curr
      item.TaxCode = "IG@28" # Code? Comes from Tax Label IG  = IGST
      item.U_Vendor = row.supplier.id # Supplier
      item.U_Vendor_Name = row.supplier.name # Supplier  Name
      item.Weight1 = "1" # product Weight
      item.U_ProdBrand = row.product.brand.name # Brand
      item.WarehouseCode = 2 # ship_from_warehouse
      item.LocationCode = 1
      item.HSNEntry = row.tax_code.remote_uid # HSN !!
      item.U_MgntRemark = ""
      item.U_Rmks = ""

      items.push(item.marshal_dump)


=begin
Example Product
      [
          {
              "DiscountPercent": 0,
              "ItemCode": "BM9G6G2",
              "ItemDescription": "WHIRPOOL 3 Star Direct-Cool Single Door Refrigerator, Capacity 190 Ltr, Colour Blue - WDE 205 CLS 3S",
              "Quantity": 1,
              "ProjectCode": record.inquiry.project_uid,
              "LineNum": 0,
              "MeasureUnit": "ea",
              "U_MPN": "WDE 205 CLS 3S",
              "U_LeadTime": "2-3 days",
              "Comments": nil,
              "UnitPrice": 14705,
              "Currency": "INR",
              "TaxCode": "IG@28",
              "U_Vendor": "SC-01774",
              "U_Vendor_Name": "Amazon.in",
              "Weight1": 0,
              "U_Margin": 14.994899693982,
              "U_ProdBrand": "WHIRPOOL",
              "U_BuyCost": 12500,
              "WarehouseCode": 2,
              "LocationCode": 1,
              "HSNEntry": 7602,
              "U_MgntRemark": "",
              "U_Rmks": ""
          }
      ]
=end
    end


    {
        U_MgntDocID: record.id, # Quote ID
        CardCode: record.inquiry.contact.remote_uid, #Customer ID
        DocDate: record.created_date, #Quote Create Date
        ReqDate: record.updated_date, # Commited Date
        ProjectCode: record.inquiry.project_uid, #Project Code
        SalesPersonCode: record.inside_sales_owner.remote_uid, #record.inside_sales_owner, # Inside Sales Owner
        NumAtCard: "", #Comment on Quote?
        DocCurrency: "INR",
        DocEntry: record.quotation_uid,
        TaxDate: nil, # record.created_date , #Tax Date??
        ImportEnt: 3232, # Customer PO ID Not Available Yet
        U_RevNo: "R1", #Quotation Revision ID
        DocDueDate: record.inquiry.expected_closing_date, #Quotation Valid Till ?
        AttachmentEntry: nil,
        DocumentLines: items, #Products
        U_Ovr_Margin: record.calculated_total_margin_percentage,
        PaymentGroupCode: record.inquiry.payment_option.remote_uid,
        U_ConsigneeAddr: 1458,
        U_TermCondition: record.inquiry.commercial_terms_and_conditions, #   # Commercial terms and conditions
        U_TrmDeli: record.inquiry.price_type, #  , # Delivery Terms
        U_Frghtterm: record.inquiry.freight_option,
        U_PackFwd: record.inquiry.packing_and_forwarding_option,
        U_BM_BillFromTo: record.inquiry.billing_address.id, #Bill FROM Address
        U_SQ_Status: 6, # Commercial Status (Preparing Quotation, Quotation Sent, Follow-up etc)
        BPL_IDAssignedToInvoice: 1,
        U_PmntMthd: "Bank Transfer",
        CreationDate: record.created_date, # Quote date time
        UpdateDate: record.updated_date, # Update Quote date time
        DocumentsOwner: record.inquiry.outside_sales_owner.remote_uid, #record.inquiry.outside_sales_owner.remote_uid,
        U_SalesMgr: record.inquiry.sales_manager.full_name,
        U_In_Sales_Own: record.inquiry.inside_sales_owner.full_name,
        U_Out_Sales_Own: record.inquiry.outside_sales_owner.full_name,
        U_QuotType: record.inquiry.opportunity_type,
        Project: record.inquiry.project_uid,
    }

  end

  def self.update(id, record, options = {})
    OpenStruct.new(patch("/#{collection_name}(#{id})", body: to_remote(record,options).to_json).parsed_response)
    id
  end

end