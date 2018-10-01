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
      item.LineNum = row.sr_no # Row Number
      item.MeasureUnit = row.product.measurement_unit.name # Unit of measure?
      item.U_MPN = row.product.mpn
      item.U_LeadTime = row.lead_time_option.name # Lead time ?
      item.Comments = nil # Inquiry COmment
      item.UnitPrice = row.unit_selling_price # Row Unit Price
      item.Currency = record.currency.name # Curr
      item.TaxCode = row.taxation.to_remote_s # Code? Comes from Tax Label IG  = IGST
      item.U_Vendor = row.supplier.remote_uid # Supplier
      item.U_BuyCost = row.unit_cost_price_with_unit_freight_cost
      item.U_Vendor_Name = row.supplier.name # Supplier  Name
      item.Weight1 = "1" # product Weight
      item.U_ProdBrand = row.product.brand.try(:name) # Brand
      item.WarehouseCode = record.inquiry.ship_from.remote_uid # ship_from_warehouse
      item.LocationCode = record.inquiry.ship_from.location_uid

      if row.product.is_service
        item.SACEntry = row.tax_code.remote_uid # HSN !!
      else
        item.HSNEntry = row.tax_code.remote_uid # HSN !!
      end
      item.U_MgntRemark = ""
      item.U_Rmks = ""

      items.push(item.marshal_dump)

    end
    sez = nil

    if record.inquiry.is_sez
      sez = {
          'ImportOrExport': 'tYES',
          'ImportOrExportType': 'et_SEZ_Unit',
      }
    end
    {
        U_MgntDocID: record.to_param, # Quote ID
        CardCode: record.inquiry.company.remote_uid, #Customer ID
        ReqDate: record.updated_date, # Commited Date
        ProjectCode: record.inquiry.project_uid, #Project Code
        SalesPersonCode: record.inquiry.inside_sales_owner.salesperson_uid, #record.inside_sales_owner, # Inside Sales Owner
        NumAtCard: record.inquiry.subject, #Comment on Quote?
        DocCurrency: record.currency.name,
        DocEntry: record.quotation_uid,
        ImportEnt: record.inquiry.customer_po_number, # Customer PO ID Not Available Yet
        U_RevNo: "R1", #Quotation Revision ID
        DocDate: record.created_date, #Quote Create Date
        DocDueDate: record.inquiry.expected_closing_date, #Quotation Valid Till ?
        TaxDate: record.inquiry.customer_order_date, # record.created_date , #Tax Date??
        AttachmentEntry: record.inquiry.attachment_uid,
        DocumentLines: items, #Products]
        U_Ovr_Margin: record.calculated_total_margin_percentage,
        PaymentGroupCode: record.inquiry.payment_option.remote_uid,
        U_TermCondition: record.inquiry.commercial_terms_and_conditions, #   # Commercial terms and conditions
        U_TrmDeli: record.inquiry.price_type, #  , # Delivery Terms
        U_Frghtterm: record.inquiry.freight_option,
        U_PackFwd: record.inquiry.packing_and_forwarding_option,
        U_BM_BillFromTo: record.inquiry.billing_address.remote_uid, #Bill FROM Address
        U_SQ_Status: Inquiry.statuses[record.inquiry.status], # Commercial Status (Preparing Quotation, Quotation Sent, Follow-up etc)
        BPL_IDAssignedToInvoice: 1,
        ShipToCode: record.inquiry.shipping_address.remote_uid,
        PayToCode: record.inquiry.billing_address.remote_uid,
        U_PmntMthd: "Bank Transfer",
        CreationDate: record.created_date, # Quote date time
        UpdateDate: record.updated_date, # Update Quote date time
        DocumentsOwner: record.inquiry.outside_sales_owner.employee_uid, #record.inquiry.outside_sales_owner.remote_uid,
        U_SalesMgr: record.inquiry.sales_manager.try(:full_name) || "Devang Shah",
        U_In_Sales_Own: record.inquiry.inside_sales_owner.try(:full_name),
        U_Out_Sales_Own: record.inquiry.outside_sales_owner.try(:full_name),
        U_QuotType: record.inquiry.opportunity_type,
        Project: record.inquiry.project_uid,
        TaxExtension: sez

    }

  end

  def self.create(record)
    #log and Validate Response
    create_or_update_attachments(record)

    response = post("/#{collection_name}", body: to_remote(record).to_json)

    get_validated_response(:post, record, response)
  end

  def self.update(id, record, options = {})
    create_or_update_attachments(record)

    response = patch("/#{collection_name}(#{id})", body: to_remote(record).to_json)
    get_validated_response(:patch, record, response)
    id
  end

  def self.create_or_update_attachments(record)
    if record.inquiry.attachment_uid.present?
      record.inquiry.attachment_uid = Resources::Attachment.create(record.inquiry)
      record.save
    else
      Resources::Attachment.update(record.inquiry.attachment_uid, record.inquiry)
    end
  end

end