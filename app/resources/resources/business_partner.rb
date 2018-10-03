class Resources::BusinessPartner < Resources::ApplicationResource

  def self.identifier
    :CardCode
  end

  def self.create(record)
    id = super(record) do |validated_response|
      self.update_associated_records(record, validated_response)
    end

    id
  end

  def self.update(id, record)
    super(id, record, use_quotes_for_id: true) do
      remote_record = self.find(record.remote_uid)
      self.update_associated_records(record, remote_record) if remote_record.blank?
    end
  end

  def self.find_by_obj(company)
    response = get("/#{collection_name}?$filter=CardName eq '#{company}'&$top=1")
    validated_response = get_validated_response(response)
    log_request(:get, company, response, is_query: true)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
      update_associated_records(company, remote_record)

      remote_record[self.identifier.to_s]
    end
  end

  def self.update_associated_records(company, response)
    # addresses = OpenStruct.new(response.value).BPAddresses
    contacts = response['ContactEmployees']

    #Update Address's row numbers
    #
    # addresses.each do |address|
    #   if address["AddressName"].present?
    #
    #     address["AddressName"] = address["AddressName"], address["RowNum"].join(",")
    #   else
    #     address["AddressName"] = address["RowNum"]
    #   end
    #
    #
    # end if addresses.present?
    #
    #   address_row_nums.each_with_index do |address_legacy_id, remote_row_num|
    #     address_to_update = company.addresses.find_by_legacy_id(address_legacy_id)
    #     if address_to_update.present?
    #       address_to_update.remote_row_num = remote_row_num
    #       address_to_update.save
    #     end
    #   end
    # end
    #

    contacts.each do |contact|
      remote_uid = contact["InternalCode"]
      company_contact = company.company_contacts.joins(:contact).where('contacts.email = ?', contact["E_Mail"]).first
      company_contact.update_attributes(:remote_uid => remote_uid)
    end if contacts.present?
  end

  def self.to_remote(record)
    addresses = []
    bp_tax_collection = []
    contacts = []
    response = {}

    row_num = 0
    record.addresses.each do |address|
      street_address = [address.street1, address.street2].compact.join(' ')
      street = street_address[0..99]
      address_name2 = street_address[100..149]
      address_name3 = street_address[150..199]
      # First Entry for Billing Address
      address_row = OpenStruct.new
      address_row.AddressName = address.remote_uid
      address_row.BPCode = record.remote_uid
      address_row.Street = street
      address_row.Block = nil
      address_row.ZipCode = address.pincode
      address_row.City = address.city_name
      address_row.County = nil
      address_row.Country = address.country_code
      address_row.State = address.state.try(:region_code_uid)
      address_row.BuildingFloorRoom = nil
      address_row.AddressType = "bo_BillTo"
      address_row.AddressName2 = address_name2
      address_row.AddressName3 = address_name3
      address_row.StreetNo = nil
      address_row.GSTIN = address.gst
      address_row.GstType = "gstRegularTDSISD"
      address_row.U_VAT = address.vat
      address_row.U_CST = address.cst
      address_row.RowNum = row_num
      addresses.push(address_row.marshal_dump)
      row_num += 1

      # Second Entry for Shipping Address
      #
      address_row.AddressType = "bo_ShipTo"
      address_row.RowNum = row_num
      addresses.push(address_row.marshal_dump)


      # BPFiscalTaxIDCollection Start
      bp_tax_collection_row = OpenStruct.new

      #Address Level tax Info
      bp_tax_collection_row.Address = address.remote_uid
      bp_tax_collection_row.AddrType = "bo_BillTo"
      bp_tax_collection_row.BPCode = record.remote_uid
      bp_tax_collection_row.TaxId1 = address.cst
      bp_tax_collection_row.TaxId2 = address.vat
      #bp_tax_collection_row.TaxId6 = address.vat #TAN num

      #Company level info
      bp_tax_collection_row.TaxId0 = record.pan
      #bp_tax_collection_row.TaxId3 = record.cmp_st;
      #bp_tax_collection_row.TaxId4 = record.cmp_edr;
      bp_tax_collection_row.TaxId6 = record.tan
      bp_tax_collection_row.TaxId8 = record.company_type
      bp_tax_collection_row.TaxId9 = record.nature_of_business

      #Push as billing
      bp_tax_collection.push(bp_tax_collection_row.marshal_dump)

      #Push as shipping
      bp_tax_collection_row.AddrType = "bo_ShipTo" #Address
      bp_tax_collection.push(bp_tax_collection_row.marshal_dump)

      # BPFiscalTaxIDCollection End

      row_num += 1

      address_tax_row = OpenStruct.new
      address_tax_row.Address = address.remote_uid
      address_tax_row.TaxId0 = record.try(:pan) || "ABCDE1234F"
      address_tax_row.TaxId3 = address.cst
      address_tax_row.TaxId4 = address.excise
      address_tax_row.TaxId5 = nil
      address_tax_row.TaxId6 = record.try(:tan)
      address_tax_row.TaxId7 = nil
      address_tax_row.TaxId8 = nil
      address_tax_row.TaxId9 = record.nature_of_business
      address_tax_row.TaxId10 = nil
      address_tax_row.TaxId11 = address.vat

      #
    end

    #push company pan, edr,tan etc in BPFiscalTaxIDCollection
    bp_tax_collection_row = OpenStruct.new

    #Address Level tax Info
    bp_tax_collection_row.TaxId0 = record.pan || "ABCDE1234F"
    #bp_tax_collection_row.TaxId3 = address.remote_uid #Magento field cmp_st
    #bp_tax_collection_row.TaxId4 = address.remote_uid #Magento field cmp_edr
    bp_tax_collection_row.TaxId6 = record.tan
    bp_tax_collection_row.TaxId8 = record.company_type
    bp_tax_collection_row.TaxId9 = record.nature_of_business
    bp_tax_collection_row.Address = ""
    bp_tax_collection_row.AddrType = "bo_ShipTo"
    bp_tax_collection_row.TaxId1 = record.default_shipping_address.present? ? record.default_shipping_address.cst : nil
    bp_tax_collection_row.BPCode = record.remote_uid
    bp_tax_collection.push(bp_tax_collection_row.marshal_dump)


    record.company_contacts.each do |company_contact|
      contact = company_contact.contact

      contact_row = OpenStruct.new
      contact_row.CardCode = record.remote_uid
      contact_row.Name = contact.full_name
      contact_row.Position = contact.designation
      contact_row.Address = nil
      contact_row.Phone1 = contact.telephone
      contact_row.Phone2 = nil
      contact_row.MobilePhone = contact.mobile
      contact_row.E_Mail = contact.email
      contact_row.Remarks1 = ""
      contact_row.DateOfBirth = nil
      contact_row.Gender = "gt_Undefined"
      contact_row.Title = contact.prefix
      contact_row.FirstName = contact.first_name
      contact_row.MiddleName = nil
      contact_row.LastName = contact.last_name
      contact_row.InternalCode = company_contact.remote_uid
      contact_row.U_MgntCustID = contact.legacy_id.present? ? contact.legacy_id : contact.id

      contacts.push(contact_row.marshal_dump)
    end

    response = {
        CardCode: record.remote_uid || record.generate_remote_uid,
        CardName: record.name,
        CardType: record.is_supplier ? "cSupplier" : "cCustomer",
        GroupCode: record.account.remote_uid,
        Address: record.default_billing_address.present? ? record.default_billing_address.to_s : nil,
        ZipCode: record.default_billing_address.present? ? record.default_billing_address.pincode : nil,
        Country: record.default_billing_address.present? ? record.default_billing_address.country_code : nil,
        EmailAddress: record.default_company_contact.present? ? record.default_company_contact.contact.email : nil,
        City: record.default_billing_address.present? ? record.default_billing_address.city_name : nil,
        ContactPerson: record.default_company_contact.present? ? record.default_company_contact.full_name : nil,
        OwnerCode: record.inside_sales_owner_id.present? ? record.inside_sales_owner_id.full_name : nil,
        Phone1: record.phone,
        Phone2: nil,
        Fax: nil,
        PayTermsGrpCode: 1,
        CreditLimit: 0,
        SalesPersonCode: -1,
        Currency: nil,
        Cellular: record.mobile,
        County: nil,
        DefaultBranch: nil,
        DefaultBankCode: "-1",
        ShippingType: nil,
        IBAN: nil,
        Block: nil,
        ShipToDefault: record.default_shipping_address.present? ? record.default_shipping_address.remote_uid : nil,
        BilltoDefault: record.default_shipping_address.present? ? record.default_billing_address.remote_uid : nil,
        Territory: nil,
        GTSBankAccountNo: nil,
        U_MSME: record.is_msme ? "Yes" : "No",
        U_URD: record.is_unregistered_dealer ? "Yes" : "No",
        BPAddresses: addresses,
        ContactEmployees: contacts,
        BPFiscalTaxIDCollection: bp_tax_collection
    }

    response
  end
end