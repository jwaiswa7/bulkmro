class Resources::BusinessPartner < Resources::ApplicationResource

  def self.identifier
    :Code
  end

  def self.create(record)
    response = OpenStruct.new(post("/#{collection_name}", body: to_remote(record,{}).to_json).parsed_response)
    response.send(self.identifier)
  end

  def self.update(id, record, options = {})
    OpenStruct.new(patch("/#{collection_name}('#{id}')", body: to_remote(record,options).to_json).parsed_response)
    id
  end

  def self.to_remote(record, options)

    addresses = []
    addresses_with_tax = []
    contacts = []
    response = {}
    states = {
        'Andaman and Nicobar Islands' => 'AN',
        'Andhra Pradesh' => 'AD',
        'Arunachal Pradesh' => 'AR',
        'Assam' => 'AS',
        'Bihar' => 'BR',
        'Chandigarh' => 'CH',
        'Chattisgarh' => 'CG',
        'Dadra and Nagar Haveli' => 'DN',
        'Daman and Diu' => 'DD',
        'Delhi' => 'DL',
        'Goa' => 'GA',
        'Gujarat' => 'GJ',
        'Haryana' => 'HR',
        'Himachal Pradesh' => 'HP',
        'Jammu and Kashmir' => 'JK',
        'Jharkhand' => 'JH',
        'Karnataka' => 'KA',
        'Kerala' => 'KL',
        'Lakshadweep Islands' => 'LD',
        'Madhya Pradesh' => 'MP',
        'Maharashtra' => 'MH',
        'Manipur' => 'MN',
        'Meghalaya' => 'ML',
        'Mizoram' => 'MZ',
        'Nagaland' => 'NL',
        'Odisha' => 'OD',
        'Pondicherry' => 'PY',
        'Punjab' => 'PB',
        'Rajasthan' => 'RJ',
        'Sikkim' => 'SK',
        'Tamil Nadu' => 'TN',
        'Telangana' => 'TS',
        'Tripura' => 'TR',
        'Uttar Pradesh' => 'UP',
        'Uttarakhand' => 'UK',
        'West Bengal' => 'WB',
    }


    if options[:skip_children] == true

      response = {
          CardCode: record.remote_uid, #record.remote_uid, # record.remote_uid,#Company Code
          CardName: record.name, #Company Name
          CardType: record.is_supplier ? "cSupplier" : "cCustomer", #
          GroupCode: record.account.remote_uid, #Company Alias
          Address: record.default_billing_address.to_s, #
          ZipCode: record.default_billing_address.pincode, #"410209", #Company zipcode
          Country: record.default_billing_address.country_code, #"IN", #Company Country
          EmailAddress: record.default_company_contact.contact.email, # "sales@universalflowtech.com", #Customer Email ID
          City: record.default_billing_address.city_name, #Company CIty
          Phone1: record.phone, # "9029482674", #Company Phone
          Phone2: nil, #
          Fax: nil, #
          PayTermsGrpCode: 1, #
          CreditLimit: 0, #
          SalesPersonCode: -1, #
          Currency: nil, #
          Cellular: record.mobile, #Company Mobile
          County: nil, #
          DefaultBranch: nil, #
          DefaultBankCode: "-1", #
          ShippingType: nil, #
          IBAN: nil, #
          Block: nil, #
          ShipToDefault: record.default_shipping_address.remote_uid, #Default Shipping Address
          BilltoDefault: record.default_billing_address.remote_uid, #Default Billing Address
          Territory: nil, #Company Territory
          GTSBankAccountNo: nil, #
          U_MSME: record.is_msme ? "Yes" : "No", #MSME
          U_URD: record.is_unregistered_dealer ? "Yes" : "No", #MSME #URD
          BPAddresses: [],
          BPFiscalTaxIDCollection: []
      }

    else

      default_address_tax_row = OpenStruct.new
      default_address_tax_row.Address = "" #Address
      default_address_tax_row.TaxId0 = record.try(:pan) #"AADFU8382N" #Company PAN#
      default_address_tax_row.TaxId3 = nil #Company Service Tax
      default_address_tax_row.TaxId4 = nil #Central Excise No.
      default_address_tax_row.TaxId5 = nil #
      default_address_tax_row.TaxId6 = record.try(:tan) #TAN
      default_address_tax_row.TaxId7 = nil #
      default_address_tax_row.TaxId8 = nil #company_type
      default_address_tax_row.TaxId9 = "dealer" #nature_of_business
      default_address_tax_row.TaxId10 = nil #
      default_address_tax_row.TaxId11 = nil #Company VAT
      addresses_with_tax.push(default_address_tax_row.marshal_dump)

      # See JSON DUMP [1] Below
      record.addresses.each do |address|
        # First Entry for Billing Address
        address_row = OpenStruct.new
        address_row.AddressName = address.remote_uid #Company Billing Address
        address_row.Street = [address.street1, address.street2].compact.join(' ') # address
        address_row.Block = nil #
        address_row.ZipCode = address.pincode #"410209" #Company zipcode
        address_row.City = address.city_name # "Navi Mumbai" #Company CIty
        address_row.County = nil #
        address_row.Country = address.country_code #"IN", #Company Country
        address_row.State = states[address.state_name] || "MH" #"MH", #Company State
        address_row.BuildingFloorRoom = nil #
        address_row.AddressType = "bo_BillTo" #
        address_row.AddressName2 = nil #address
        address_row.AddressName3 = nil #address
        address_row.StreetNo = nil #
        address_row.GSTIN = address.gst #"27AADFU8382N1ZD" #Company GST
        address_row.GstType = "gstRegularTDSISD" # ???
        address_row.U_VAT = address.vat #Company VAT
        address_row.U_CST = address.cst #Company  CST
        addresses.push(address_row.marshal_dump)

        # Second Entry for Shipping Address
        address_row = OpenStruct.new
        address_row.AddressName = address.remote_uid #Company Billing Address
        address_row.Street = [address.street1, address.street2].compact.join(' ') #"Office No.1 #address
        address_row.Block = nil #
        address_row.ZipCode = address.pincode #"410209" #Company zipcode
        address_row.City = address.city_name # "Navi Mumbai" #Company CIty
        address_row.County = nil #
        address_row.Country = address.country_code #"IN", #Company Country
        address_row.State = states[address.state_name] || "MH" #"MH", #Company State
        address_row.BuildingFloorRoom = nil #
        address_row.AddressType = "bo_ShipTo" #
        address_row.AddressName2 = nil #address
        address_row.AddressName3 = nil #address
        address_row.StreetNo = nil #
        address_row.GSTIN = address.gst #"27AADFU8382N1ZD" #Company GST#
        address_row.GstType = "gstRegularTDSISD" #
        address_row.U_VAT = "" #Company VAT#
        address_row.U_CST = "" #Company  CST#
        address_row.AddressType = "bo_ShipTo" #
        addresses.push(address_row.marshal_dump)

        address_tax_row = OpenStruct.new
        address_tax_row.Address = address.remote_uid #Address
        address_tax_row.TaxId0 = record.try(:pan) || "ABCDE1234F" #Company PAN#
        address_tax_row.TaxId3 = address.cst #Company Service Tax
        address_tax_row.TaxId4 = address.excise #Central Excise No.
        address_tax_row.TaxId5 = nil #
        address_tax_row.TaxId6 = record.try(:tan) #TAN
        address_tax_row.TaxId7 = nil #
        address_tax_row.TaxId8 = nil #company_type
        address_tax_row.TaxId9 = "dealer" #nature_of_business
        address_tax_row.TaxId10 = nil #
        address_tax_row.TaxId11 = address.vat #Company VAT
        addresses_with_tax.push(address_tax_row.marshal_dump)
        addresses_with_tax.push(address_tax_row.marshal_dump)
      end

      # See JSON DUMP [2]
      record.contacts.each do |contact|
        # First Entry for Billing Address
        contact_row = OpenStruct.new
        contact_row.CardCode = "cs15446992" # record.remote_uid #Company Code #"SC-7419" #CardCode
        contact_row.Name = contact.full_name #"B.S. GAUTAM-849" #
        contact_row.Position = contact.designation #nil #Position
        contact_row.Address = nil #Address
        contact_row.Phone1 = contact.telephone #nil #Contact Person Phone
        contact_row.Phone2 = nil #
        contact_row.MobilePhone = contact.mobile #"9029482674" #Contact Person Phone
        contact_row.E_Mail = contact.email #"sales@universalflowtech.com" #Contact Person EMail
        contact_row.Remarks1 = "" #Customer Line Manager
        contact_row.DateOfBirth = nil #Date of Birth
        contact_row.Gender = "gt_Undefined" #Gender
        contact_row.Title = nil #Prefix (Mr / Mrs / Ms)
        contact_row.FirstName = contact.first_name #"B.S." #Contact Person First Name
        contact_row.MiddleName = nil #Contact Person Middle Name
        contact_row.LastName = contact.last_name #"GAUTAM" #Contact Person Last Name
        contacts.push(contact_row.marshal_dump)

        response = {
            CardCode: record.remote_uid, #record.remote_uid, # record.remote_uid,#Company Code
            CardName: record.name, #Company Name
            CardType: record.is_supplier ? "cSupplier" : "cCustomer", #
            GroupCode: record.account.remote_uid, #Company Alias
            Address: record.default_billing_address.to_s, #
            ZipCode: record.default_billing_address.pincode, #"410209", #Company zipcode
            Country: record.default_billing_address.country_code, #"IN", #Company Country
            EmailAddress: record.default_company_contact.email, # "sales@universalflowtech.com", #Customer Email ID
            City: record.default_billing_address.city_name, #Company CIty
            Phone1: record.phone, # "9029482674", #Company Phone
            Phone2: nil, #
            Fax: nil, #
            PayTermsGrpCode: 1, #
            CreditLimit: 0, #
            SalesPersonCode: -1, #
            Currency: nil, #
            Cellular: record.mobile, #Company Mobile
            County: nil, #
            DefaultBranch: nil, #
            DefaultBankCode: "-1", #
            ShippingType: nil, #
            IBAN: nil, #
            Block: nil, #
            ShipToDefault: record.default_shipping_address.remote_uid, #Default Shipping Address
            BilltoDefault: record.default_billing_address.remote_uid, #Default Billing Address
            Territory: nil, #Company Territory
            GTSBankAccountNo: nil, #
            U_MSME: record.is_msme ? "Yes" : "No", #MSME
            U_URD: record.is_unregistered_dealer ? "Yes" : "No", #MSME #URD
            BPAddresses: addresses,
            ContactEmployees: contacts,
            BPFiscalTaxIDCollection: addresses_with_tax,
        }
      end
    end

    response
  end
