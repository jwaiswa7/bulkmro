class Resources::BusinessPartner < Resources::ApplicationResource

  def self.identifier
    :CardCode
  end

  def self.create(record)
    id = super(record) do |response|
      # persist company.remote_uid because find_by won't work in update_associated
      record.save!

      # persist address.remote_uid because find_by won't work in update_associated
      record.addresses.each do |address|
        address.save!
      end

      update_associated_records(response)
    end

    id
  end

  def self.update(id, record)
    update_associated_records(id, force_find: true)

    super(id, record, quotes: true) do |response|
      update_associated_records(id, force_find: true) if response.present?
    end
  end

  def self.custom_find(company_name, company_type)
    encoded_url = URI.encode("/#{collection_name}?$filter=CardName eq '#{company_name}' and CardType eq '#{company_type}'")
    response = get(encoded_url)

    log_request(:get, company_name, is_find: true)
    validated_response = get_validated_response(response)
    log_response(validated_response)

    if validated_response['value'].present?
      remote_record = validated_response['value'][0]
      yield remote_record if block_given?
      remote_record[self.identifier.to_s]
    end
  end

  def self.update_associated_records(response, force_find: false)

    response = find(response, quotes: true) if force_find
    return if response.blank?

    company = Company.find_by_remote_uid!(response['CardCode'])
    addresses = response['BPAddresses']
    contacts = response['ContactEmployees']
    banks  = response['BPBankAccounts']

    addresses.each do |address|
      address_to_update = company.addresses.find_by_remote_uid(address["AddressName"])
      if address_to_update.blank?

        address_to_update = company.addresses.where(remote_uid: address['AddressName']).first_or_initialize do |new_address|
          new_address.assign_attributes(
              legacy_id: address['AddressName'],
              name: company.name,
              street1: address['Street'].present? ? address['Street'] : nil,
              city_name: address['City'].present? ? address['City'] : nil,
              street2: address['AddressName2'].present? ? address['AddressName2'] : nil,
              country_code: address['Country'].present? ? address['Country'] : 'IN',
              state_name: address['State'].present? ? AddressState.where(:region_code => address['State'],:country_code => address['Country']).first.name : nil,
              address_state_id: address['State'].present? ? AddressState.where(:region_code => address['State'],:country_code => address['Country']).first.id : nil,
              pincode: address['ZipCode'].present? ? address['ZipCode'] : nil,
              gst: address['GSTIN'].present? ? address['GSTIN'] : nil,
              vat: address['U_VAT'].present? ? address['U_VAT'] : nil,
              cst: address['U_CST'].present? ? address['U_CST'] : nil
          )
        end
        address_to_update.save

      end

      if address['AddressType'].eql? "bo_BillTo"
        address_to_update.update_attribute(:billing_address_uid, address['RowNum'])
      elsif address['AddressType'].eql? "bo_ShipTo"
        address_to_update.update_attribute(:shipping_address_uid, address['RowNum'])
      end

    end if addresses.present?

    contacts.each do |contact|
      remote_uid = contact["InternalCode"]
      contact_email = contact["E_Mail"].to_s.strip.downcase
      existing_contact = Contact.find_by_email(contact_email)

      if existing_contact.blank?
        assigned_email = contact_email
      elsif existing_contact.present? && company.account == existing_contact.account
        assigned_email = contact_email
      elsif existing_contact.present? && company.account != existing_contact.account
        assigned_email = [contact_email.split('@', 2)[0], '_duplicate', '@', contact_email.split('@', 2)[1]].join('')
      end

      assigned_contact = Contact.where(:email => assigned_email).first_or_create! do |new_contact|
        new_contact.update_attributes(
            :account => company.account,
            :first_name => contact['FirstName'],
            :last_name => contact['LastName'],
            :telephone => contact['Phone1'],
            :mobile => contact['MobilePhone'],
            :email => assigned_email
        )
      end
      company.company_contacts.where(:remote_uid => remote_uid, :contact => assigned_contact).first_or_create!

      banks.each do |bank|
        account_number= bank["AccountNo"]
        remote_uid = bank["InternalKey"]
        company_bank = CompanyBank.find_by_account_number(account_number)
        company_bank.update_attributes(:remote_uid => remote_uid) if company_bank .present?
      end if banks.present?
    end
  end

  def self.to_remote(record)
    addresses = []
    contacts = []
    bp_tax_collection = []
    banks = []

    if record.remote_uid.blank?
      record.assign_attributes(:remote_uid => Services::Resources::Shared::UidGenerator.company_uid(record))
    end

    record.addresses.each do |address|
      address.assign_attributes(:remote_uid => Services::Resources::Shared::UidGenerator.address_uid(address)) if address.remote_uid.blank?

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

      if address.gst.present? && address.gst.to_s != "No GST Number"
        address_row.GSTIN = address.gst
        address_row.GstType = "gstRegularTDSISD"
      end

      address_row.U_VAT = address.vat
      address_row.U_CST = address.cst

      if !address.billing_address_uid.blank?
        address_row.RowNum = address.billing_address_uid
      end
      addresses.push(address_row.marshal_dump)

      # Second Entry for Shipping Address
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
      address_row.AddressType = "bo_ShipTo"
      address_row.AddressName2 = address_name2
      address_row.AddressName3 = address_name3
      address_row.StreetNo = nil

      if address.gst.present? && address.gst.to_s != "No GST Number"
        address_row.GSTIN = address.gst
        address_row.GstType = "gstRegularTDSISD"
      end

      address_row.U_VAT = address.vat
      address_row.U_CST = address.cst

      if !address.shipping_address_uid.blank?
        address_row.RowNum = address.shipping_address_uid
      end

      addresses.push(address_row.marshal_dump)

      # BPFiscalTaxIDCollection Start

      # Push as billing
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

      bp_tax_collection.push(bp_tax_collection_row.marshal_dump)

      #Push as shipping
      bp_tax_collection_row = OpenStruct.new

      #Address Level tax Info
      bp_tax_collection_row.Address = address.remote_uid
      bp_tax_collection_row.AddrType = "bo_ShipTo"
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

      bp_tax_collection.push(bp_tax_collection_row.marshal_dump)

      # BPFiscalTaxIDCollection End

      #Extra as per SAP
      # address_tax_row = OpenStruct.new
      # address_tax_row.Address = address.remote_uid
      # address_tax_row.TaxId0 = record.try(:pan) || "ABCDE1234F"
      # address_tax_row.TaxId3 = address.cst
      # address_tax_row.TaxId4 = address.excise
      # address_tax_row.TaxId5 = nil
      # address_tax_row.TaxId6 = record.try(:tan)
      # address_tax_row.TaxId7 = nil
      # address_tax_row.TaxId8 = nil
      # address_tax_row.TaxId9 = record.nature_of_business
      # address_tax_row.TaxId10 = nil
      # address_tax_row.TaxId11 = address.vat
      #
      # bp_tax_collection.push(address_tax_row.marshal_dump)
    end if record.remote_uid.present?

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
      contact_row.Name = [contact.full_name, contact.id, record.id].join("-")
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

      if company_contact.remote_uid.present?
        contact_row.InternalCode = company_contact.remote_uid
      end

      contacts.push(contact_row.marshal_dump)
    end if record.remote_uid.present?

    record.company_banks.each do |company_bank|

      bank_row = OpenStruct.new
      bank_row.BPCode = record.remote_uid
      bank_row.AccountNo = company_bank.account_number
      bank_row.AccountName = company_bank.account_name
      bank_row.Branch = company_bank.branch
      bank_row.MandateID = company_bank.mandate_id
      bank_row.BankCode = company_bank.bank.code

      if company_bank.remote_uid.present?
        bank_row.InternalKey = company_bank.remote_uid
      end

      banks.push(bank_row.marshal_dump)
    end if record.remote_uid.present?

    params = {
        CardCode: record.remote_uid,
        CardName: record.name,
        CardType: record.is_supplier? ? "cSupplier" : "cCustomer",
        GroupCode: record.account.remote_uid,
        #Address: record.default_billing_address.present? ? record.default_billing_address.to_s : nil,
        ZipCode: record.default_billing_address.present? ? record.default_billing_address.pincode : nil,
        Country: record.default_billing_address.present? ? record.default_billing_address.country_code : nil,
        EmailAddress: record.default_company_contact.present? ? record.default_company_contact.contact.email : nil,
        BillToState: record.default_billing_address.present? ? record.default_billing_address.state.try(:region_code_uid) : nil,
        City: record.default_billing_address.present? ? record.default_billing_address.city_name : nil,
        ContactPerson: record.default_company_contact.present? ? record.default_company_contact.contact.full_name : nil,
        OwnerCode: record.outside_sales_owner_id.present? ? record.outside_sales_owner.employee_uid : nil,
        Phone1: record.phone,
        Phone2: nil,
        Fax: nil,
        PayTermsGrpCode: record.default_payment_option_id.present? ? record.default_payment_option.remote_uid : nil,
        CreditLimit: record.credit_limit,
        SalesPersonCode: record.inside_sales_owner_id.present? ? record.inside_sales_owner.salesperson_uid : nil,
        Currency: "##",
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
        BPBankAccounts: banks,
        BPFiscalTaxIDCollection: bp_tax_collection,
        UseBillToAddrToDetermineTax: "tYES"
    }

    params.compact
  end
end