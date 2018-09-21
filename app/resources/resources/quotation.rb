class Resources::Quotation < Resources::ApplicationResource
  def self.identifier
    :U_MgntDocID
  end

  def self.to_remote(record)
    items = []

    record.rows.each do |row|
      item = OpenStruct.new
      item.DiscountPercent = 5
      item.ItemCode = row.product.sku
      item.ItemDescription = row.product.name # Product Desc / NAME
      item.Quantity = row.quantity # Quantity
      item.ProjectCode = record.inquiry.recordproject_uid # Project Code
      item.LineNum = "0"  # Row Number
      item.MeasureUnit = "unit" # Unit of measure?
      item.U_MPN = "15487"
      item.U_LeadTime = "2 - 3 Days" # Lead time ?
      item.Comments = nil # Inquiry COmment
      item.UnitPrice = row.unit_cost_price # Row Unit Price
      item.Currency = "INR"# Curr
      item.TaxCode = "IG@28"# Code?
      item.U_Vendor = row.supplier.id# Supplier
      item.U_Vendor_Name = row.supplier.name# Supplier  Name
      item.Weight1 = "200"  # product Weight
      item.U_ProdBrand = row.product.brand.name# Brand
      item.WarehouseCode = 2# ship_from_warehouse
      item.LocationCode = 1
      item.HSNEntry = 7602 # HSN !!
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
        "U_MgntDocID": sales_quote.id, # Quote ID
        "CardCode": 3,  #Customer ID
        "DocDate": record.created_at.strftime('%F'), #Quote Create Date
        "ReqDate": "2018-09-10", # Commited Date
        "ProjectCode": record.inquiry.project_uid, #Project Code
        "SalesPersonCode": 8,   #record.inside_sales_owner, # Inside Sales Owner
        "NumAtCard": "test SAP",  #Comment on Quote?
        "DocCurrency": "INR",
        TaxDate: nil, # record.created_at.strftime('%F') , #Tax Date??
        "ImportEnt": 3232,
        "U_RevNo": "R1", #Quotation Revision ID
        "DocDueDate": "2018-10-10", #Quotation Valid Till ?
        "AttachmentEntry": nil,
        "DocumentLines": items,  #Products
        "U_Ovr_Margin": 14.99,
        "PaymentGroupCode": 8,
        "ShipToCode": 1458,
        "U_ConsigneeAddr": 1458,
        "U_TermCondition": "1. Cost does not include any additional certification if required as per Indian regulations. \r\n2. Any errors in Quotation including HSN codes, GST Tax rate must be notified before placing order.\r\n3. Order once placed cannot be changed.\r\n4. Bulk MRO does not accept any financial penalties for late deliveries.", # record.inquiry.commercial_terms,  # Commercial terms and conditions
        "U_TrmDeli": "EXW",  # record.inquiry.delivery_terms , # Delivery Terms
        "U_Frghtterm": "Extra as per Actual",
        "U_PackFwd": "Included",
        "U_BM_BillFromTo": record.inquiry.billing_address.id, #Bill FROM Address
        "U_SQ_Status": 6, # Commercial Status (Preparing Quotation, Quotation Sent, Follow-up etc)
        "BPL_IDAssignedToInvoice": 1,
        "U_PmntMthd": "Bank Transfer",
        "CreationDate": record.created_at.strftime('%F'), # Quote date time
        "UpdateDate": record.updated_at.strftime('%F'), # Update Quote date time
        "DocumentsOwner": 191,
        "U_SalesMgr": "Lavanya Jamma",
        "U_In_Sales_Own": "Swati Bhosale",
        "U_Out_Sales_Own": "Madan Sharma",
        "U_QuotType": 7,
        "Project": 26901,
        "PayToCode": 1441,
        "U_Procure_Date": "2018-09-10"
    }


  end

end