end


=begin

DUMP [1]


    [
            {
                AddressName: "4159", #Company Billing Address
                Street: "Office No.1, Shree Sai CHS., Plot No.20, Sector No.20, Kamothe,", #address
                Block: nil, #
                ZipCode: "410209", #Company zipcode
                City: "Navi Mumbai", #Company CIty
                County: nil, #
                Country: "IN", #Company Country
                State: "MH", #Company State
                BuildingFloorRoom: nil, #
                AddressType: "bo_BillTo", #
                AddressName2: nil, #address
                AddressName3: nil, #address
                StreetNo: nil, #
                GSTIN: "27AADFU8382N1ZD", #Company GST#
                GstType: "gstRegularTDSISD", #
                U_VAT: "", #Company VAT#
                U_CST: "" #Company  CST#
            },
            {
                AddressName: "4159", #Company Billing Address
                Street: "Office No.1, Shree Sai CHS., Plot No.20, Sector No.20, Kamothe,", #address
                Block: nil, #
                ZipCode: "410209", #Company zipcode
                City: "Navi Mumbai", #Company CIty
                County: nil, #
                Country: "IN", #Company Country
                State: "MH", #Company State
                BuildingFloorRoom: nil, #
                AddressType: "bo_ShipTo", #
                AddressName2: nil, #address
                AddressName3: nil, #address
                StreetNo: nil, #
                GSTIN: "27AADFU8382N1ZD", #Company GST#
                GstType: "gstRegularTDSISD", #
                U_VAT: nil, #Company VAT#
                U_CST: nil #Company  CST#
            }
        ]


