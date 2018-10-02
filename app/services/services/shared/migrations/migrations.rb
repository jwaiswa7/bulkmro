require 'csv'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  attr_accessor :limit, :secondary_limit

  def initialize
    @limit = nil
    @secondary_limit = nil

    PaperTrail.enabled = false

    methods = %w(inquiries inquiry_terms)
    # methods = %w(overseers overseers_smtp_config measurement_unit lead_time_option currencies states payment_options industries accounts contacts companies_acting_as_customers company_contacts addresses companies_acting_as_suppliers supplier_contacts supplier_addresses warehouse brands tax_codes categories products product_categories inquiries inquiry_terms inquiry_details activity sales_order_drafts inquiry_attachments)

    PaperTrail.enabled = true

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
      Industry.where(name: x.get_column('industry_name')).first_or_create! do |industry|
        industry.assign_attributes(
            remote_uid: x.get_column('industry_sap_id'),
            description: x.get_column('industry_description'),
            legacy_id: x.get_column('idindustry'),
            legacy_metadata: x.get_row
        )
      end
    end
  end

  def accounts
    Account.first_or_create!(remote_uid: 101, name: "Trade", alias: "TRD", account_type: :is_supplier)
    Account.first_or_create!(remote_uid: 102, name: "Non-Trade", alias: "NTRD", account_type: :is_supplier)

    Account.where(:name => 'Legacy Account').first_or_create! do |account|
      account.remote_uid = 99999999
      account.alias = 'LGA'
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')
    service.loop(limit) do |x|
      id = x.get_column('id')
      next if id.in? %w(3275)
      account_name = x.get_column('aliasname')
      Account.where(name: account_name).first_or_create! do |account|
        account.remote_uid = x.get_column('sap_id')
        account.name = account_name
        account.alias = account_name.titlecase.split.map(&:first).join
        account.legacy_id = id
        account.account_type = :is_customer
        account.legacy_metadata = x.get_row
        account.created_at = x.get_column('created_at', to_datetime: true)
        account.updated_at = x.get_column('updated_at', to_datetime: true)
      end
    end
  end

  def contacts
    password = Devise.friendly_token
    Contact.where(email: "legacy@bulkmro.com").first_or_create! do |contact|
      contact.assign_attributes(account: Account.legacy, first_name: "Fake", last_name: "Name", telephone: "9999999999", password: password, password_confirmation: password)
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')

    status_mapping = {'0' => 20, '1' => 10}
    contact_group_mapping = {'General' => 10, 'Company Top Manager' => 20, 'Retailer' => 30, 'Ador' => 40, 'Vmi_group' => 50, 'C-Form customer GROUP' => 60, 'Manager' => 70}

    service.loop(limit) do |x|
      entity_id = x.get_column('entity_id')


      alias_name = x.get_column('aliasname')
      first_name = x.get_column('firstname', default: 'fname')
      last_name = x.get_column('lastname', default: 'lname')

      email = x.get_column('email', downcase: true, remove_whitespace: true)
      email = [entity_id, '@bulkmro.com'].join if email.match(Devise.email_regexp).blank?
      # email = [remote_uid, email].join('-') if Contact.where(:email => email).exists?

      account = alias_name ? Account.find_by_name!(x.get_column('aliasname')) : Account.legacy

      Contact.where(email: email).first_or_create! do |contact|
        password = Devise.friendly_token
        contact.assign_attributes(
            legacy_email: x.get_column('email', downcase: true, remove_whitespace: true),
            account: account,
            first_name: first_name,
            last_name: last_name,
            prefix: x.get_column('prefix'),
            designation: x.get_column('designation'),
            telephone: x.get_column('telephone'),
            mobile: x.get_column('mobile'),
            status: status_mapping[x.get_column('is_active').to_s],
            contact_group: contact_group_mapping[x.get_column('group')],
            password: password,
            password_confirmation: password,
            legacy_id: entity_id,
            legacy_metadata: x.get_row,
            created_at: x.get_column('created_at', to_datetime: true),
            updated_at: x.get_column('updated_at', to_datetime: true),
        )
      end
    end
  end

  def companies_acting_as_customers
    legacy_account = Account.legacy
    legacy_company = Company.where(name: "Legacy Company").first_or_create! do |company|
      company.account = legacy_account
      company.remote_uid = 99999999
    end

    company_contact = CompanyContact.first_or_create!(company: legacy_company, contact: legacy_account.contacts.first)
    legacy_company.company_contacts << company_contact
    legacy_company.update_attributes(:default_company_contact => company_contact)

    service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv')
    service.loop(limit) do |x|

      id = x.get_column('Magento Id')
      next if id.in? %w(3275)

      alias_name = x.get_column('aliasname')
      alias_legacy_id = x.get_column('Magento Id')
      account = if alias_legacy_id.present?
                  Account.find_by_legacy_id(alias_legacy_id)
                else
                  legacy_account
                end

      company_type_mapping = {'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110}
      priority_mapping = {'0' => 10, '1' => 20}
      nature_of_business_mapping = {'Trading' => 10, 'Manufacturer' => 20, 'Dealer' => 30}
      is_msme_mapping = {'N' => false, 'Y' => true}
      urd_mapping = {'N' => false, 'Y' => true}

      company_name = x.get_column('cmp_name')
      Company.where(name: company_name || alias_name).first_or_create! do |company|
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
            credit_limit: x.get_column('creditlimit', default: 1, to_f: true),
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

  def company_contacts
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contact_mapping.csv')

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      company_id = x.get_column('cmp_id')
      next if company_name.in? ['Amazon Online Sales']
      next if company_id.in? %w(1764)

      contact_email = x.get_column('email', downcase: true)
      if contact_email && company_name
        company = Company.find_by_name(company_name)
        company_contact = CompanyContact.find_or_create_by(
            company: Company.find_by_name(company_name),
            contact: Contact.find_by_email(contact_email),
            remote_uid: x.get_column('sap_id'),
            legacy_metadata: x.get_row
        )

        company.update_attributes(:default_company_contact => company_contact) if company.legacy_metadata['default_contact'] == x.get_column('entity_id')
      end
    end
  end

  def addresses
    legacy_state = AddressState.where(name: 'Legacy Indian State', country_code: 'IN').first_or_create
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv')
    gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    legacy_company = Company.legacy
    legacy_company.addresses.where(name: 'Legacy Address').first_or_create! do |address|
      address.assign_attributes(
          gst: '2AAAAAAAAAAAAAA',
          country_code: "IN",
          state: AddressState.find_by_name('Maharashtra'),
          state_name: nil,
          city_name: "Mumbai",
          pincode: "400001",
          street1: "Lower Parel"
      )
    end

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      legacy_id = x.get_column('cmp_id')

      next if legacy_id.in? %w(1764)

      company = Company.find_by_legacy_id!(legacy_id)
      address = Address.where(legacy_id: x.get_column('idcompany_gstinfo')).first_or_create! do |address|
        address.assign_attributes(
            company: company,
            name: company.name,
            gst: x.get_column('gst_num'),
            country_code: x.get_column('country'),
            state: AddressState.find_by_name(x.get_column('state_name')) || legacy_state,
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
            legacy_metadata: x.get_row
        )
      end

      address.update_attributes(
          billing_address_uid: x.get_column('sap_row_num').split(',')[0],
          shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
      ) if x.get_column('sap_row_num').present?

      if company.legacy_metadata['default_billing'] == x.get_column('idcompany_gstinfo')
        company.default_billing_address = address
      end

      if company.legacy_metadata['default_shipping'] == x.get_column('idcompany_gstinfo')
        company.default_shipping_address = address
      end

      company.save!
    end
  end

  def companies_acting_as_suppliers
    supplier_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers.csv')
    supplier_service.loop(limit) do |x|
      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      supplier_name = x.get_column('sup_name')
      company = Company.find_by_name(supplier_name)

      next if x.get_column('sup_id').in? %w(5406)

      if company.present?
        company.update_attributes(:name => "#{company.name} (Customer)")
        supplier_name = "#{supplier_name} (Supplier)"
      end

      company_type_mapping = {'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110}
      is_msme_mapping = {"N" => false, "Y" => true}
      urd_mapping = {"N" => false, "Y" => true}

      Company.where(remote_uid: x.get_column('sup_code')).first_or_create! do |company|
        inside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_person'))
        outside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_outside'))
        sales_manager = Overseer.find_by_email(x.get_column('sup_sales_manager'))
        payment_option = PaymentOption.find_by_name(x.get_column('payment_terms'))

        company.assign_attributes(
            account: account,
            name: supplier_name,
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
            legacy_metadata: x.get_row,
            created_at: x.get_column('created_at', to_datetime: true),
            updated_at: x.get_column('updated_at', to_datetime: true)
        )
      end
    end
  end

  def supplier_contacts
    service = Services::Shared::Spreadsheets::CsvImporter.new('supplier_contacts.csv')

    service.loop(limit) do |x|

      supplier_remote_uid = x.get_column('sup_code')
      next if supplier_remote_uid.in? ['SC-9192', 'SC-9195', 'SC-9201', 'SC-9202', 'SC-9205', 'SC-9206', 'SC-9207']

      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      entity_id = x.get_column('pc_num')
      next if supplier_remote_uid.blank?

      supplier_name = x.get_column('sup_name')
      contact_email = x.get_column('pc_email', downcase: true, remove_whitespace: true)
      contact_email = [entity_id, '@bulkmro.com'].join if (!contact_email.present? || contact_email.match(Devise.email_regexp).blank?)

      # if contact_email && supplier_name
      supplier_contact = Contact.where(email: contact_email).first_or_create! do |contact|
        password = Devise.friendly_token

        contact.assign_attributes(
            account: account,
            legacy_email: x.get_column('pc_email', downcase: true, remove_whitespace: true),
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

      company = Company.find_by_remote_uid!(supplier_remote_uid)
      CompanyContact.find_or_create_by(
          company: company,
          contact: supplier_contact,
          remote_uid: x.get_column('sap_id'),
          legacy_metadata: x.get_row
      )
      # end
    end
  end

  def supplier_addresses
    supplier_address_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers_address.csv')
    gst_type_mapping = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    supplier_address_service.loop(limit) do |x|
      company = Company.acts_as_supplier.find_by_legacy_id(x.get_column('cmp_id'))

      next if x.get_column('NULL').nil?

      country_code = x.get_column('country')
      address = Address.where(legacy_id: x.get_column('address_id')).first_or_create do |address|
        address.assign_attributes(company: company,
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
                                  legacy_metadata: x.get_row
        )
      end

      address.update_attributes(
          billing_address_uid: x.get_column('sap_row_num').split(',')[0],
          shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
      ) if x.get_column('sap_row_num').present?

      if company.legacy_metadata['default_billing'] == x.get_column('address_id')
        company.default_billing_address = address
      end

      if company.legacy_metadata['default_shipping'] == x.get_column('address_id')
        company.default_shipping_address = address
      end

      company.save!
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
    Brand.where(name: 'Legacy Brand').first_or_create!
    service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
    service.loop(limit) do |x|
      name = x.get_column('name')
      next if name == nil

      Brand.where(name: name).first_or_create! do |brand|
        brand.legacy_id = x.get_column('manufacturer_id')
        brand.remote_uid = x.get_column('sap_code')
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
      parent_id = x.get_column('parent_id')
      tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code'))
      parent = Category.find_by_legacy_id(parent_id)
      name = x.get_column('name')

      Category.where(name: name).first_or_create! do |category|
        category.assign_attributes(
            remote_uid: x.get_column('sap_code', nil_if_zero: true),
            tax_code: tax_code || TaxCode.default,
            parent: parent,
            description: x.get_column('description'),
            is_service: x.get_column('is_service'),
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
      name = x.get_column('name')
      legacy_id = x.get_column('entity_id')
      sku = x.get_column('sku')
      tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code'))
      next if legacy_id.in? %w(677812 720307 736619 736662 736705)
      next if Product.where(:sku => sku).exists?

      product = Product.where(legacy_id: legacy_id).first_or_create! do |product|
        product.assign_attributes(
            brand: brand,
            category: Category.default,
            sku: sku,
            tax_code: tax_code || TaxCode.default,
            # mpn: x.get_column('mfr_model_number'),
            description: x.get_column('description'),
            meta_description: x.get_column('meta_description'),
            meta_keyword: x.get_column('meta_keyword'),
            meta_title: x.get_column('meta_title'),
            name: name || "noname ##{legacy_id}",
            remote_uid: x.get_column('sap_created') ? x.get_column('sku') : nil,
            measurement_unit: measurement_unit,
            legacy_metadata: x.get_row,
            created_at: x.get_column('created', to_datetime: true),
            updated_at: x.get_column('modified', to_datetime: true),
        )
      end

      product.create_approval(:comment => product.comments.create!(:overseer => Overseer.default, message: 'Legacy product, being preapproved'), :overseer => Overseer.default) if product.approval.blank?
    end
  end

  def product_categories
    service = Services::Shared::Spreadsheets::CsvImporter.new('category_product_mapping.csv')
    service.loop(limit) do |x|
      Product.find_by_legacy_id(x.get_column('product_legacy_id')).update_attributes(:category => Category.find_by_legacy_id(x.get_column('category_legacy_id')))
    end
  end


  def inquiries
    legacy_company = Company.legacy
    opportunity_type = {'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80}
    quote_category = {'bmro' => 10, 'ong' => 20}
    opportunity_source = {1 => 10, 2 => 20, 3 => 30, 4 => 40}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries_without_amazon.csv')
    service.loop(limit) do |x|
      company = Company.find_by_remote_uid(x.get_column('customer_company')) || legacy_company
      contact_legacy_id = x.get_column('customer_id')
      contact_email = x.get_column('email', downcase: true)

      contact = Contact.find_by_legacy_id('contact_legacy_id') || Contact.find_by_email(contact_email) || company.contacts.first
      next if contact.blank?

      if company.industry.blank?
        industry_uid = x.get_column('industry_sap_id')

        if industry_uid
          industry = Industry.find_by_remote_uid(industry_uid)
          company.update_attributes(:industry => industry) if industry.present?
        end
      end

      if company == legacy_company || contact.legacy_id != contact_legacy_id
        shipping_address = company.addresses.first
        billing_address = company.addresses.first
      else
        shipping_address = company.addresses.find_by_legacy_id!(x.get_column('shipping_address'))
        billing_address = company.addresses.find_by_legacy_id!(x.get_column('billing_address'))
      end

      inquiry = Inquiry.where(inquiry_number: x.get_column('increment_id', downcase: true, remove_whitespace: true)).first_or_create! do |inquiry|
        inquiry.assign_attributes(
            company: company,
            contact: contact,
            status: x.get_column('bought').to_i,
            opportunity_type: (opportunity_type[x.get_column('quote_type').gsub(" ", "_").downcase] if x.get_column('quote_type').present?),
            potential_amount: x.get_column('potential_amount'),
            opportunity_source: (opportunity_source[x.get_column('opportunity_source').to_i] if x.get_column('opportunity_source').present?),
            subject: x.get_column('caption'),
            gross_profit_percentage: x.get_column('grossprofitp'),
            inside_sales_owner: Overseer.find_by_username(x.get_column('manager', downcase: true)),
            outside_sales_owner: Overseer.find_by_username(x.get_column('outside', downcase: true)),
            sales_manager: Overseer.find_by_username(x.get_column('powermanager', downcase: true)),
            quote_category: (quote_category[x.get_column('category').downcase] if x.get_column('category').present?),
            billing_address: billing_address || company.addresses.first,
            shipping_address: shipping_address || company.addresses.first,
            opportunity_uid: x.get_column('op_code', nil_if_zero: true),
            customer_po_number: x.get_column('customer_po_id'),
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
            updated_at: x.get_column('update_time', to_datetime: true)
        )
      end

      inquiry.update_attributes!(legacy_bill_to_contact: company.contacts.where('first_name ILIKE ? AND last_name ILIKE ?', "%#{x.get_column('billing_name').split(' ').first}%", "%#{x.get_column('billing_name').split(' ').last}%").first) if x.get_column('billing_name').present? && inquiry.legacy_bill_to_contact_id.blank?
      inquiry.update_attributes!(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_legacy_id(x.get_column('currency')))) && inquiry.inquiry_currency_id.blank?
    end
  end

  def inquiry_terms
    price_type_mapping = {'CIF' => 30, 'CIP Mumbai Airport' => 80, 'DAP' => 50, 'DD' => 90, 'Door Delivery' => 60, 'EXW' => 10, 'FCA Mumbai' => 70, 'FOB' => 20, 'CFR' => 40}
    freight_option_mapping = {'Extra as per Actual' => 20, 'Included' => 10}
    packing_and_forwarding_option_mapping = {'Included' => 10, 'Not Included' => 20}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_terms.csv')
    service.loop(limit) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      next if inquiry.blank?
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
      supplier_uid = x.get_column('sup_code')

      inquiry = Inquiry.find_by_legacy_id!(quotation_id)
      product = Product.find_by_legacy_id!(product_id)

      next if inquiry.blank?

      if product.blank?
        product = Product.where(legacy_id: x.get_column('product_id')).first_or_create! do |product|
          product.assign_attributes(
              name: x.get_column('caption'),
              brand: Brand.legacy,
              category: Category.default,
              sku: x.get_column('sku'),
              description: x.get_column('caption'),
              meta_description: x.get_column('caption'),
              meta_title: x.get_column('caption'),
          )
        end

        product.create_approval(
            :comment => product.comments.create!(
                :overseer => Overseer.default, message: 'Legacy product, being preapproved'
            ),
            :overseer => Overseer.default
        ) if product.approval.blank?
      end

      inquiry_product = InquiryProduct.where(
          inquiry: inquiry,
          product: product,
      ).first_or_create! do |ip|
        ip.assign_attributes(
            sr_no: x.get_column('order'),
            quantity: x.get_column('qty', nil_if_zero: true) || 1,
            bp_catalog_name: x.get_column('caption'),
            bp_catalog_sku: x.get_column('bpcat'),
            legacy_metadata: x.get_row
        )
      end

      # if supplier_uid
      supplier = Company.acts_as_supplier.find_by_remote_uid!(supplier_uid)
      inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(:supplier => supplier).first_or_create! do |ips|
        ips.unit_cost_price = x.get_column('cost')
      end

      quotation_uid = x.get_column('doc_entry')
      sales_quote = inquiry.sales_quote

      if sales_quote.blank? && quotation_uid.present?
        sales_quote = inquiry.sales_quotes.create!({overseer: inquiry.inside_sales_owner, quotation_uid: quotation_uid})
      end

      sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_create do |row|
        row.assign_attributes(
            quantity: x.get_column('qty', nil_if_zero: true) || 1,
            margin_percentage: ((1 - (x.get_column('cost').to_f / x.get_column('price_ht').to_f)) * 100),
            tax_code: TaxCode.find_by_chapter(x.get_column('hsncode')) || nil,
            legacy_applicable_tax: x.get_column('tax_code'),
            legacy_applicable_tax_class: x.get_column('tax_class_id'),
            unit_selling_price: x.get_column('price_ht'),
            converted_unit_selling_price: x.get_column('price_ht'),
            lead_time_option: LeadTimeOption.find_by_name(x.get_column('leadtime'))
        )
      end
      # end
    end
  end

  def sales_order_drafts
    raise

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
      if contact.present?
        company = contact.companies.first
      else
        contact = inquiry.contact
        company = inquiry.company
      end
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
