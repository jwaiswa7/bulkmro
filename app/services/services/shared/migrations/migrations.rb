require 'csv'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  attr_accessor :limit, :secondary_limit

  def initialize
    @limit = nil
    @secondary_limit = nil

    methods = %w(overseers overseers_smtp_config measurement_unit lead_time_option currencies states payment_options industries accounts_acting_as_customers contacts companies_acting_as_customers addresses companies_acting_as_suppliers supplier_contacts supplier_addresses warehouse brands tax_codes categories products inquiries inquiry_terms activity inquiry_details sales_order_drafts)

    methods.each do |method|
      perform_migration(method.to_sym)
    end
  end

  def overseers
    Overseer.where(:email => 'ashwin.goyal@bulkmro.com').first_or_create! do |overseer|
      overseer.first_name = 'Ashwin'
      overseer.last_name = 'Goyal'
      overseer.role = :admin
      overseer.username = 'ashwin.goyal'
      overseer.password = 'abc123'
      overseer.password_confirmation = 'abc123'
    end

    roles_mapping = {
        'Administrators' => :admin,
        'Logistics' => :sales,
        'Sales Executive' => :sales,
        'Data Entry' => :sales,
        'accounts' => :sales,
        'Admin With Edit Invoice' => :sales,
        'Sales Support' => :sales,
        'SalesExport' => :sales,
        'sales_supplier' => :sales,
        'Sales Manager' => :sales_manager,
        'HR' => :sales,
        'Creative' => :sales,
        'saleswithaccounts' => :sales,
        'salesSupplierNew' => :sales,
        'Sales Executive with target report' => :sales,
        'God' => :admin,
        'NULL' => :sales
    }

    status_mapping = {
        '1' => :active,
        '0' => :inactive
    }

    service = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv')
    service.loop(secondary_limit) do |x|
      Overseer.where(email: x.get_column('email').strip.downcase).first_or_create! do |overseer|
        password = Devise.friendly_token
        identifier = x.get_column('identifier', downcase: true)
        role_name = roles_mapping[x.get_column('role_name')]


        overseer.assign_attributes(
            parent: Overseer.find_by_first_name(x.get_column('business_head_manager').split(' ')[0]),
            first_name: x.get_column('firstname'),
            last_name: x.get_column('lastname'),
            role: case role_name
                  when :sales
                    if identifier == 'inside'
                      :inside_sales
                    elsif identifier == 'outside'
                      :outside_sales
                    elsif identifier == 'outside/manager'
                      :outside_sales_manager
                    else
                      :sales
                    end
                  else
                    role_name
                  end,
            function: x.get_column('user_function'),
            department: x.get_column('user_department'),
            status: status_mapping[x.get_column('is_active')],
            username: x.get_column('username'),
            mobile: x.get_column('mobile'),
            designation: x.get_column('designation'),
            identifier: identifier,
            geography: x.get_column('user_geography'),
            salesperson_uid: x.get_column('sap_internal_code'),
            employee_uid: x.get_column('employee_id'),
            center_code_uid: x.get_column('user_id'),
            legacy_id: x.get_column('user_id'),
            password: password,
            password_confirmation: password,
            legacy_metadata: x.get_row,
            created_at: x.get_column('created', to_datetime: true),
            updated_at: x.get_column('modified', to_datetime: true),
        )
      end
    end

    service.loop(secondary_limit) do |x|
      overseer = Overseer.find_by_email(x.get_column('email', downcase: true))
      business_head = x.get_column('business_head')
      business_head_manager = x.get_column('business_head_manager')

      actual_business_head = if business_head.present? && overseer.first_name == business_head.split(' ')[0]
                               business_head_manager
                             else
                               business_head
                             end

      overseer.update_attributes(:parent => Overseer.find_by_first_name(actual_business_head.split(' ')[0]))
    end
  end

  def overseers_smtp_config
    service = Services::Shared::Spreadsheets::CsvImporter.new('smtp_conf.csv')
    service.loop(secondary_limit) do |x|
      email = x.get_column('email')
      next if email.in? %w(shailesh.salekar@bulkmro.com service@bulkmro.com)
      overseer = Overseer.find_by_email!(email)
      overseer.update_attributes(:smtp_password => x.get_column('password'))
    end
  end


  def measurement_unit
    measurement_units = ["EA", "SET", "PK", "KG", "M", "FT", "Pack", "Pair", "PR", "BOX", "LTR", "LT", "MTR", "ROLL", "Nos", "PKT", "REEL", "FEET", "Meter", "1 ROLL", "ml", "MAT", "LOT", "No", "RFT", "Bundle", "NPkt", "Metre", "CAN", "SQ.Ft", "BOTTLE", "BOTTEL", "CUBIC METER", "PC", "GRAM", "EACH", "FOOT", "Dozen", "INCH", "Ream", "Bag", "Unit", "MT", "KIT", "SQ INCH", "CASE"]
    MeasurementUnit.first_or_create! measurement_units.map {|mu| {name: mu}}
  end

  def lead_time_option
    LeadTimeOption.first_or_create!([
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
                                        {name: "20 WEEKS", min_days: 140, max_days: 140},
                                        {name: "24 WEEKS", min_days: 168, max_days: 168},
                                        {name: "6-10 WEEKS", min_days: 42, max_days: 70},
                                        {name: "10-12 WEEKS", min_days: 70, max_days: 84},
                                        {name: "12-14 WEEKS", min_days: 84, max_days: 98},
                                        {name: "14-16 WEEKS", min_days: 98, max_days: 112},
                                        {name: "MORE THAN 14 WEEKS", min_days: 98, max_days: nil},
                                        {name: "MORE THAN 12 WEEKS", min_days: 84, max_days: nil},
                                        {name: "MORE THAN 6 WEEKS", min_days: 42, max_days: nil},
                                        {name: "60 days from the date of order for 175MT, and 60 days for remaining from the date of call", min_days: 60, max_days: 120},
                                        {name: "In Stock", min_days: 0, max_days: 0},
                                        {name: "Refer T&C", min_days: 0, max_days: 0}
                                    ])
  end

  def currencies
    Currency.first_or_create!([
                                  {name: 'USD', conversion_rate: 71.59, legacy_id: 2},
                                  {name: 'INR', conversion_rate: 1, legacy_id: 0},
                                  {name: 'EUR', conversion_rate: 83.85, legacy_id: 1},
                              ])
  end

  def states
    service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv')
    service.loop(secondary_limit) do |x|
      AddressState.where(name: x.get_column('default_name').strip).first_or_create! do |state|
        state.assign_attributes(
            country_code: x.get_column('country_id'),
            region_code: x.get_column('code'),
            region_code_uid: x.get_column('sap_code'),
            remote_uid: x.get_column('gst_state_code'),
            legacy_id: x.get_column('region_id'),
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def payment_options
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
    service.loop(secondary_limit) do |x|
      next if x.get_column('id').in? %w(123 146)
      raise if x.get_column('value') == 'NULL'
      PaymentOption.where(name: x.get_column('value')).first_or_create! do |payment_option|
        payment_option.assign_attributes(
            remote_uid: x.get_column('group_code', nil_if_zero: true),
            legacy_id: x.get_column('id'),
            credit_limit: x.get_column('credit_limit').to_f,
            general_discount: x.get_column('general_discount').to_f,
            load_limit: x.get_column('load_limit').to_f,
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def industries
    service = Services::Shared::Spreadsheets::CsvImporter.new('industries.csv')
    service.loop(secondary_limit) do |x|
      Industry.first_or_create!(
          remote_uid: x.get_column('industry_sap_id'),
          name: x.get_column('industry_name'),
          description: x.get_column('industry_description'),
          legacy_id: x.get_column('idindustry'),
          legacy_metadata: x.get_row
      )
    end
  end

  def accounts_acting_as_customers
    Account.first_or_create!(remote_uid: 101, name: "Trade", alias: "TRD")
    Account.first_or_create!(remote_uid: 102, name: "Non-Trade", alias: "NTRD")
    Account.first_or_create!(remote_uid: 99999999, name: "Legacy Account", alias: "LA")

    service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')
    service.loop(limit) do |x|
      id = x.get_column('id')
      next if id.in? %w(3275)
      account_name = x.get_column('aliasname')
      Account.where(name: account_name).first_or_create! do |accounts|
        accounts.remote_uid = x.get_column('sap_id')
        accounts.name = account_name
        accounts.alias = account_name.titlecase.split.map(&:first).join
        accounts.legacy_id = id
        accounts.account_type = :is_customer
        accounts.legacy_metadata = x.get_row
      end
    end
  end

  def contacts
    raise

    password = Devise.friendly_token
    Contact.create!(account: Account.legacy, remote_uid: 99999999, email: "legacy@bulkmro.com", first_name: "Fake", last_name: "Name", telephone: "9999999999", password: password, password_confirmation: password)

    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')

    status_mapping = {'0' => 20, '1' => 10}
    contact_group_mapping = {'General' => 10, 'Company Top Manager' => 20, 'Retailer' => 30, 'Ador' => 40, 'Vmi_group' => 50, 'C-Form customer GROUP' => 60, 'Manager' => 70}

    service.loop(limit) do |x|
      if x.get_column('aliasname').present?
        account = Account.find_by_name!(x.get_column('aliasname'))
      else
        account = Account.legacy
      end

      Contact.where(email: x.get_column('email').downcase).first_or_create! do |contact|
        password = Devise.friendly_token
        contact.assign_attributes(
            account: account,
            remote_uid: x.get_column('sap_id'),
            first_name: x.get_column('firstname', default: 'fname'),
            last_name: x.get_column('lastname'),
            prefix: x.get_column('prefix'),
            designation: x.get_column('designation'),
            telephone: x.get_column('telephone'),
            status: status_mapping[x.get_column('is_active').to_s],
            contact_group: contact_group_mapping[x.get_column('group')],
            password: password,
            password_confirmation: password,
            legacy_id: x.get_column('entity_id'),
            legacy_metadata: x.get_row
        )
      end
    end
    raise

  end

  def companies_acting_as_customers
    legacy_account = Account.legacy
    legacy_company = Company.create!(
        name: "Legacy Company",
        account: legacy_account,
        remote_uid: 99999999,
    )

    company_contact = CompanyContact.create!(company: legacy_company, contact: legacy_account.contacts.first)
    legacy_company.company_contacts << company_contact
    legacy_company.update_attributes(:default_company_contact => company_contact)

    service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv')
    service.loop(limit) do |x|
      account = if x.get_column('aliasname').present?
                  Account.find_by_name(x.get_column('aliasname'))
                else
                  legacy_account
                end

      company_type_mapping = {'Proprietorship' => 10, 'Private Limited' => 20, 'Contractor' => 30, 'Trust' => 40, 'Public Limited' => 50}
      priority_mapping = {'0' => 10, '1' => 20}
      nature_of_business_mapping = {'Trading' => 10, 'Manufacturer' => 20, 'Dealer' => 30}
      is_msme_mapping = {'N' => false, 'Y' => true}
      urd_mapping = {'N' => false, 'Y' => true}

      company_name = x.get_column('cmp_name')
      if company_name
        Company.where(name: company_name).first_or_create! do |company|
          inside_sales_owner = Overseer.find_by_email(x.get_column('inside_sales_email'))
          outside_sales_owner = Overseer.find_by_email(x.get_column('outside_sales_email'))
          sales_manager = Overseer.find_by_email(x.get_column('manager_email'))
          payment_option = PaymentOption.find_by_name(x.get_column('payment_term'))

          company.assign_attributes(default_company_contact: CompanyContact.new(company: company, contact: account.contacts.find_by_email(x.get_column('email').strip.downcase))) if x.get_column('email').present?

          company.assign_attributes(
              account: account,
              industry: Industry.find_by_name(x.get_column('cmp_industry')),
              remote_uid: x.get_column('cmp_id'),
              legacy_email: x.get_column('cmp_email', downcase: true),
              default_payment_option: payment_option,
              inside_sales_owner: inside_sales_owner,
              outside_sales_owner: outside_sales_owner,
              sales_manager: sales_manager,
              site: x.get_column('cmp_website'),
              company_type: company_type_mapping[x.get_column('company_type')],
              priority: priority_mapping[x.get_column('is_strategic').to_s],
              nature_of_business: nature_of_business_mapping[x.get_column('nature_of_business')],
              credit_limit: x.get_column('creditlimit', default: 1),
              is_msme: is_msme_mapping[x.get_column('msme')],
              is_unregistered_dealer: urd_mapping[x.get_column('urd')],
              tax_identifier: x.get_column('cmp_gst'),
              is_customer: true,
              attachment_uid: x.get_column('attachment_entry'),
              legacy_id: x.get_column('cmp_id'),
              pan: x.get_column('cmp_pan'),
              tan: x.get_column('cmp_tan'),
              legacy_metadata: x.get_row
          )
        end
      end
    end
  end

  def company_contacts
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contact_mapping.csv')

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      contact_email = x.get_column('email', downcase: true)
      if contact_email && company_name
        company = Company.find_by_name(company_name)
        company_contact = CompanyContact.find_or_create_by(
            company: Company.find_by_name(company_name),
            contact: Contact.find_by_email(contact_email),
            legacy_metadata: x.get_row
        )

        company.update_attributes(:default_company_contact => company_contact) if company.legacy_metadata['default_contact'] == x.get_column('entity_id')
      end
    end
  end

  def addresses
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv')
    gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    legacy_company = Company.legacy
    legacy_company.addresses.create!(
        company: legacy_company,
        name: legacy_company.name,
        gst: '2AAAAAAAAAAAAAA',
        country_code: "IN",
        state: AddressState.find_by_name('Maharashtra'),
        state_name: nil,
        city_name: "Mumbai",
        pincode: "400001",
        street1: "Lower Parel"
    )

    service.loop(limit) do |x|
      company = Company.find_by_name(x.get_column('cmp_name'))

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
          gst_type: gst_type[x.get_column('gst_type').to_i],
          legacy_id: x.get_column('idcompany_gstinfo'),
          legacy_metadata: x.get_row
      )

      address.assign_attributes(
          billing_address_uid: x.get_column('sap_row_num').split(',')[0],
          shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
      ) if x.get_column('sap_row_num').present?


      if company.legacy_metadata['default_billing'] == x.get_column('idcompany_gstinfo')
        company.default_billing_address = address
      end

      if company.legacy_metadata['default_shipping'] == x.get_column('idcompany_gstinfo')
        company.default_shipping_address = address
      end

      ActiveRecord::Base.transaction do
        address.save!
        company.save!
      end
    end
  end

  def companies_acting_as_suppliers
    supplier_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers.csv')
    supplier_service.loop(limit) do |x|
      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      supplier_name = x.get_column('sup_name')
      company = Company.find_by_name(supplier_name)

      if company.present?
        company.update_attributes(:name => "#{company.name} (Customer)")
        supplier_name = "#{supplier_name} (Supplier)"
      end

      company_type_mapping = {'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110}
      is_msme_mapping = {"N" => false, "Y" => true}
      urd_mapping = {"N" => false, "Y" => true}

      Company.where(remote_uid: x.get_column('sup_code').strip).first_or_create! do |company|

        inside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_person'))
        outside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_outside'))
        sales_manager = Overseer.find_by_email(x.get_column('sup_sales_manager'))
        payment_option = PaymentOption.find_by_name(x.get_column('payment_terms'))

        company.assign_attributes(
            account: account,
            name: name,
            default_payment_option: payment_option,
            inside_sales_owner: inside_sales_owner,
            outside_sales_owner: outside_sales_owner,
            sales_manager: sales_manager,
            site: x.get_column('cmp_website'),
            company_type: (company_type_mapping[x.get_column('sup_type').split(',').first] if x.get_column('sup_type')),
            credit_limit: x.get_column('creditlimit', default: 1),
            is_msme: is_msme_mapping[x.get_column('msme')],
            is_unregistered_dealer: urd_mapping[x.get_column('urd')],
            tax_identifier: x.get_column('cmp_gst'),
            is_supplier: true,
            is_customer: false,
            legacy_id: x.get_column('sup_id'),
            pan: x.get_column('sup_pan'),
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def supplier_contacts
    service = Services::Shared::Spreadsheets::CsvImporter.new('supplier_contacts.csv')

    service.loop(limit) do |x|
      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      contact_email = x.get_column('pc_email', downcase: true)
      supplier_name = x.get_column('sup_name')

      if contact_email && supplier_name
        supplier_contact = Contact.where(email: contact_email).first_or_create! do |contact|
          password = Devise.friendly_token

          contact.assign_attributes(
              account: account,
              remote_uid: x.get_column('sap_id'),
              first_name: x.get_column('pc_firstname', default: 'fname'),
              last_name: x.get_column('pc_lastname', default: 'lname'),
              prefix: x.get_column('prefix'),
              designation: x.get_column('pc_function'),
              telephone: x.get_column('pc_phone'),
              mobile: x.get_column('pc_mobile'),
              status: :active,
              password: password,
              password_confirmation: password,
              legacy_id: x.get_column('pc_num'),
              legacy_metadata: x.get_row
          )
        end

        company = Company.find_by_name!(supplier_name)
        CompanyContact.find_or_create_by(
            company: company,
            contact: supplier_contact,
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def supplier_addresses
    supplier_address_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers_address.csv')
    gst_type_mapping = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    supplier_address_service.loop(limit) do |x|
      company = Company.find_by_name(x.get_column('cmp_name'))

      if company.present?
        country_code = x.get_column('country')
        address = Address.new(
            company: company,
            name: company.name,
            gst: x.get_column('gst_num'),
            country_code: country_code,
            state: AddressState.find_by_name(x.get_column('state_name')),
            state_name: country_code == 'IN' ? nil : x.get_column('state_name'),
            city_name: x.get_column('city'),
            pincode: x.get_column('pincode'),
            street1: x.get_column('address'),
            cst: x.get_column('cst_num'),
            vat: x.get_column('vat_num'),
            excise: x.get_column('ed_num'),
            telephone: x.get_column('telephone'),
            gst_type: gst_type_mapping[x.get_column('gst_type').to_i],
            legacy_id: x.get_column('address_id'),
            legacy_metadata: x.get_row
        )

        address.assign_attributes(
            billing_address_uid: x.get_column('sap_row_num').split(',')[0],
            shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
        ) if x.get_column('sap_row_num').present?


        if company.legacy_metadata['default_billing'] == x.get_column('address_id')
          company.default_billing_address = address
        end

        if company.legacy_metadata['default_shipping'] == x.get_column('address_id')
          company.default_shipping_address = address
        end

        ActiveRecord::Base.transaction do
          address.save!
          company.save!
        end
      end
    end
  end

  def warehouse
    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses.csv')
    service.loop(limit) do |x|
      Warehouse.where(:name => x.get_column('Warehouse Name')).first_or_create do |warehouse|
        warehouse.assign_attributes(
            :remote_uid => x.get_column('Warehouse Code'),
            :legacy_id => x.get_column('Warehouse Code'),
            :location_uid => x.get_column('Location'),
            :remote_branch_name => x.get_column('Warehouse Name'),
            :remote_branch_code => x.get_column('Business Place ID'),
            :legacy_metadata => x.get_row
        )

        warehouse.build_address(
            :street1 => x.get_column('Street'),
            :street2 => x.get_column('Block'),
            :pincode => x.get_column('Zip Code'),
            :city_name => x.get_column('City'),
            :country_code => x.get_column('Country'),
            :state => AddressState.find_by_region_code(x.get_column('State'))
        )
      end
    end
  end

  def brands
    Brand.create!(name: 'Legacy Brand')
    service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
    service.loop(limit) do |x|
      Brand.where(name: x.get_column('value')).first_or_create! do |brand|
        brand.legacy_id = x.get_column('option_id')
        brand.legacy_metadata = x.get_row
      end
    end
  end

  def tax_codes
    service = Services::Shared::Spreadsheets::CsvImporter.new('hsn_codes.csv')
    service.loop(limit) do |x|
      chapter = x.get_column('chapter')
      tax_code = x.get_column('tax_code')

      if chapter && tax_code
        TaxCode.where(legacy_id: x.get_column('idbmro_sap_hsn_mapping')).first_or_create!(
            chapter: chapter,
            remote_uid: x.get_column('internal_key'),
            code: ((x.get_column('hsn') == "NULL") || (x.get_column('hsn') == nil) ? x.get_column('chapter') : x.get_column('hsn').gsub('.', '')),
            description: x.get_column('description'),
            is_service: x.get_column('is_service') == 'NULL' ? false : true,
            tax_percentage: tax_code.match(/\d+/)[0].to_f,
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def categories
    service = Services::Shared::Spreadsheets::CsvImporter.new('categories.csv')
    service.loop(limit) do |x|
      id = x.get_column('id')
      parent_id = x.get_column('parent_id')

      if id != '1' && id != '2'
        tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code'))
        parent = Category.find_by_remote_uid(x.get_column('parent_id')) if parent_id != '2'

        Category.create!(
            remote_uid: x.get_column('sap_code', nil_if_zero: true),
            tax_code: tax_code || TaxCode.default,
            parent: parent,
            name: x.get_column('name'),
            description: x.get_column('description'),
            legacy_id: x.get_column('id'),
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def products
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    service.loop(limit) do |x|
      brand = Brand.find_by_legacy_id(x.get_column('product_brand'))
      measurement_unit = MeasurementUnit.find_by_name(x.get_column('uom_name'))

      product = Product.create!(
          name: x.get_column('name'),
          brand: brand,
          category: Category.default,
          sku: x.get_column('sku'),
          description: x.get_column('description'),
          meta_description: x.get_column('meta_description'),
          meta_keyword: x.get_column('meta_keyword'),
          meta_title: x.get_column('meta_title'),
          legacy_id: x.get_column('entity_id'),
          remote_uid: x.get_column('sap_created') ? x.get_column('sku') : nil,
          measurement_unit: measurement_unit,
          legacy_metadata: x.get_row
      )

      product.create_approval(:comment => product.comments.create!(:overseer => Overseer.default, message: 'Legacy product, being preapproved'), :overseer => overseer)
    end
  end


  def inquiries
    legacy_company = Company.legacy
    opportunity_type = {'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80}
    quote_category = {'bmro' => 10, 'ong' => 20}
    opportunity_source = {1 => 10, 2 => 20, 3 => 30, 4 => 40}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries.csv')

    service.loop(limit) do |x|
      company = Company.find_by_remote_uid(x.get_column('customer_company')) || legacy_company
      contact_email = x.get_column('email', downcase: true)

      if contact_email
        contact = Contact.find_by_email(contact_email) || company.contacts.first
        CompanyContact.where(company: company, contact: contact).first_or_create
      end

      if company.industry.blank?
        industry_uid = x.get_column('industry_sap_id')

        if industry_uid
          industry = Industry.find_by_remote_uid(industry_uid)
          company.update_attributes(:industry => industry) if industry.present?
        end
      end

      billing_address = company.addresses.find_by_legacy_id(x.get_column('billing_address'))
      shipping_address = company.addresses.find_by_legacy_id(x.get_column('shipping_address'))

      inquiry = Inquiry.create!(
          inquiry_number: x.get_column('increment_id'),
          company: company,
          contact: contact,
          status: x.get_column('bought').to_i,
          opportunity_type: (opportunity_type[x.get_column('quote_type').gsub(" ", "_").downcase] if x.get_column('quote_type').present?),
          potential_amount: x.get_column('potential_amount'),
          opportunity_source: (opportunity_source[x.get_column('opportunity_source').to_i] if x.get_column('opportunity_source').present?),
          subject: x.get_column('caption'),
          gross_profit_percentage: x.get_column('grossprofitp'),
          inside_sales_owner: Overseer.find_by_username(x.get_column('manager')),
          outside_sales_owner: Overseer.find_by_username(x.get_column('outside')),
          sales_manager: Overseer.find_by_username(x.get_column('powermanager')),
          quote_category: (quote_category[x.get_column('category').downcase] if x.get_column('category').present?),
          billing_address: billing_address || company.addresses.first,
          shipping_address: shipping_address || company.addresses.first,
          opportunity_uid: x.get_column('op_code'),
          customer_po_number: x.get_column('customer_po_id'),
          customer_po_sheet: x.get_column('additional_pdf1'),
          calculation_sheet: x.get_column('additional_pdf'),
          email_attachment: x.get_column('email_attachment'),
          supplier_quote_attachment: x.get_column('supplier_quote_attachment'),
          supplier_quote_attachment_additional: x.get_column('final_sup_quote_attachment'),
          legacy_shipping_company: Company.find_by_remote_uid(x.get_column('customer_shipping_company')),
          bill_from: Warehouse.find_by_legacy_id(x.get_column('warehouse')),
          ship_from: Warehouse.find_by_legacy_id(x.get_column('ship_from_warehouse')),
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
          weight_in_kgs: x.get_column('weight'),
          legacy_metadata: x.get_row,
          created_at: x.get_column('created_time', to_datetime: true),
      )

      inquiry.update_attributes(legacy_bill_to_contact: company.contacts.where('first_name ILIKE ? AND last_name ILIKE ?', "%#{x.get_column('billing_name').split(' ').first}%", "%#{x.get_column('billing_name').split(' ').last}%").first) if x.get_column('billing_name').present?
      inquiry.update_attributes(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_legacy_id(x.get_column('currency'))))
    end
  end

  def inquiry_terms
    price_type_mapping = {'CIF' => 30, 'CIP Mumbai Airport' => 80, 'DAP' => 50, 'DD' => 90, 'Door Delivery' => 60, 'EXW' => 10, 'FCA Mumbai' => 70, 'FOB' => 20, 'CFR' => 40}
    freight_option_mapping = {'Extra as per Actual' => 20, 'Included' => 10}
    packing_and_forwarding_option_mapping = {'Included' => 10, 'Not Included' => 20}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_terms.csv')
    service.loop(limit) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      inquiry.update_attributes(
          price_type: price_type_mapping[x.get_column('Price')],
          freight_option: freight_option_mapping[x.get_column('Freight')],
          commercial_terms_and_conditions: x.get_column('Commercial Terms & Conditions'),
          payment_option: PaymentOption.find_by_name(x.get_column('Payment Terms')),
          packing_and_forwarding_option: packing_and_forwarding_option_mapping[x.get_column('Packing and Forwarding')]
      )
    end
  end

  def inquiry_details
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_items.csv')
    service.loop(limit) do |x|
      quotation_id = x.get_column('quotation_id')
      product_id = x.get_column('product_id')
      if quotation_id && product_id
        inquiry = Inquiry.find_by_legacy_id(quotation_id)
        product = Product.find_by_legacy_id(product_id)

        if product.blank?
          product = Product.create!(
              name: x.get_column('caption'),
              brand: Brand.legacy,
              category: Category.default,
              sku: x.get_column('sku'),
              description: x.get_column('caption'),
              meta_description: x.get_column('caption'),
              meta_title: x.get_column('caption'),
              legacy_id: x.get_column('product_id')
          )

          product.create_approval(
              :comment => product.comments.create!(
                  :overseer => Overseer.default, message: 'Legacy product, being preapproved'
              ),
              :overseer => Overseer.default
          )
        end

        if inquiry.present?
          inquiry_product = InquiryProduct.create!(
              inquiry: inquiry,
              product: product,
              sr_no: x.get_column('order'),
              quantity: x.get_column('qty', nil_if_zero: true) || 1,
              bp_catalog_name: x.get_column('caption'),
              bp_catalog_sku: x.get_column('bpcat'),
              legacy_metadata: x.get_row
          )

          supplier_uid = x.get_column('sup_code')
          if supplier_uid
            supplier = Company.where(remote_uid: supplier_uid, is_supplier: true).first
            inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.create!(
                supplier: supplier,
                unit_cost_price: x.get_column('cost')
            )

            quotation_uid = x.get_column('doc_entry')
            sales_quote = inquiry.sales_quote

            if sales_quote.blank?
              if quotation_uid.present?
                sales_quote = inquiry.sales_quotes.build({overseer: inquiry.inside_sales_owner, quotation_uid: quotation_uid})
              end
            end

            # todo look at tax_code
            sales_quote.rows.create!(
                inquiry_product_supplier: inquiry_product_supplier,
                quantity: x.get_column('qty', nil_if_zero: true) || 1,
                margin_percentage: ((1 - (x.get_column('cost').to_f / x.get_column('price_ht').to_f)) * 100),
                tax_code: TaxCode.find_by_chapter(x.get_column('hsncode')) || TaxCode.default,
                legacy_applicable_tax: x.get_column('tax_code'),
                legacy_applicable_tax_class: x.get_column('tax_class_id'),
                unit_selling_price: x.get_column('price_ht'),
                converted_unit_selling_price: x.get_column('price_ht'),
                lead_time_option: LeadTimeOption.find_by_name(x.get_column('leadtime'))
            )
          end
        end
      end
    end
  end

  def sales_order_drafts
    legacy_request_status_mapping = {'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70}

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv')
    service.loop(limit) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))

      if inquiry.present?
        requested_by = Overseer.find_by_legacy_id(x.get_column('requested_by')) || Overseer.default
        sales_quote = inquiry.sales_quotes.last

        sales_order = sales_quote.sales_orders.build(
            overseer: requested_by,
            order_number: x.get_column('order_number'),
            created_at: x.get_column('requested_time').to_datetime,
            sap_series: x.get_column('sap_series'),
            remote_uid: x.get_column('remote_uid'),
            doc_number: x.get_column('doc_num'),
            legacy_request_status: legacy_request_status_mapping[x.get_column('request_status')],
            legacy_metadata: x.get_row
        )

        product_skus = x.get_column('skus')

        sales_quote.rows.each do |row|
          if product_skus.include? row.product.sku
            sales_order.rows.build(:sales_quote_row => row)
          end
        end

        sales_order.save!

        # todo handle cancellation, etc
        request_status = x.get_column('request_status')
        if request_status.in? %w(approved requested)
          sales_order.create_approval(
              :comment => sales_order.inquiry.comments.create!(:overseer => Overseer.default, message: 'Legacy sales order, being preapproved'),
              :overseer => Overseer.default,
              :metadata => Serializers::InquirySerializer.new(sales_order.inquiry)
          )
        elsif request_status == 'rejected'
          sales_order.create_rejection(
              :comment => sales_order.inquiry.comments.create!(:overseer => Overseer.default, message: 'Legacy sales order, being rejected'),
              :overseer => Overseer.default
          )
        else
          sales_order.inquiry.comments.create(:overseer => Overseer.default, message: "Legacy sales order, being #{request_status}")
        end
      end
    end
  end

  def activity
    company_type_mapping = {'is_supplier' => 10, 'is_customer' => 20}
    purpose = {'First Meeting/Intro Meeting' => 10, 'Follow up' => 20, 'Negotiation' => 30, 'Closure' => 40, 'Others' => 50}
    activity_type = {'Meeting' => 10, 'Phone call' => 20, 'Email' => 30, 'Quote/Tender Prep' => 40, 'Tender preparation' => 50}
    activity_status = {'Approved' => 10, 'Pending Approval' => 20, 'Rejected' => 30}

    service = Services::Shared::Spreadsheets::CsvImporter.new('activity_reports.csv')
    service.loop(limit) do |x|

      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      contact = Contact.find_by_legacy_id(x.get_column('company_contact_lagacy'))
      company = contact.companies.first if contact.present?
      company_type = company_type_mapping[company.is_supplier ? 'is_supplier' : 'is_customer'] if company.present?

      activity = Activity.where(legacy_id: x.get_column('legacy_id')).first_or_create! do |activity|
        activity.assign_attributes(
            inquiry: inquiry,
            company: company,
            contact: contact,
            subject: x.get_column('subject'),
            company_type: company_type,
            purpose: purpose[x.get_column('purpose')],
            activity_type: activity_type[x.get_column('activity')],
            activity_status: activity_status[x.get_column('activitystatus')],
            points_discussed: x.get_column('comment'),
            actions_required: x.get_column('actionrequired'),
            reference_number: x.get_column('refno'),
            created_at: (x.get_column('created_at').to_datetime if x.get_column('created_at').present?),
            legacy_metadata: x.get_row
        )
      end

      overseer_legacy_id = x.get_column('overseer_legacy_id')
      ActivityOverseer.create!(activity: activity, overseer: Overseer.find_by_legacy_id(overseer_legacy_id)) if overseer_legacy_id.present?
    end
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
          attach_file(inquiry, filename: x.get_column(file[0]), field_name: file[2], file_url: x.get_column(file[1]))
        end
      end
    end
  end

  private

  def perform_migration(name)
    puts "Creating #{name.to_s.pluralize}"
    send name
    puts "Done creating #{name.to_s.pluralize}"
  end

  def attach_file(inquiry, filename:, field_name:, file_url:)
    if file_url.present? && filename.present?
      file = open(file_url)
      inquiry.send(field_name).attach(io: file, filename: filename)
    end
  end
end
