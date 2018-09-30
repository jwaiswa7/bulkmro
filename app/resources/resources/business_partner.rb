class Resources::BusinessPartner < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.create(record)

    account = record.account

    if !account.remote_uid.present?
      account.remote_uid = Resources::BusinessPartnerGroup.create(account)
      account.save
    end

    response = OpenStruct.new(post("/#{collection_name}", body: to_remote(record,{}).to_json).parsed_response)
    response.send(self.identifier)

    #update contact internal key and address's row num
    self.update_sap_fields(record, response)
  end

  def self.update_sap_fields(company, response)
    addresses = response.BPAddresses
    contacts = response.ContactEmployees

    if addresses.present?
      addresses.each do |address|
        #company_address = company.addresses.find_by_remote_uid(address.AddressName)
      end
    end

    if contacts.present?
      contacts.each do |contact|
        remote_uid = contact.InternalCode
        company_contact = company.contact.find_by_email(contact.E_Mail)
        company_contact.remote_uid = remote_uid
        company_contact.save
      end
    end
  end

  def self.update(id, record, options = {})
    response = OpenStruct.new(patch("/#{collection_name}('#{id}')", body: to_remote(record,options).to_json).parsed_response)
    sap_response = self.validate_response(response)

    if sap_response.status
      get_response = self.find(record.remote_uid)
      get_response_validate = self.validate_response(get_response)

      if get_response_validate.status
        #update contact internal key and address's row num
        update_sap_fields(record, get_response)
      else
        #log error
      end
    else
      #log error
    end
  end

  def self.to_remote(record, options)

    addresses = []
    bp_tax_collection = []
    contacts = []
    response = {}

    if options[:skip_children] == true
      response = {
          CardCode: record.remote_uid,
          CardName: record.name,
          CardType: record.is_supplier ? "cSupplier" : "cCustomer", #
          GroupCode: record.account.remote_uid,
          Address: record.default_billing_address.present? ? record.default_billing_address.to_s : "",
          ZipCode: record.default_billing_address.present? ? record.default_billing_address.pincode : "",
          Country: record.default_billing_address.present? ? record.default_billing_address.country_code : "",
          EmailAddress: record.default_company_contact.present? ? record.default_company_contact.contact.email : "",
          City: record.default_billing_address.present? ? record.default_billing_address.city_name : "",
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
          IBAN: nil, #
          Block: nil, #
          ShipToDefault: record.default_billing_address.present? ? record.default_shipping_address.remote_uid : "",
          BilltoDefault: record.default_billing_address.present? ? record.default_billing_address.remote_uid : "",
          Territory: nil,
          GTSBankAccountNo: nil,
          U_MSME: record.is_msme ? "Yes" : "No",
          U_URD: record.is_unregistered_dealer ? "Yes" : "No",
          BPAddresses: [],
          BPFiscalTaxIDCollection: []
      }

    else

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
        address_row.State = address.state.region_code
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
      bp_tax_collection_row.TaxId0 = record.pan
      #bp_tax_collection_row.TaxId3 = address.remote_uid #Magento field cmp_st
      #bp_tax_collection_row.TaxId4 = address.remote_uid #Magento field cmp_edr
      bp_tax_collection_row.TaxId6 = record.tan
      bp_tax_collection_row.TaxId8 = record.company_type
      bp_tax_collection_row.TaxId9 = record.nature_of_business
      bp_tax_collection_row.Address = ""
      bp_tax_collection_row.AddrType = "bo_ShipTo"
      bp_tax_collection_row.TaxId1 = record.default_shipping_address.present? ? record.default_shipping_address.cst : ""
      bp_tax_collection_row.BPCode = record.remote_uid
      bp_tax_collection.push(bp_tax_collection_row.marshal_dump)


      record.contacts.each do |contact|
        contact_row = OpenStruct.new
        contact_row.CardCode = "cs15446992"
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
        contact_row.InternalCode = contact.remote_uid
        contact_row.U_MgntCustID = contact.legacy_id.present? ? contact.legacy_id : contact.id
        contacts.push(contact_row.marshal_dump)
      end

      response = {
          CardCode: record.remote_uid,
          CardName: record.name,
          CardType: record.is_supplier ? "cSupplier" : "cCustomer",
          GroupCode: record.account.remote_uid,
          Address: record.default_billing_address.present? ? record.default_billing_address.to_s : "",
          ZipCode: record.default_billing_address.present? ? record.default_billing_address.pincode : "",
          Country: record.default_billing_address.present? ? record.default_billing_address.country_code : "",
          EmailAddress: record.default_company_contact.present? ? record.default_company_contact.contact.email : "",
          City: record.default_billing_address.present? ? record.default_billing_address.city_name : "",
          ContactPerson: record.default_company_contact.present? ? record.default_company_contact.full_name : "",
          OwnerCode: record.inside_sales_owner_id.present? ? record.inside_sales_owner_id.full_name : "",
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
          ShipToDefault: record.default_shipping_address.present? ? record.default_shipping_address.remote_uid : "",
          BilltoDefault: record.default_shipping_address.present? ? record.default_billing_address.remote_uid : "",
          Territory: nil,
          GTSBankAccountNo: nil,
          U_MSME: record.is_msme ? "Yes" : "No",
          U_URD: record.is_unregistered_dealer ? "Yes" : "No",
          BPAddresses: addresses,
          ContactEmployees: contacts,
          BPFiscalTaxIDCollection: bp_tax_collection
      }

    end

    response
  end
end