[
            {
                Address: "", #Address
                TaxId0: "AADFU8382N", #Company PAN#
                TaxId3: nil, #Company Service Tax
                TaxId4: nil, #Central Excise No.
                TaxId5: nil, #
                TaxId6: nil, #TAN
                TaxId7: nil, #
                TaxId8: nil, #company_type
                TaxId9: "dealer", #nature_of_business
                TaxId10: nil, #
                TaxId11: nil, #Company VAT
            },
            {
                Address: "4159", #
                TaxId0: "AADFU8382N", #Company PAN#
                TaxId3: nil, #Company Service Tax
                TaxId4: nil, #Central Excise No.
                TaxId5: nil, #
                TaxId6: nil, #TAN
                TaxId7: nil, #
                TaxId8: nil, #company_type
                TaxId9: "dealer", #nature_of_business
                TaxId10: nil, #
                TaxId11: nil, #Company VAT
            },
            {
                Address: "4159", #
                TaxId0: "AADFU8382N", #Company PAN#
                TaxId3: nil, #Company Service Tax
                TaxId4: nil, #Central Excise No.
                TaxId5: nil, #
                TaxId6: nil, #TAN
                TaxId7: nil, #
                TaxId8: nil, #company_type
                TaxId9: "dealer", #nature_of_business
                TaxId10: nil, #
                TaxId11: nil, #Company VAT
            }
        ]



JSON DUMP [2]


    [
            {
                CardCode: "cs15446992",#"SC-7419", #CardCode
 "cs15446992",#               Name: "B.S. GAUTAM-849", #
                Position: nil, #Position
                Address: nil, #Address
                Phone1: nil, #Contact Person Phone
                Phone2: nil, #
                MobilePhone: "9029482674", #Contact Person Phone
                E_Mail: "sales@universalflowtech.com", #Contact Person EMail
                Remarks1: "", #Customer Line Manager
                DateOfBirth: nil, #Date of Birth
                Gender: "gt_Undefined", #Gender
                Title: nil, #Prefix (Mr / Mrs / Ms)
                FirstName: "B.S.", #Contact Person First Name
                MiddleName: nil, #Contact Person Middle Name
                LastName: "GAUTAM", #Contact Person Last Name
            }
        ]


=end
