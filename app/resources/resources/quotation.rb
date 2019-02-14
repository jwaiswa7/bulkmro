

class Resources::Quotation < Resources::ApplicationResource
  def self.identifier
    :DocEntry
  end

  def self.create(record)
    id = super(record) do |response|
      update_associated_records(response['DocEntry'], force_find: true) if response['DocEntry'].present?
    end

    id
  end

  def self.update(id, record)
    update_associated_records(id, force_find: true) # todo remove this when update associated records works on create

    super(id, record) do |response|
      update_associated_records(id, force_find: true) if response.present?
    end
  end

  def self.update_associated_records(id, force_find: false)
    response = find(id) if force_find
    return if response.blank?

    document_lines = response['DocumentLines']
    inquiry = Inquiry.find_by_inquiry_number(response['Project'])

    if inquiry.present? && inquiry.final_sales_quote.present?
      final_sales_quote = inquiry.final_sales_quote

      document_lines.each do |line|
        sales_quote_row = final_sales_quote.rows.select { |r| r.sku == line['ItemCode'] }[0]
        sales_quote_row.update_attributes!(remote_uid: line['LineNum']) if sales_quote_row.present?
      end
    end
  end

  def self.to_remote(record)
    items = []

    record.rows.each_with_index do |row, index|
      if row.product.not_synced?
        row.product.update_attributes(remote_uid: ::Resources::Item.create(row.product))
      end

      item = OpenStruct.new
      item.DiscountPercent = 0
      item.ItemCode = row.product.sku
      item.ItemDescription = row.to_bp_catalog_s # Product Desc / NAME
      item.Quantity = row.quantity # Quantity
      item.ProjectCode = record.inquiry.project_uid # Project Code
      item.LineNum = row.sr_no # Row Number
      item.MeasureUnit = row.measurement_unit.try(:to_s) || row.product.measurement_unit.try(:to_s) || MeasurementUnit.default # Unit of measure?
      item.U_MPN = row.product.try(:mpn) || 'NIL'
      item.U_LeadTime = row.lead_time_option.try(:name) # Lead time ?
      item.Comments = nil # Inquiry Comment
      item.UnitPrice = row.unit_selling_price # Row Unit Price
      item.Currency = 'INR' # record.currency.name
      item.TaxCode = row.taxation.to_remote_s # Code? Comes from Tax Label IG  = IGST
      item.U_Vendor = row.supplier.remote_uid # Supplier
      item.U_BuyCost = row.unit_cost_price_with_unit_freight_cost
      item.U_Vendor_Name = row.supplier.name # Supplier  Name
      item.Weight1 = '1' # product Weight
      item.U_ProdBrand = row.product.brand.try(:name) # Brand
      item.WarehouseCode = record.inquiry.ship_from.remote_uid # ship_from_warehouse
      item.LocationCode = record.inquiry.ship_from.location_uid
      item.U_Margin = row.margin_percentage

      if row.product.is_service
        item.SACEntry = row.best_tax_code.remote_uid # HSN !!
      else
        item.HSNEntry = row.best_tax_code.remote_uid # HSN !!
      end

      item.U_MgntRemark = ''
      item.U_Rmks = ''
      if row.product.is_kit
        item.TreeType = 'iSalesTree'
        items.push(item.marshal_dump)

        line_num = row.sr_no + 1

        row.product.kit.kit_product_rows.each do |kit_product|
          kit_item = OpenStruct.new
          kit_item.TreeType = 'iIngredient'
          kit_item.ItemCode = kit_product.product.sku
          kit_item.ItemDescription = kit_product.product.name
          kit_item.Quantity = kit_product.quantity
          kit_item.ProjectCode = record.inquiry.project_uid
          kit_item.WarehouseCode = record.inquiry.ship_from.remote_uid
          kit_item.LocationCode = record.inquiry.ship_from.location_uid

          if kit_product.product.is_service
            kit_item.SACEntry = kit_product.best_tax_code.remote_uid
          else
            kit_item.HSNEntry = kit_product.best_tax_code.remote_uid
          end

          # kit_item.U_ProdBrand = kit_product.product.brand.try(:name)
          # kit_item.U_BuyCost = row.unit_cost_price_with_unit_freight_cost
          # kit_item.U_Vendor_Name = row.supplier.name

          kit_item.LineNum = line_num
          line_num = line_num + 1
          items.push(kit_item.marshal_dump)
        end
      else
        items.push(item.marshal_dump)
      end
    end

    sez = if record.inquiry.is_sez
      {
          'ImportOrExport': 'tYES',
          'ImportOrExportType': 'et_SEZ_Unit',
      }
    else
      nil
    end

    company_contact = record.inquiry.company.company_contacts.joins(:contact).where('contacts.email = ?', record.inquiry.contact.email).first
    company_shipping_contact = record.inquiry.shipping_company.company_contacts.joins(:contact).where('contacts.email = ?', record.inquiry.shipping_contact.present? ? record.inquiry.shipping_contact.email : record.inquiry.billing_contact.email).first
    {
        U_MgntDocID: record.to_param, # Quote ID
        CardCode: record.inquiry.company.remote_uid, # Customer ID
        ReqDate: record.updated_date, # Commited Date
        ProjectCode: record.inquiry.project_uid, # Project Code
        SalesPersonCode: record.inquiry.inside_sales_owner.salesperson_uid, # record.inside_sales_owner, # Inside Sales Owner
        NumAtCard: record.inquiry.subject, # Comment on Quote?
        DocCurrency: 'INR', # record.currency.name
        DocEntry: record.quotation_uid,
        ImportEnt: record.inquiry.customer_po_number, # Customer PO ID Not Available Yet
        U_RevNo: record.ancestors.size, # Quotation Revision ID
        DocDate: record.created_date, # Quote Create Date
        DocDueDate: record.inquiry.valid_end_time.present? ? record.inquiry.valid_end_time.strftime('%Y-%m-%d') : nil, # Quotation Valid Till ?
        TaxDate: record.inquiry.customer_order_date.present? ? record.inquiry.customer_order_date.strftime('%Y-%m-%d') : nil, # record.created_date , #Tax Date??
        AttachmentEntry: record.inquiry.attachment_uid,
        DocumentLines: items, # [Products]
        U_Ovr_Margin: record.calculated_total_margin_percentage,
        PaymentGroupCode: record.inquiry.payment_option.remote_uid,
        U_TermCondition: record.inquiry.commercial_terms_and_conditions, #   # Commercial terms and conditions
        U_TrmDeli: record.inquiry.price_type, #  , # Delivery Terms
        U_Frghtterm: record.inquiry.freight_option,
        U_PackFwd: record.inquiry.packing_and_forwarding_option,
        U_BM_BillFromTo: record.inquiry.bill_from.remote_uid, # Bill FROM Address
        U_SQ_Status: Inquiry.statuses[record.inquiry.status], # Commercial Status (Preparing Quotation, Quotation Sent, Follow-up etc)
        BPL_IDAssignedToInvoice: record.inquiry.ship_from.remote_branch_code,
        ShipToCode: record.inquiry.remote_shipping_address_uid, # record.inquiry.shipping_address.remote_uid,
        PayToCode: record.inquiry.billing_address.remote_uid,
        U_PmntMthd: 'Bank Transfer',
        CreationDate: record.created_date, # Quote date time
        UpdateDate: record.updated_date, # Update Quote date time
        DocumentsOwner: record.inquiry.outside_sales_owner.employee_uid, # record.inquiry.outside_sales_owner.remote_uid,
        U_SalesMgr: record.inquiry.sales_manager.try(:full_name) || 'Devang Shah',
        U_In_Sales_Own: record.inquiry.inside_sales_owner.try(:full_name),
        U_Out_Sales_Own: record.inquiry.outside_sales_owner.try(:full_name),
        U_QuotType: record.inquiry.opportunity_type,
        Project: record.inquiry.project_uid,
        TaxExtension: sez,
        BPChannelCode: record.inquiry.remote_shipping_company_uid,
        BPChannelContact: company_shipping_contact.present? ? company_shipping_contact.remote_uid : nil,
        ContactPersonCode: company_contact.present? ? company_contact.remote_uid : nil,
        U_ConsigneeAddr: record.inquiry.shipping_address.remote_uid
    }
  end
end
