require 'csv'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  attr_accessor :limit

  def initialize

    @limit = nil

    perform_migration(:overseers)
    perform_migration(:measurement_unit)
    perform_migration(:lead_time_option)
    perform_migration(:currencies)
    perform_migration(:states)
    perform_migration(:payment_options)
    perform_migration(:industries)
    perform_migration(:accounts_acting_as_customers)
    perform_migration(:contacts)
    perform_migration(:companies_acting_as_customers)
    perform_migration(:company_contacts)
    perform_migration(:addresses)
    perform_migration(:accounts_acting_as_suppliers)
    perform_migration(:companies_acting_as_suppliers)
    perform_migration(:supplier_contacts)
    perform_migration(:supplier_addresses)
    perform_migration(:brands)
    perform_migration(:tax_codes)
    perform_migration(:categories)
    perform_migration(:products)
    perform_migration(:inquiries)
    perform_migration(:inquiry_details)
    perform_migration(:sales_order_drafts)
    perform_migration(:inquiry_attachments)

  end

  def perform_migration(name)
    puts "Creating #{name.to_s.pluralize}"
    send name
    puts "Done creating #{name.to_s.pluralize}"
  end

  def generate_csv(array_of_ids, object_type)
    file = "#{Rails.root}/public/#{object_type}_data.csv"
    column_headers = ["ID"]
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      array_of_ids.each do |i|
        writer << [i]
      end
    end
  end

  def overseers
    errors = []
    Overseer.create!(
        :first_name => 'Ashwin',
        :last_name => 'Goyal',
        :email => 'ashwin.goyal@bulkmro.com',
        :username => 'ashwin.goyal',
        :password => 'abc123',
        :password_confirmation => 'abc123'
    )

    service = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv')
    service.loop(limit) do |x|
      begin
        Overseer.where(email: x.get_column('email').strip.downcase).first_or_create! do |overseer|
          overseer.assign_attributes(
              first_name: x.get_column('firstname'),
              last_name: x.get_column('lastname'),
              username: x.get_column('username'),
              mobile: x.get_column('mobile'),
              designation: x.get_column('designation'),
              identifier: x.get_column('identifier'),
              geography: x.get_column('geography'),
              salesperson_uid: x.get_column('sap_internal_code'),
              employee_uid: x.get_column('employee_id'),
              # center_code_uid: x.get_column('center_code'),
              password: 'abc123',
              password_confirmation: 'abc123'
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('email')}")
      end
    end
    generate_csv(errors, "overseers")
  end


  def measurement_unit
    MeasurementUnit.create!([
                                {name: 'EA'},
                                {name: 'SET'},
                                {name: 'PK'},
                                {name: 'KG'},
                                {name: 'M'},
                                {name: 'FT'},
                                {name: 'Pair'},
                                {name: 'PR'},
                                {name: 'BOX'},
                                {name: 'LTR'},
                                {name: 'LT'},
                                {name: 'MTR'},
                                {name: 'ROLL'},
                                {name: 'Nos'},
                                {name: 'PKT'},
                                {name: 'REEL'},
                                {name: 'FEET'},
                                {name: 'Meter'},
                                {name: '1 ROLL'},
                                {name: 'ml'},
                                {name: 'MAT'},
                                {name: 'LOT'},
                                {name: 'No'},
                                {name: 'RFT'},
                                {name: 'Bundle'},
                                {name: 'NPkt'},
                                {name: 'Metre'},
                                {name: 'CAN'},
                                {name: 'SQ.Ft'},
                                {name: 'BOTTLE'},
                                {name: 'BOTTEL'},
                                {name: 'CUBIC METER'},
                                {name: 'PC'},
                            ])
  end


  def lead_time_option
    LeadTimeOption.create!([
                               {name: "2-3 DAYS", min_days: 2, max_days: 3},
                               {name: "1 WEEK", min_days: 7, max_days: 7},
                               {name: "8-10 DAYS", min_days: 8, max_days: 10},
                               {name: "1-2 WEEKS", min_days: 7, max_days: 14},
                               {name: "2 WEEKS", min_days: 14, max_days: 14},
                               {name: "2-3 WEEK", min_days: 14, max_days: 21},
                               {name: "3 WEEKS", min_days: 21, max_days: 21},
                               {name: "3-4 WEEKS", min_days: 21, max_days: 28},
                               {name: "4 WEEKS", min_days: 28, max_days: 28},
                               {name: "5 WEEKS", min_days: 35, max_days: 35},
                               {name: "4-6 WEEKS", min_days: 28, max_days: 42},
                               {name: "6-8 WEEKS", min_days: 42, max_days: 56},
                               {name: "8 WEEKS", min_days: 56, max_days: 56},
                               {name: "6-10 WEEKS", min_days: 42, max_days: 70},
                               {name: "10-12 WEEKS", min_days: 70, max_days: 84},
                               {name: "12-14 WEEKS", min_days: 84, max_days: 98},
                               {name: "14-16 WEEKS", min_days: 98, max_days: 112},
                               {name: "MORE THAN 14 WEEKS", min_days: 98, max_days: nil},
                               {name: "60 days from the date of order for 175MT, and 60 days for remaining from the date of call", min_days: 60, max_days: 120}
                           ])
  end

  def currencies
    Currency.create!([
                         {name: 'USD', conversion_rate: 71.59},
                         {name: 'INR', conversion_rate: 1},
                         {name: 'EUR', conversion_rate: 83.85},
                     ])
  end

  def states
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv')
    service.loop(limit) do |x|
      begin
        if x.get_column('default_name').present? && x.get_column('code').present? && x.get_column('region_id').present?
          # puts x.get_column('default_name')
          AddressState.where(name: x.get_column('default_name').strip).first_or_create! do |state|
            state.assign_attributes(
                country_code: x.get_column('country_id'),
                region_code: x.get_column('code'),
                region_code_uid: x.get_column('sap_code'),
                remote_uid: x.get_column('gst_state_code') == 'NULL' ? nil : x.get_column('gst_state_code'),
                legacy_id: x.get_column('region_id'),
            )
          end
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('default_name')}")
      end
    end
    generate_csv(errors, "states")
  end

  def payment_options
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
    service.loop(limit) do |x|
      begin
        if x.get_column('value').present? && x.get_column('group_code').present?
          group_code = x.get_column('group_code')
          PaymentOption.where(name: x.get_column('value')).first_or_create! do |payment_option|
            payment_option.assign_attributes(
                remote_uid: (group_code.blank? || group_code == 0 || group_code == '0') ? nil : group_code,
                legacy_id: x.get_column('id')
            )
          end
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('value')}")
      end
    end
    generate_csv(errors, "payment_options")
  end

  def industries
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('industries.csv')
    service.loop(limit) do |x|
      begin
        i = Industry.create!(
            remote_uid: x.get_column('industry_sap_id'),
            name: x.get_column('industry_name'),
            description: x.get_column('industry_description'),
            legacy_id: x.get_column('idindustry')
        )
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('industry_sap_id')}")
      end
    end
    generate_csv(errors, "industries")
  end

  def accounts_acting_as_customers
    errors = []
    Account.create!(remote_uid: 99999999, name: "Fake Account", alias: "FA")
    service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')

    service.loop(limit) do |x|
      begin
        #create account alias
        account_name = x.get_column('aliasname')
        aliasname = x.get_column('aliasname')
        remote_uid = x.get_column('sap_id')
        Account.where(name: account_name).first_or_create! do |accounts|
          accounts.remote_uid = remote_uid
          accounts.name = account_name
          accounts.alias = account_name.titlecase.split.map(&:first).join
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('sap_id')}")
      end
    end
    generate_csv(errors, "account_acting_as_customer")
  end

  def contacts
    errors = []
    fake_account = Account.find_by_name("Fake Account")
    fake_contact = Contact.create!(account: fake_account, remote_uid: 99999999, email: "fake@bulkmro.com", first_name: "Fake", last_name: "Name", telephone: "9999999999", password: 'abc123', password_confirmation: 'abc123')
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')
    is_active = [20, 10]
    contact_group = {"General" => 10, "Company Top Manager" => 20, "retailer" => 30, "ador" => 40, "vmi_group" => 50, "C-Form customer GROUP" => 60, "Manager" => 70}

    service.loop(limit) do |x|
      if x.get_column('aliasname').present?
        account = Account.find_by_name(x.get_column('aliasname'))
      else
        account = fake_account
      end

      begin
        Contact.where(email: x.get_column('email').strip.downcase).first_or_create! do |contact|
          contact.assign_attributes(
              account: account,
              remote_uid: (x.get_column('sap_id') == "NULL" ? nil : x.get_column('sap_id')),
              first_name: x.get_column('firstname') || 'fname',
              last_name: x.get_column('lastname'),
              prefix: x.get_column('prefix'),
              designation: x.get_column('designation'),
              telephone: x.get_column('telephone'),
              #role: x.get_column('account'),
              status: is_active[x.get_column('is_active').to_i],
              contact_group: contact_group[x.get_column('group')],
              password: 'abc123',
              password_confirmation: 'abc123',
              legacy_id: x.get_column('entity_id')
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('email')}")
      end
    end
    generate_csv(errors, "contacts")
  end

  def companies_acting_as_customers
    errors = []
    fake_account = Account.find_by_name("Fake Account")
    fake_contact = Contact.find_by_email("fake@bulkmro.com")
    fake_company = Company.create!(name: "Fake Company", account: fake_account, remote_uid: 99999999, default_payment_option_id: nil, inside_sales_owner_id: nil)
    fake_company.assign_attributes(default_company_contact: CompanyContact.create!(company: fake_company, contact: fake_account.contacts.first))
    service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv')
    service.loop(limit) do |x|
      begin
        if x.get_column('aliasname').present?
          account = Account.find_by_name(x.get_column('aliasname'))
        else
          account = fake_account
        end

        return if account.blank?

        company_type = {"Proprietorship" => 10, "Private Limited" => 20, "Contractor" => 30, "Trust" => 40, "Public Limited" => 50}
        priority = [10, 20]
        nature_of_business = {"Trading" => 10, "Manufacturer" => 20, "Dealer" => 30}
        is_msme = {"N" => false, "Y" => true}
        urd = {"N" => false, "Y" => true}
        if (x.get_column('cmp_name') != nil)
          Company.where(name: x.get_column('cmp_name')).first_or_create! do |company|

            inside_email = Overseer.find_by_email(x.get_column('inside_sales_email'))
            outside_email = Overseer.find_by_email(x.get_column('outside_sales_email'))
            manager_email = Overseer.find_by_email(x.get_column('manager_email'))
            payment_option = PaymentOption.find_by_name(x.get_column('default_payment_term'))
            industry = Industry.find_by_name(x.get_column('cmp_industry'))

            company.assign_attributes(
                account: account,
                industry: industry.present? ? industry : nil,
                remote_uid: x.get_column('cmp_id'),
                default_payment_option_id: payment_option.present? ? payment_option.id : nil,
                # default_billing_address_id: company.account.addresses.find_by_id(x.get_column('default_billing')),
                # default_shipping_address_id: company.account.addresses.find_by_id(x.get_column('default_shipping')),
                inside_sales_owner_id: inside_email.present? ? inside_email.id : nil,
                outside_sales_owner_id: outside_email.present? ? outside_email.id : nil,
                sales_manager_id: manager_email.present? ? manager_email.id : nil,
                site: x.get_column('cmp_website'),
                company_type: company_type[x.get_column('company_type')],
                priority: priority[x.get_column('is_strategic').to_i],
                nature_of_business: nature_of_business[x.get_column('nature_of_business')],
                credit_limit: x.get_column('creditlimit').present? && x.get_column('creditlimit').to_i > 0 ? x.get_column('creditlimit') : 1,
                is_msme: is_msme[x.get_column('msme')],
                is_unregistered_dealer: urd[x.get_column('urd')],
                tax_identifier: x.get_column('cmp_gst'),
                is_customer: true,
                attachment_uid: x.get_column('attachment_entry'),
                legacy_id: x.get_column('cmp_id'),
                pan: (x.get_column('cmp_pan') if x.get_column('cmp_pan') != 'NULL'),
                tan: (x.get_column('cmp_tan') if x.get_column('cmp_tan') != 'NULL')
            )


            company.assign_attributes(default_company_contact: CompanyContact.new(company: company, contact: account.contacts.find_by_email(x.get_column('email').strip.downcase))) if x.get_column('email').present?

          end
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('cmp_name')}")
      end
    end
    generate_csv(errors, "companies_acting_as_customers")
  end

  def company_contacts
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contact_mapping.csv')
    service.loop(limit) do |x|
      begin
        if x.get_column('email').present? && x.get_column('cmp_name').present?
          company_name = x.get_column('cmp_name')

          CompanyContact.find_or_create_by(
              company: Company.find_by_name(company_name),
              contact: Contact.find_by_email(x.get_column('email').strip.downcase)
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('email')}")
      end
    end
    generate_csv(errors, "company_contacts")
  end

  def addresses
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv')
    gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    fake_company = Company.find_by_name("Fake Company")
    fake_company.addresses.create!(
        company: fake_company,
        name: fake_company.name,
        gst: '2AAAAAAAAAAAAAA',
        country_code: "IN",
        state: AddressState.find_by_name('Maharashtra'),
        state_name: nil,
        city_name: "Mumbai",
        pincode: "400001",
        street1: "LowerParel"
    )

    service.loop(limit) do |x|
      begin
        company = Company.find_by_name(x.get_column('cmp_name'))

        if company.present?

          address = Address.new(
              company: company,
              name: company.name,
              gst: x.get_column('gst_num'),
              country_code: x.get_column('country'),
              state: AddressState.find_by_name(x.get_column('state_name')),
              state_name: x.get_column('country') != "IN" ? x.get_column('state_name') : nil,
              city_name: x.get_column('city'),
              pincode: x.get_column('pincode'),
              street1: x.get_column('address'),
              #street2:x.get_column('gst_num'),
              cst: x.get_column('cst_num'),
              vat: x.get_column('vat_num'),
              excise: x.get_column('ed_num'),
              telephone: x.get_column('telephone'),
              #mobile:x.get_column('gst_num'),
              gst_type: gst_type[x.get_column('gst_type')],
              legacy_id: x.get_column('idcompany_gstinfo')
          )

          address.assign_attributes(
              billing_address_uid: x.get_column('sap_row_num').split(',')[0],
              shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
          ) if x.get_column('sap_row_num').present?

          address.save!
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('cmp_id')}")
      end
    end
    generate_csv(errors, "addresses")
  end

  def accounts_acting_as_suppliers
    Account.create!(
        remote_uid: 101,
        name: "Trade",
        alias: "TRD"
    )

    Account.create!(
        remote_uid: 102,
        name: "Non-Trade",
        alias: "NTRD"
    )
  end

  def companies_acting_as_suppliers
    errors = []
    supplier_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers.csv')
    supplier_service.loop(limit) do |x|
      if x.get_column('alias_id')
        account = Account.find_by_remote_uid(102) #Non-Trade
      else
        account = Account.find_by_remote_uid(101) #Trade
      end

      return if account.blank?

      company_type = {"Proprietorship" => 10, "Private Limited" => 20, "Contractor" => 30, "Trust" => 40, "Public Limited" => 50, "dealer_company" => 50, "distributor" => 60, "trader" => 70, "manufacturer_company" => 80, "wholesaler_stockist" => 90, "serviceprovider" => 100, "employee" => 110}

      is_msme = {"N" => false, "Y" => true}
      urd = {"N" => false, "Y" => true}

      begin
        Company.where(remote_uid: x.get_column('sup_code').strip).first_or_create! do |company|

          inside_email = Overseer.find_by_email(x.get_column('sup_sales_person'))
          outside_email = Overseer.find_by_email(x.get_column('sup_sales_outside'))
          manager_email = Overseer.find_by_email(x.get_column('sup_sales_manager'))
          payment_option = PaymentOption.find_by_name(x.get_column('payment_terms'))
          #industry = Industry.find_by_name(x.get_column('cmp_industry'))
          company.assign_attributes(
              account: account,
              name: x.get_column('sup_name'),
              default_payment_option_id: payment_option.present? ? payment_option.id : nil,
              inside_sales_owner_id: inside_email.present? ? inside_email.id : nil,
              outside_sales_owner_id: outside_email.present? ? outside_email.id : nil,
              sales_manager_id: manager_email.present? ? manager_email.id : nil,
              site: x.get_column('cmp_website'),
              company_type: company_type[x.get_column('sup_type')],
              credit_limit: x.get_column('creditlimit').present? && x.get_column('creditlimit').to_i > 0 ? x.get_column('creditlimit') : 1,
              is_msme: is_msme[x.get_column('msme')],
              is_unregistered_dealer: urd[x.get_column('urd')],
              tax_identifier: x.get_column('cmp_gst'),
              is_supplier: true,
              legacy_id: x.get_column('sup_id'),
              pan: (x.get_column('cmp_pan') if x.get_column('sup_pan') != 'NULL'),
          #tan: ( x.get_column('cmp_tan') if x.get_column('cmp_tan') != 'NULL' )
          #phone: x.get_column('sup_tel'),
          #mobile: x.get_column('sup_mob'),
          #remote_attachment_id: x.get_column('attachment_entry')
          # default_billing_address_id: company.account.addresses.find_by_id(x.get_column('default_billing')),
          # default_shipping_address_id: company.account.addresses.find_by_id(x.get_column('default_shipping')),
          #industry: industry.present? ? industry : nil
          #priority: priority[x.get_column('is_strategic').to_i],
          #nature_of_business: nature_of_business[x.get_column('nature_of_business')]
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('sup_code')}")
      end

    end
    generate_csv(errors, "companies_acting_as_supplier")
  end

  def supplier_contacts
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('supplier_contacts.csv')

    service.loop(limit) do |x|
      if x.get_column('alias_id')
        account = Account.find_by_remote_uid("102") #Non-Trade
      else
        account = Account.find_by_remote_uid("101") #Trade
      end

      begin

        if x.get_column('pc_email').present?
          Contact.where(email: x.get_column('pc_email').strip.downcase).first_or_create! do |contact|
            contact.assign_attributes(
                account: account,
                remote_uid: (x.get_column('sap_id') == "NULL" ? nil : x.get_column('sap_id')),
                first_name: x.get_column('pc_firstname') || 'fname',
                last_name: x.get_column('pc_lastname') || 'lname',
                prefix: x.get_column('prefix'),
                designation: x.get_column('pc_function'),
                telephone: x.get_column('pc_phone'),
                mobile: x.get_column('pc_mobile'),
                #role: x.get_column('account'),
                status: 10,
                #contact_group: contact_group[x.get_column('group')],
                password: 'abc123',
                password_confirmation: 'abc123',
                legacy_id: x.get_column('pc_num')
            )
          end
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('pc_email')}")
      end
    end
    generate_csv(errors, "supplier_contacts")
  end

  def supplier_addresses
    errors = []
    supplier_address_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers_address.csv')
    gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    supplier_address_service.loop(limit) do |x|
      begin
        company = Company.find_by_name(x.get_column('cmp_name'))

        if company.present?
          address = Address.new(
              company: company,
              name: company.name,
              gst: x.get_column('gst_num'),
              country_code: x.get_column('country'),
              state: AddressState.find_by_name(x.get_column('state_name')),
              state_name: x.get_column('country') != "IN" ? x.get_column('state_name') : nil,
              city_name: x.get_column('city'),
              pincode: x.get_column('pincode'),
              street1: x.get_column('address'),
              #street2:x.get_column('gst_num'),
              cst: (x.get_column('cst_num') if (x.get_column('cst_num') != 'NULL' && x.get_column('cst_num') != nil)),
              vat: (x.get_column('vat_num') if (x.get_column('vat_num') != 'NULL' && x.get_column('vat_num') != nil)),
              excise: (x.get_column('ed_num') if (x.get_column('ed_num') != 'NULL' && x.get_column('ed_num') != nil)),
              telephone: x.get_column('telephone'),
              #mobile:x.get_column('gst_num'),
              gst_type: gst_type[x.get_column('gst_type')],
              legacy_id: x.get_column('address_id')
          )

          address.assign_attributes(
              billing_address_uid: x.get_column('sap_row_num').split(',')[0],
              shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
          ) if x.get_column('sap_row_num').present?

          address.save!
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('address_id')}")
      end
    end
    generate_csv(errors, "supplier_address")
  end

  def brands
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
    service.loop(limit) do |x|
      begin
        Brand.where(name: x.get_column('value')).first_or_create! do |brand|
          brand.legacy_id = x.get_column('option_id')
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('option_id')}")
      end
    end
    generate_csv(errors, "brands")
  end

  def tax_codes
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('hsn_codes.csv')
    service.loop(limit) do |x|
      begin
        # puts "#{x.get_column('idbmro_sap_hsn_mapping')}"
        # puts "#{x.get_column('hsn')}"
        if (x.get_column('chapter') != "NULL" && x.get_column('tax_code') != nil)
          TaxCode.where(chapter: x.get_column('chapter')).first_or_create!(
              remote_uid: x.get_column('internal_key'),
              code: ((x.get_column('hsn') == "NULL") || (x.get_column('hsn') == nil) ? x.get_column('chapter') : x.get_column('hsn').gsub('.', '')),
              description: x.get_column('description'),
              is_service: x.get_column('is_service') == 'NULL' ? false : true,
              tax_percentage: x.get_column('tax_code').match(/\d+/)[0].to_f
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('chapter')}")
      end
    end
    generate_csv(errors, "tax_codes")
  end

  def categories
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('categories.csv')
    service.loop(limit) do |x|
      begin
        if (x.get_column('id') != "1" && x.get_column('id') != "2")
          # puts "#{x.get_column('id')}"
          tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code')) if (x.get_column('hsn_code').present?)
          parent = Category.find_by_remote_uid(x.get_column('parent_id')) if (x.get_column('parent_id') != "2" && x.get_column('parent_id') != nil)
          Category.create!(
              remote_uid: x.get_column('id'),
              tax_code_id: (tax_code.present? ? tax_code.id : TaxCode.default.id),
              parent_id: (parent.present? ? parent.id : nil),
              name: x.get_column('name'),
              description: x.get_column('description'),
              legacy_id: x.get_column('id')
          )
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('id')}")
      end
    end
    generate_csv(errors, "categories")
  end

  def products
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    service.loop(limit) do |x|
      begin
        # puts "#{x.get_column('entity_id')}"
        brand = Brand.find_by_name(x.get_column('product_brand'))
        product = Product.create!(
            name: x.get_column('name'),
            brand: (brand if (brand.present?)),
            category: Category.default,
            sku: x.get_column('sku'),
            description: x.get_column('description'),
            meta_description: x.get_column('meta_description'),
            meta_keyword: x.get_column('meta_keyword'),
            meta_title: x.get_column('meta_title'),
            legacy_id: x.get_column('entity_id')
        )

        overseer = Overseer.find_by_email('ashwin.goyal@bulkmro.com')
        product.create_approval(:comment => product.comments.create!(:overseer => overseer, message: 'Legacy product, being preapproved'), :overseer => overseer)
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('entity_id')}")
      end
    end
    generate_csv(errors, "products")
  end

  def inquiries
    errors = []

    fake_company = Company.find_by_name("Fake Company")

    opportunity_type = {"amazon" => 10, "rate_contract" => 20, "financing" => 30, "regular" => 40, "service" => 50, "repeat" => 60, "route_through" => 70, "tender" => 80}
    opportunity_source = {"meeting" => 10, "phone_call" => 20, "email" => 30, "quote_tender_prep" => 40}
    quote_category = {"bmro" => 10, "ong" => 20}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries.csv')
    service.loop(limit) do |x|
      begin

        company = Company.find_by_remote_uid(x.get_column('customer_company'))
        company = company.present? ? company : fake_company

        if (x.get_column('email').present? && x.get_column('email') != "NULL")
          contact = Contact.find_by_email(x.get_column('email').downcase)
          if contact.present?
            comp_contact = company.contacts.find_by_email(x.get_column('email').downcase)
            if comp_contact.present?
              contact = comp_contact
            else
              CompanyContact.create!(company: company, contact: contact)
            end
          else
            contact = fake_company.contacts.first
          end
        else
          contact = company.contacts.first
        end

        if !company.industry.present?
          if (x.get_column('industry_sap_id') != "NULL" && x.get_column('industry_sap_id') != nil)
            industry = Industry.find_by_remote_uid(x.get_column('industry_sap_id'))
            company.update_attribute(:industry, industry) if industry.present?
          end
        end

        inquiry = Inquiry.create!(
            inquiry_number: x.get_column('increment_id'),
            company: company,
            contact: contact,
            status: x.get_column('bought').to_i,
            opportunity_type: (opportunity_type[x.get_column('quote_type').gsub(" ", "_")] if x.get_column('quote_type').present?),
            potential_amount: x.get_column('potential_amount'),
            opportunity_source: (opportunity_source[x.get_column('opportunity_source').downcase] if x.get_column('opportunity_source').present?),
            subject: x.get_column('caption'),
            gross_profit_percentage: x.get_column('grossprofitp'),
            inside_sales_owner: Overseer.find_by_username(x.get_column('manager')),
            outside_sales_owner: Overseer.find_by_username(x.get_column('outside')),
            sales_manager: Overseer.find_by_username(x.get_column('powermanager')),
            quote_category: (quote_category[x.get_column('category').downcase] if x.get_column('category').present?),
            billing_address: (company.addresses.find_by_legacy_id(x.get_column('billing_address')).present? ? company.addresses.find_by_legacy_id(x.get_column('billing_address')) : company.addresses.first),
            shipping_address: (company.addresses.find_by_legacy_id(x.get_column('shipping_address')).present? ? company.addresses.find_by_legacy_id(x.get_column('shipping_address')) : company.addresses.first),
            #billing_address: company.addresses.find_by_,
            created_at: x.get_column('created_time').to_datetime,
            opportunity_uid: x.get_column('op_code'),
            customer_po_number: x.get_column('customer_po_id'),
            customer_po_sheet: x.get_column('additional_pdf1'),
            calculation_sheet: x.get_column('additional_pdf'),
            email_attachment: x.get_column('email_attachment'),
            supplier_quote_attachment: x.get_column('supplier_quote_attachment'),
            supplier_quote_attachment_additional: x.get_column('final_sup_quote_attachment'),
            shipping_company: Company.find_by_remote_uid(x.get_column('customer_shipping_company')),
            #bill_from_warehouse: x.get_column('warehouse'),
            #ship_from_warehouse: x.get_column('ship_from_warehouse'),
            bill_to_name: Contact.find_by_legacy_id(x.get_column('billing_name')),
            #billing_address_id: x.get_column('billing_address'),
            #shipping_address_id: x.get_column('shipping_address'),
            #inside_sales_owner_id: x.get_column('manager'),
            #outside_sales_owner_id: x.get_column('outside'),
            sales_manager_id: x.get_column('powermanager'),
            attachment_uid: x.get_column('attachment_entry'),
            legacy_id: x.get_column('quotation_id'),
            priority: x.get_column('is_prioritized'),
            expected_closing_date: x.get_column('closing_date'),
            quotation_date: x.get_column('quotation_date'),
            quotation_expected_date: x.get_column('quotation_expected_date'),
            valid_end_time: x.get_column('valid_end_time'),
            quotation_followup_date: x.get_column('quotation_followup_date'),
            customer_order_date: x.get_column('customer_order_date'),
            customer_committed_date: x.get_column('committed_customer_date'),
            procurement_date: x.get_column('procurement_date'),
            is_sez: x.get_column('sez'),
            is_kit: x.get_column('is_kit'),

            #stage: x.get_column('increment_id'),
            # freight_option: x.get_column('increment_id'),
            # project_uid: x.get_column('increment_id'),
            # payment_option: x.get_column('increment_id'),
            # packing_and_forwarding_option: x.get_column('increment_id'),
            # price_type: x.get_column('increment_id'),
            weight_in_kgs: x.get_column('weight'),
        # commercial_terms_and_conditions: x.get_column('increment_id'),
        )

        inquiry.assign_attributes(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_name(x.get_column('currency'))))
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('increment_id')}")
      end
    end

    generate_csv(errors, "inquiries")
  end

  def inquiry_details
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_items.csv')
    service.loop(limit) do |x|
      begin
        if x.get_column('quotation_id').present? && x.get_column('product_id').present?
          inquiry = Inquiry.find_by_legacy_id(x.get_column('quotation_id'))
          product = Product.find_by_legacy_id(x.get_column('product_id'))

          if !product.present?
            product = Product.create!(name: x.get_column('caption'),
                                      brand: nil,
                                      category: Category.default,
                                      sku: x.get_column('sku'),
                                      description: x.get_column('caption'),
                                      meta_description: x.get_column('caption'),
                                      meta_title: x.get_column('caption'),
                                      legacy_id: x.get_column('product_id')
            )

            overseer = Overseer.find_by_email('ashwin.goyal@bulkmro.com')
            product.create_approval(:comment => product.comments.create!(:overseer => overseer, message: 'Legacy product, being preapproved'), :overseer => overseer)
          end

          if (inquiry.present? && product.present?)
            inquiry_product = InquiryProduct.create!(
                inquiry: inquiry,
                product: product,
                sr_no: x.get_column('order'),
                quantity: x.get_column('qty'),
                bp_catalog_name: x.get_column('caption'),
                bp_catalog_sku: (x.get_column('bpcat') if x.get_column('bpcat') != 'NULL')
            )
            if (x.get_column('sup_code') != 'NULL')
              supplier = Company.where(remote_uid: x.get_column('sup_code'), is_supplier: true).first
              inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.create!(
                  supplier: supplier,
                  unit_cost_price: x.get_column('cost')
              # bp_catalog_name: x.get_column(),
              # bp_catalog_sku: x.get_column()
              )

              sales_quote = inquiry.sales_quotes.blank? ? inquiry.sales_quotes.build({overseer: inquiry.inside_sales_owner, quotation_uid: (x.get_column('doc_entry') if x.get_column('doc_entry') != 'NULL')}) : inquiry.sales_quotes.last

              #sales_quote = inquiry.sales_quotes.create!(quotation_uid: nil)
              sales_quote_row = sales_quote.rows.build(
                  inquiry_product_supplier: inquiry_product_supplier,
                  quantity: x.get_column('qty'),
                  margin_percentage: ((1 - (x.get_column('cost').to_f / x.get_column('price_ht').to_f)) * 100),
                  tax_code: TaxCode.find_by_chapter(x.get_column('hsncode')),
                  legacy_applicable_tax: x.get_column('tax_code'),
                  legacy_applicable_tax_class: x.get_column('tax_class_id'),
                  unit_selling_price: x.get_column('price_ht'),
                  converted_unit_selling_price: x.get_column('price_ht'),
                  lead_time_option: LeadTimeOption.find_by_name(x.get_column('leadtime'))
              )
              sales_quote.save
            end
          end
        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('quotation_id')}")
      end
    end
    generate_csv(errors, "inquiry_details")
  end

  def sales_order_drafts
    errors = []
    legacy_request_status = {'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70}

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv')
    service.loop(limit) do |x|
      begin
        inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
        if (inquiry.present? && x.get_column('order_number').present?)

          requested_by = Overseer.find_by_legacy_id(x.get_column('requested_by'))
          requested_by = requested_by.present? ? requested_by : Overseer.find_by_email('ashwin.goyal@bulkmro.com')

          sales_quote = inquiry.sales_quotes.last

          sales_order = sales_quote.sales_orders.build(
              :overseer => requested_by,
              order_number: x.get_column('order_number'),
              created_at: x.get_column('requested_time').to_datetime,
              sap_series: x.get_column('sap_series'),
              remote_uid: x.get_column('remote_uid'),
              doc_number: x.get_column('doc_num'),
              legacy_request_status: legacy_request_status[x.get_column('request_status')]
          )

          product_skus = x.get_column('skus')

          sales_quote.rows.each do |row|
            if product_skus.include? row.product.sku
              sales_order.rows.build(:sales_quote_row => row)
            end
          end

          sales_order.save!
          if (x.get_column('request_status') == 'approved' || x.get_column('request_status') == 'requested')
            overseer = Overseer.find_by_email('ashwin.goyal@bulkmro.com')
            sales_order.create_approval(:comment => sales_order.inquiry.comments.create!(:overseer => overseer, message: 'Legacy sales order, being preapproved'), :overseer => overseer, :metadata => Serializers::InquirySerializer.new(sales_order.inquiry))
          elsif (x.get_column('request_status') == 'rejected')
            overseer = Overseer.find_by_email('ashwin.goyal@bulkmro.com')
            sales_order.create_rejection(:comment => sales_order.inquiry.comments.create!(:overseer => overseer, message: 'Legacy sales order, being rejected'), :overseer => overseer)
          end

        end
      rescue => error
        errors.push("#{error.inspect} - #{x.get_column('inquiry_number')}")
      end
    end

    generate_csv(errors, "sales_order_drafts")
  end

  def inquiry_attachments
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_attachments.csv')
    service.loop(limit) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      sheet_columns = [
          %w(calculation_sheet calculation_sheet_path calculation_sheet),
          ['customer_po_sheet', 'customer_po_sheet_path', 'customer_po_sheet'],
          ['email_attachment', 'email_attachment_path', 'copy_of_email'],
          ['supplier_quote_attachment', 'sqa_path', 'suppler_quote'],
          ['supplier_quote_attachment_additional', 'sqa_additional_path', 'final_supplier_quote']
      ]

      if inquiry.present?
        sheet_columns.each do |file|
          file_attach(inquiry, filename: x.get_column(file[0]), field_name: file[2], file_url: x.get_column(file[1]))
        end
      end
    end
  end

  def file_attach(inquiry, filename:, field_name:, file_url:)
    if file_url.present? && filename.present?
      file = open(file_url)
      inquiry.send(field_name).attach(io: file, filename: filename)
    end
  end
end