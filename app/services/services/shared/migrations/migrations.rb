require 'csv'
require 'net/http'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  attr_accessor :limit, :secondary_limit, :custom_methods, :update_if_exists

  def initialize(custom_methods = nil, limit = nil, secondary_limit = nil, update_if_exists: true)
    @custom_methods = custom_methods
    @limit = limit
    @secondary_limit = secondary_limit
    @update_if_exists = update_if_exists
  end

  def call
    methods = if custom_methods.present?
                custom_methods
              elsif Rails.env.production?
                %w(inquiry_attachments)
              elsif Rails.env.development?
                %w(overseers overseers_smtp_config measurement_unit lead_time_option currencies states payment_options industries accounts contacts companies_acting_as_customers company_contacts addresses companies_acting_as_suppliers supplier_contacts supplier_addresses warehouse brands tax_codes categories products inquiries inquiry_terms inquiry_details sales_order_drafts sales_order_items activities inquiry_attachments sales_invoices sales_shipments purchase_orders sales_receipts product_categories)
              end

    PaperTrail.request(enabled: false) do
      methods.each do |method|
        perform_migration(method.to_sym)
      end
    end
  end

  def call_later
    call
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
        'Sales Manager' => :outside_sales_manager,
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
      overseer = Overseer.where(email: x.get_column('email').strip.downcase).first_or_initialize
      password = Devise.friendly_token
      identifier = x.get_column('identifier', downcase: true)
      role_name = roles_mapping[x.get_column('role_name')]
      if overseer.new_record? || update_if_exists
        overseer.parent = Overseer.find_by_first_name(x.get_column('business_head_manager').split(' ')[0])
        overseer.first_name = x.get_column('firstname')
        overseer.last_name = x.get_column('lastname')
        overseer.role = case role_name
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
              end
        overseer.function = x.get_column('user_function')
        overseer.department = x.get_column('user_department')
        overseer.status = status_mapping[x.get_column('is_active')]
        overseer.username = x.get_column('username')
        overseer.mobile = x.get_column('mobile')
        overseer.designation = x.get_column('designation')
        overseer.identifier = identifier
        overseer.geography = x.get_column('user_geography')
        overseer.salesperson_uid = x.get_column('sap_internal_code')
        overseer.employee_uid = x.get_column('employee_id')
        overseer.center_code_uid = x.get_column('user_id')
        overseer.legacy_id = x.get_column('user_id')
        overseer.password = password
        overseer.password_confirmation = password
        overseer.legacy_metadata = x.get_row
        overseer.created_at = x.get_column('created', to_datetime: true)
        overseer.updated_at = x.get_column('modified', to_datetime: true)
        overseer.save!
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
      state = AddressState.where(name: x.get_column('default_name').strip).first_or_initialize
      if state.new_record? || update_if_exists
        state.country_code = x.get_column('country_id')
        state.region_code = x.get_column('code')
        state.region_code_uid = x.get_column('sap_code')
        state.remote_uid = x.get_column('gst_state_code')
        state.legacy_id = x.get_column('region_id')
        state.legacy_metadata = x.get_row
        state.save!
      end
    end
  end

  def payment_options
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
    service.loop(secondary_limit) do |x|
      next if x.get_column('id').in? %w(123 146)
      payment_option = PaymentOption.where(name: x.get_column('value')).first_or_initialize
      if payment_option.new_record? || update_if_exists
        payment_option.remote_uid = x.get_column('group_code', nil_if_zero: true)
        payment_option.legacy_id = x.get_column('id')
        payment_option.credit_limit = x.get_column('credit_limit').to_f
        payment_option.general_discount = x.get_column('general_discount').to_f
        payment_option.load_limit = x.get_column('load_limit').to_f
        payment_option.legacy_metadata = x.get_row
        payment_option.save!
      end
    end
  end

  def industries
    service = Services::Shared::Spreadsheets::CsvImporter.new('industries.csv')
    service.loop(secondary_limit) do |x|
      industry = Industry.where(name: x.get_column('industry_name')).first_or_initialize
      if industry.new_record? || update_if_exists
        industry.remote_uid = x.get_column('industry_sap_id')
        industry.description = x.get_column('industry_description')
        industry.legacy_id = x.get_column('idindustry')
        industry.legacy_metadata = x.get_row
        industry.save!
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
      account = Account.where(name: account_name).first_or_initialize
      if account.new_record? || update_if_exists
        account.remote_uid = x.get_column('sap_id')
        account.name = account_name
        account.alias = account_name.titlecase.split.map(&:first).join
        account.legacy_id = id
        account.account_type = :is_customer
        account.legacy_metadata = x.get_row
        account.created_at = x.get_column('created_at', to_datetime: true)
        account.updated_at = x.get_column('updated_at', to_datetime: true)
        account.save!
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

      contact = Contact.where(email: email).first_or_initialize
      password = Devise.friendly_token
      if contact.new_record? || update_if_exists
        contact.legacy_email = x.get_column('email', downcase: true, remove_whitespace: true),
        contact.account = account
        contact.first_name = first_name
        contact.last_name = last_name
        contact.prefix = x.get_column('prefix')
        contact.designation = x.get_column('designation')
        contact.telephone = x.get_column('telephone')
        contact.mobile = x.get_column('mobile')
        contact.status = status_mapping[x.get_column('is_active').to_s]
        contact.contact_group = contact_group_mapping[x.get_column('group')]
        contact.password = password
        contact.password_confirmation = password
        contact.legacy_id = entity_id
        contact.legacy_metadata = x.get_row
        contact.created_at = x.get_column('created_at', to_datetime: true)
        contact.updated_at = x.get_column('updated_at', to_datetime: true)
        contact.save!
      end
    end
  end

  def companies_acting_as_customers
    legacy_account = Account.legacy
    legacy_company = Company.where(name: "Legacy Company").first_or_create! do |company|
      company.account = legacy_account
      company.remote_uid = 99999999
      company.is_customer = true
      company.is_supplier = true
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
      company = Company.where(name: company_name || alias_name).first_or_initialize
      if company.new_record? || update_if_exists
        inside_sales_owner = Overseer.find_by_email(x.get_column('inside_sales_email'))
        outside_sales_owner = Overseer.find_by_email(x.get_column('outside_sales_email'))
        sales_manager = Overseer.find_by_email(x.get_column('manager_email'))
        payment_option = PaymentOption.find_by_name(x.get_column('payment_term'))

        company.assign_attributes(default_company_contact: CompanyContact.new(company: company, contact: account.contacts.find_by_email(x.get_column('email').strip.downcase))) if x.get_column('email').present?

        company.account = account
        company.industry = Industry.find_by_name(x.get_column('cmp_industry'))
        company.remote_uid = x.get_column('cmp_id')
        company.legacy_email = x.get_column('cmp_email', downcase: true)
        company.default_payment_option = payment_option
        company.inside_sales_owner =  inside_sales_owner
        company.outside_sales_owner = outside_sales_owner
        company.sales_manager = sales_manager
        company.site = x.get_column('cmp_website')
        company.company_type = company_type_mapping[x.get_column('company_type')]
        company.priority = priority_mapping[x.get_column('is_strategic').to_s]
        company.nature_of_business = nature_of_business_mapping[x.get_column('nature_of_business')]
        company.credit_limit = x.get_column('creditlimit', default: 1, to_f: true)
        company.is_msme = is_msme_mapping[x.get_column('msme')]
        company.is_unregistered_dealer = urd_mapping[x.get_column('urd')]
        company.tax_identifier = x.get_column('cmp_gst')
        company.is_customer = true
        company.attachment_uid = x.get_column('attachment_entry')
        company.legacy_id = x.get_column('cmp_id')
        company.pan = x.get_column('cmp_pan')
        company.tan = x.get_column('cmp_tan')
        company.legacy_metadata = x.get_row
        company.save!
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
        
        if company.present?
          company_contact = CompanyContact.find_or_create_by(
            company: company,
            contact: Contact.find_by_email(contact_email),
            remote_uid: x.get_column('sap_id'),
            legacy_metadata: x.get_row
          )
          company.update_attributes(:default_company_contact => company_contact) if company.legacy_metadata['default_contact'] == x.get_column('entity_id')
        end
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
      address = Address.where(legacy_id: x.get_column('idcompany_gstinfo')).first_or_initialize
      if address.new_record? || update_if_exists
        address.remote_uid = x.get_column('idcompany_gstinfo')
        address.company = company
        address.name = company.name
        address.gst = x.get_column('gst_num')
        address.country_code = x.get_column('country')
        address.state = AddressState.find_by_name(x.get_column('state_name')) || legacy_state
        address.state_name = x.get_column('country') != "IN" ? x.get_column('state_name') : nil
        address.city_name = x.get_column('city')
        address.pincode = x.get_column('pincode')
        address.street1 = x.get_column('address')
        #address.street2 = x.get_column('gst_num')
        address.cst = x.get_column('cst_num')
        address.vat = x.get_column('vat_num')
        address.excise = x.get_column('ed_num')
        address.telephone = x.get_column('telephone')
        #address.mobile = x.get_column('gst_num')
        address.gst_type = gst_type[x.get_column('gst_type').to_i]
        address.legacy_metadata = x.get_row
        address.save!
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

      next if x.get_column('sup_id').in? %w(5406)

      company_type_mapping = {'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110}
      is_msme_mapping = {"N" => false, "Y" => true}
      urd_mapping = {"N" => false, "Y" => true}

      company = Company.where(remote_uid: x.get_column('sup_code')).first_or_initialize
      if company.new_record? || update_if_exists
        inside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_person'))
        outside_sales_owner = Overseer.find_by_email(x.get_column('sup_sales_outside'))
        sales_manager = Overseer.find_by_email(x.get_column('sup_sales_manager'))
        payment_option = PaymentOption.find_by_name(x.get_column('payment_terms'))

        company.account = account
        company.name = supplier_name
        company.default_payment_option = payment_option
        company.inside_sales_owner = inside_sales_owner
        company.outside_sales_owner = outside_sales_owner
        company.sales_manager = sales_manager
        company.site = x.get_column('cmp_website')
        company.company_type = (company_type_mapping[x.get_column('sup_type').split(',').first] if x.get_column('sup_type'))
        company.credit_limit = x.get_column('creditlimit', default: 1)
        company.is_msme = is_msme_mapping[x.get_column('msme')]
        company.is_unregistered_dealer = urd_mapping[x.get_column('urd')]
        company.tax_identifier = x.get_column('cmp_gst')
        company.is_supplier = true
        company.is_customer = false
        company.legacy_id = x.get_column('sup_id')
        company.pan = x.get_column('sup_pan')
        company.legacy_metadata = x.get_row
        company.created_at = x.get_column('created_at', to_datetime: true)
        company.updated_at = x.get_column('updated_at', to_datetime: true)
        company.save!
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
      supplier_contact = Contact.where(email: contact_email).first_or_initialize
      if supplier_contact.new_record? || update_if_exists
        password = Devise.friendly_token
        supplier_contact.account = account
        supplier_contact.legacy_email = x.get_column('pc_email', downcase: true, remove_whitespace: true)
        supplier_contact.first_name = x.get_column('pc_firstname', default: 'fname')
        supplier_contact.last_name = x.get_column('pc_lastname', default: 'lname')
        supplier_contact.prefix = x.get_column('prefix')
        supplier_contact.designation = x.get_column('pc_function')
        supplier_contact.telephone = x.get_column('pc_phone')
        supplier_contact.mobile = x.get_column('pc_mobile')
        supplier_contact.status = :active
        supplier_contact.password = password
        supplier_contact.password_confirmation = password
        supplier_contact.legacy_id = x.get_column('pc_num')
        supplier_contact.legacy_metadata = x.get_row
        supplier_contact.save!
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

      next if company.blank? # todo remove
      #next if x.get_column('NULL').nil?

      country_code = x.get_column('country')
      address = Address.where(legacy_id: x.get_column('address_id')).first_or_initialize
      if address.new_record? || update_if_exists
        address.company = company
        address.remote_uid = x.get_column('address_id')
        address.name = company.name
        address.gst = x.get_column('gst_num')
        address.country_code = country_code
        address.state = AddressState.find_by_name(x.get_column('state_name'))
        if !address.state.present?
          address.state = AddressState.find_by_name('Maharashtra')
        end
        address.state_name = country_code == 'IN' ? nil : x.get_column('state_name')
        address.city_name = x.get_column('city')
        address.pincode = x.get_column('pincode')
        address.street1 = x.get_column('address')
        address.cst = x.get_column('cst_num')
        address.vat = x.get_column('vat_num')
        address.excise = x.get_column('ed_num')
        address.telephone = x.get_column('telephone')
        address.gst_type = gst_type_mapping[x.get_column('gst_type').to_i]
        address.legacy_metadata = x.get_row
        address.save!
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
      warehouse = Warehouse.where(:name => x.get_column('Warehouse Name')).first_or_initialize
      if warehouse.new_record? || update_if_exists
        warehouse.remote_uid = x.get_column('Warehouse Code')
        warehouse.legacy_id = x.get_column('Warehouse Code')
        warehouse.location_uid = x.get_column('Location')
        warehouse.remote_branch_name = x.get_column('Warehouse Name')
        warehouse.remote_branch_code = x.get_column('Business Place ID')
        warehouse.legacy_metadata = x.get_row
        warehouse.build_address(
          :name => x.get_column('Account Name'),
          :street1 => x.get_column('Street'),
          :street2 => x.get_column('Block'),
          :pincode => x.get_column('Zip Code'),
          :city_name => x.get_column('City'),
          :country_code => x.get_column('Country'),
          :gst => x.get_column('GST'),
          :state => AddressState.find_by_region_code(x.get_column('State'))
        )
        warehouse.save!
      end
    end
  end

  def brands
    Brand.where(name: 'Legacy Brand').first_or_create!
    service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
    service.loop(limit) do |x|
      name = x.get_column('name')
      next if name == nil
      brand = Brand.where(name: name).first_or_initialize
      if brand.new_record? || update_if_exists
        brand.legacy_id = x.get_column('manufacturer_id')
        brand.remote_uid = x.get_column('sap_code')
        brand.legacy_option_id = x.get_column('option_id')
        brand.legacy_metadata = x.get_row
        brand.save!
      end
    end
  end

  def tax_codes
    service = Services::Shared::Spreadsheets::CsvImporter.new('hsn_codes.csv')
    service.loop(limit) do |x|
      chapter = x.get_column('chapter')
      tax_code = x.get_column('tax_code')

      if chapter && tax_code

        tax = TaxCode.where(legacy_id: x.get_column('idbmro_sap_hsn_mapping')).first_or_initialize
        if tax.new_record? || update_if_exists
          tax.chapter = chapter
          tax.remote_uid = x.get_column('internal_key')
          tax.code = ((x.get_column('hsn') == "NULL") || (x.get_column('hsn') == nil) ? x.get_column('chapter') : x.get_column('hsn').gsub('.', ''))
          tax.description = x.get_column('description')
          tax.is_service = x.get_column('is_service') == 'NULL' ? false : true
          tax.tax_percentage = tax_code.match(/\d+/)[0].to_f
          tax.legacy_metadata = x.get_row
          tax.save!
        end
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
      legacy_id = x.get_column('id')

      category = Category.where(legacy_id: legacy_id).first_or_initialize
      if category.new_record? || update_if_exists
        category.remote_uid = x.get_column('sap_code', nil_if_zero: true)
        category.tax_code = tax_code || TaxCode.default
        category.parent = parent
        category.description = x.get_column('description')
        category.is_service = x.get_column('is_service')
        category.name = name
        category.legacy_metadata = x.get_row
        category.save!
      end
    end
  end

  def products
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    service.loop(limit) do |x|
      brand = Brand.find_by_legacy_option_id(x.get_column('product_brand'))
      measurement_unit = MeasurementUnit.find_by_name(x.get_column('uom_name'))
      name = x.get_column('name')
      legacy_id = x.get_column('entity_id')
      sku = x.get_column('sku')
      tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code'))
      next if legacy_id.in? %w(677812 720307 736619 736662 736705)
      next if Product.where(:sku => sku).exists?

      product = Product.where(legacy_id: legacy_id).first_or_initialize
      if product.new_record? || update_if_exists
        product.brand = brand
        product.category = Category.default
        product.sku = sku
        product.tax_code = tax_code || TaxCode.default
        product.mpn = x.get_column('mfr_model_number')
        product.description = x.get_column('description')
        product.meta_description = x.get_column('meta_description')
        product.meta_keyword = x.get_column('meta_keyword')
        product.meta_title = x.get_column('meta_title')
        product.name = name || "noname ##{legacy_id}"
        product.remote_uid = x.get_column('sap_created') ? x.get_column('sku') : nil
        product.measurement_unit = measurement_unit
        product.weight = x.get_column('weight')
        product.legacy_metadata = x.get_row
        product.created_at = x.get_column('created', to_datetime: true)
        product.updated_at = x.get_column('modified', to_datetime: true)
        product.save!
      end
      product.create_approval(:comment => product.comments.create!(:overseer => Overseer.default, message: 'Legacy product, being preapproved'), :overseer => Overseer.default) if product.approval.blank?
    end
  end

  def product_categories
    service = Services::Shared::Spreadsheets::CsvImporter.new('category_product_mapping.csv')
    service.loop(limit) do |x|
      product = Product.find_by_legacy_id(x.get_column('product_legacy_id'))
      product.update_attributes(:category => Category.find_by_legacy_id(x.get_column('category_legacy_id'))) if product.present?
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

      contact = Contact.find_by_legacy_id(contact_legacy_id) || Contact.find_by_email(contact_email) || company.contacts.first

      if company.industry.blank?
        industry_uid = x.get_column('industry_sap_id')

        if industry_uid
          industry = Industry.find_by_remote_uid(industry_uid)
          company.update_attributes!(:industry => industry) if industry.present?
        end
      end

      if company != legacy_company
        shipping_address = company.account.addresses.find_by_legacy_id(x.get_column('shipping_address')) if ((x.get_column('shipping_address')) != nil)
        billing_address = company.account.addresses.find_by_legacy_id(x.get_column('billing_address')) if ((x.get_column('billing_address')) != nil)
      end

      if company == legacy_company && shipping_address.blank?
        shipping_address = company.addresses.first
      end

      if company == legacy_company && billing_address.blank?
        billing_address = company.addresses.first
      end

      inquiry_number = x.get_column('increment_id', downcase: true, remove_whitespace: true)
      legacy_id = x.get_column('quotation_id', downcase: true, remove_whitespace: true)

      next if ( inquiry_number.nil? || inquiry_number == '0' || inquiry_number == 0)

      inquiry = Inquiry.where(inquiry_number: inquiry_number).first_or_initialize
      if inquiry.new_record? || update_if_exists
        inquiry.company = company
        inquiry.contact = contact
        inquiry.legacy_contact_name = x.get_column('customer_name')
        inquiry.status = x.get_column('bought').to_i
        inquiry.opportunity_type = (opportunity_type[x.get_column('quote_type').gsub(" ", "_").downcase] if x.get_column('quote_type').present?)
        inquiry.potential_amount = x.get_column('potential_amount')
        inquiry.opportunity_source = (opportunity_source[x.get_column('opportunity_source').to_i] if x.get_column('opportunity_source').present?)
        inquiry.subject = x.get_column('caption')
        inquiry.gross_profit_percentage = x.get_column('grossprofitp')
        inquiry.inside_sales_owner = Overseer.find_by_username(x.get_column('manager', downcase: true))
        inquiry.outside_sales_owner = Overseer.find_by_username(x.get_column('outside', downcase: true))
        inquiry.sales_manager = Overseer.find_by_username(x.get_column('powermanager', downcase: true))
        inquiry.quote_category = (quote_category[x.get_column('category').downcase] if x.get_column('category').present?)
        inquiry.billing_address = billing_address
        inquiry.shipping_address = shipping_address
        inquiry.opportunity_uid = x.get_column('op_code', nil_if_zero: true)
        inquiry.customer_po_number = x.get_column('customer_po_id')
        inquiry.legacy_shipping_company = Company.find_by_remote_uid(x.get_column('customer_shipping_company'))
        inquiry.bill_from = Warehouse.find_by_legacy_id(x.get_column('warehouse'))
        inquiry.ship_from = Warehouse.find_by_legacy_id(x.get_column('ship_from_warehouse'))
        inquiry.attachment_uid = x.get_column('attachment_entry')
        inquiry.legacy_id = legacy_id
        inquiry.priority = x.get_column('is_prioritized')
        inquiry.expected_closing_date = x.get_column('closing_date', to_datetime: true)
        inquiry.quotation_date = (x.get_column('quotation_date', to_datetime: true) if x.get_column('quotation_date') != "0000-00-00")
        inquiry.quotation_expected_date = x.get_column('quotation_expected_date', to_datetime: true)
        inquiry.valid_end_time = (x.get_column('valid_end_time', to_datetime: true) if x.get_column('valid_end_time') != "0000-00-00")
        inquiry.quotation_followup_date = x.get_column('quotation_followup_date', to_datetime: true)
        inquiry.customer_order_date = (x.get_column('customer_order_date', to_datetime: true) if x.get_column('customer_order_date') != "0000-00-00")
        inquiry.customer_committed_date = (x.get_column('committed_customer_date', to_datetime: true) if x.get_column('committed_customer_date') != "0000-00-00")
        inquiry.procurement_date = (x.get_column('procurement_date', to_datetime: true) if x.get_column('procurement_date') != "0000-00-00")
        inquiry.is_sez = x.get_column('sez')
        inquiry.is_kit = x.get_column('is_kit')
        inquiry.weight_in_kgs = x.get_column('weight')
        inquiry.legacy_metadata = x.get_row
        inquiry.created_at = x.get_column('created_time', to_datetime: true)
        inquiry.updated_at = x.get_column('update_time', to_datetime: true)
      end
      inquiry.update_attributes!(legacy_bill_to_contact: company.contacts.where('first_name ILIKE ? AND last_name ILIKE ?', "%#{x.get_column('billing_name').split(' ').first}%", "%#{x.get_column('billing_name').split(' ').last}%").first) if x.get_column('billing_name').present? && inquiry.legacy_bill_to_contact_id.blank?
      inquiry.update_attributes!(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_legacy_id(x.get_column('currency')))) if inquiry.inquiry_currency_id.blank?
    end
  end

  def inquiry_terms
    price_type_mapping = {'CIF' => 30, 'CIP Mumbai Airport' => 80, 'DAP' => 50, 'DD' => 60, 'Door Delivery' => 60, 'EXW' => 10, 'FCA Mumbai' => 70, 'FOB' => 20, 'CFR' => 40}
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
      puts "#{x.get_column('quotation_item_id')}"
      #next if (x.get_column('quotation_item_id').to_i < 3189 )
      quotation_id = x.get_column('quotation_id')
      product_id = x.get_column('product_id')
      supplier_uid = x.get_column('sup_code')

      next if quotation_id.in? %w(3529 123 8023)
      inquiry = Inquiry.find_by_legacy_id(quotation_id)
      product = Product.find_by_legacy_id(product_id)
      next if inquiry.blank? || product.blank?

      inquiry_product = InquiryProduct.where(inquiry: inquiry, product: product).first_or_initialize
      if inquiry_product.new_record? || update_if_exists
        inquiry_product.sr_no = x.get_column('order')
        inquiry_product.quantity = x.get_column('qty', nil_if_zero: true) || 1
        inquiry_product.bp_catalog_name = x.get_column('caption')
        inquiry_product.bp_catalog_sku = x.get_column('bpcat')
        inquiry_product.legacy_metadata = x.get_row
        inquiry_product.legacy_id = x.get_column('quotation_item_id')
        inquiry_product.save!
      end

      supplier = Company.acts_as_supplier.find_by_remote_uid(supplier_uid) || Company.legacy
      inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(:supplier => supplier).first_or_initialize
      if inquiry_product_supplier.new_record? || update_if_exists
        inquiry_product_supplier.unit_cost_price = x.get_column('cost')
        inquiry_product_supplier.save!
      end

      quotation_uid = x.get_column('doc_entry')
      sales_quote = inquiry.sales_quote

      if sales_quote.blank?
        inquiry.update_attributes(:quotation_uid => quotation_uid)
        sales_quote = inquiry.sales_quotes.create!({overseer: inquiry.inside_sales_owner})
      end

      if inquiry.status_before_type_cast >= 5
        sales_quote.update_attributes!(:sent_at => sales_quote.created_at)
      end

      row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
      if row.new_record? || update_if_exists
        row.quantity = x.get_column('qty', nil_if_zero: true) || 1
        row.margin_percentage = ((x.get_column('price_ht', to_f: true) == 0 || x.get_column('cost', to_f: true) == 0) ? 0 : ((1 - (x.get_column('cost').to_f / x.get_column('price_ht').to_f)) * 100))
        row.tax_code = TaxCode.find_by_chapter(x.get_column('hsncode')) || nil
        row.legacy_applicable_tax = x.get_column('tax_code')
        row.legacy_applicable_tax_class = x.get_column('tax_class_id')
        row.legacy_applicable_tax_percentage = (x.get_column('tax_code').match(/\d+/)[0].to_f if x.get_column('tax_code').present?)
        row.unit_selling_price = x.get_column('price_ht', to_f: true)
        row.converted_unit_selling_price = x.get_column('price_ht', to_f: true)
        row.lead_time_option = LeadTimeOption.find_by_name(x.get_column('leadtime'))
        row.save!
      end
    end
  end

  def sales_order_drafts
    legacy_request_status_mapping = {'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70}
    remote_status = {'Supplier PO: Request Pending' => 17, 'Supplier PO: Partially Created' => 18, 'Partially Shipped' => 19, 'Partially Invoiced' => 20, 'Partially Delivered: GRN Pending' => 21, 'Partially Delivered: GRN Received' => 22, 'Supplier PO: Created' => 23, 'Shipped' => 24, 'Invoiced' => 25, 'Delivered: GRN Pending' => 26, 'Delivered: GRN Received' => 27, 'Partial Payment Received' => 28, 'Payment Received (Closed)' => 29, 'Cancelled by SAP' => 30, 'Short Close' => 31, 'Processing' => 32, 'Material Ready For Dispatch' => 33, 'Order Deleted' => 70}
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv')
    service.loop(limit) do |x|
      inquiry_number = x.get_column('inquiry_number').to_i
      next if inquiry_number == 11505
      inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
      next if inquiry.blank?

      requested_by = Overseer.find_by_legacy_id!(x.get_column('requested_by')) || Overseer.default

      sales_quote = inquiry.sales_quotes.last
      next if sales_quote.blank?
      sales_order = sales_quote.sales_orders.where(remote_uid: x.get_column('remote_uid')).first_or_initialize
      if sales_order.new_record? || update_if_exists
        sales_order.overseer = requested_by
        sales_order.order_number = x.get_column('order_number')
        sales_order.created_at = x.get_column('requested_time').to_datetime
        sales_order.draft_uid = x.get_column('doc_num')
        sales_order.legacy_request_status = legacy_request_status_mapping[x.get_column('request_status')]
        sales_order.remote_status = remote_status[x.get_column('remote_status')]
        sales_order.legacy_metadata = x.get_row
        sales_order.sent_at = sales_quote.created_at
        sales_order.save!
      end

      product_skus = x.get_column('skus')

      sales_quote.rows.each do |row|
        if product_skus.include? row.product.sku
          sales_order.rows.where(:sales_quote_row => row).first_or_create!
        end
      end

      # todo handle cancellation, etc
      request_status = x.get_column('request_status')

      if !sales_order.approved?
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

  def sales_order_items
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_items.csv')
    service.loop(limit) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order_number'))
      product = Product.find_by_sku(x.get_column('sku'))
      if sales_order.present?
        if product.present?
          sales_order_rows = sales_order.rows.joins(:inquiry_product).where(:inquiry_products => {:product_id => product.id})
          if sales_order_rows.present?
            sales_order_rows.first.update_attributes(quantity: x.get_column('qty_ordered'))
          end
        end
      end
    end
  end

  def activities
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
        contact = inquiry.contact if inquiry.present?
        company = inquiry.company if inquiry.present?
      end
      company_type = company_type_mapping[company.is_supplier ? 'is_supplier' : 'is_customer'] if company.present?
      overseer_legacy_id = x.get_column('overseer_legacy_id')

      overseer_legacy_id = x.get_column('overseer_legacy_id')
      overseer = Overseer.find_by_legacy_id(overseer_legacy_id)

      activity = Activity.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
      if activity.new_record? || update_if_exists
        activity.inquiry = inquiry
        activity.company = company
        activity.contact = contact
        activity.subject = x.get_column('subject')
        activity.company_type = company_type
        activity.purpose = purpose[x.get_column('purpose')]
        activity.activity_type = activity_type[x.get_column('activity')]
        activity.activity_status = activity_status[x.get_column('activitystatus')]
        activity.points_discussed = x.get_column('comment')
        activity.actions_required = x.get_column('actionrequired')
        activity.rference_number = x.get_column('refno')
        activity.created_at = (x.get_column('created_at').to_datetime if x.get_column('created_at').present?)
        activity.legacy_metadata = x.get_row
        activity.created_by = overseer
        activity.updated_by = overseer
        activity.save!
      end
      # ActivityOverseer.create!(activity: activity, overseer: overseer) if overseer_legacy_id.present?
    end
  end


  def inquiry_attachments
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_attachments.csv')
    service.loop(nil) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      next if inquiry.blank?
      sheet_columns = [
          ['calculation_sheet', 'calculation_sheet_path', 'calculation_sheet'],
          ['customer_po_sheet', 'customer_po_sheet_path', 'customer_po_sheet'],
          ['email_attachment', 'email_attachment_path', 'copy_of_email'],
          ['supplier_quote_attachment', 'sqa_path', 'supplier_quotes'],
          ['supplier_quote_attachment_additional', 'sqa_additional_path', 'final_supplier_quote']
      ]

      sheet_columns.each do |file|
        file_url = x.get_column(file[1])
        next if file_url.in? %w(https://bulkmro.com/media/quotation_attachment/tender_order_calc_308.xlsx)
        next if inquiry.send(file[2]).attached?
        begin
          attach_file(inquiry, filename: x.get_column(file[0]), field_name: file[2], file_url: file_url)
        rescue URI::InvalidURIError => e
          puts "Help! #{e} did not migrate."
        end
      end
    end
  end

  def sales_invoices
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_invoice.csv')
    service.loop(limit) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order_number'))
      if sales_order
        sales_invoice = SalesInvoice.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
        if sales_invoice.new_record? || update_if_exists
          sales_invoice.sales_order = sales_order
          sales_invoice.is_legacy = true
          sales_invoice.invoice_number = x.get_column('invoice_number')
          sales_invoice.metadata = x.get_row
          sales_invoice.save!
        end
        attach_file(sales_invoice, filename: x.get_column('original_file_name'), field_name: 'original_invoice', file_url: x.get_column('original_file_path'))
        attach_file(sales_invoice, filename: x.get_column('duplicate_file_name'), field_name: 'duplicate_invoice', file_url: x.get_column('duplicate_file_path'))
        attach_file(sales_invoice, filename: x.get_column('triplicate_file_name'), field_name: 'triplicate_invoice', file_url: x.get_column('triplicate_file_path'))
      end
    end
  end

  def sales_shipments
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_shipment.csv')
    service.loop(limit) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order_number'))
      if sales_order
        sales_shipment = SalesShipment.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
        if sales_shipment.new_record? || update_if_exists
          sales_shipment.sales_order = sales_order
          sales_shipment.is_legacy = true
          sales_shipment.shipment_number = x.get_column('shipment_number')
          sales_shipment.metadata = x.get_row
          sales_shipment.save!
        end
        attach_file(sales_shipment, filename: x.get_column('file_name'), field_name: 'shipment_pdf', file_url: x.get_column('file_path'))
      end
    end
  end

  def purchase_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('purchase_orders.csv')
    errors = []
    service.loop(limit) do |x|
      begin
        inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
        if inquiry
          purchase_order = PurchaseOrder.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
          if purchase_order.new_record? || update_if_exists
            purchase_order.inquiry = inquiry
            purchase_order.is_legacy = true
            purchase_order.po_number = x.get_column('po_number')
            purchase_order.metadata = x.get_row
            purchase_order.save!
          end
          attach_file(purchase_order, filename: x.get_column('file_name'), field_name: 'document', file_url: x.get_column('file_path'))
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('legacy_id')}")
      end
    end
    puts errors
  end

  def sales_receipts
    payment_method = {'banktransfer' => 10, 'Cheque' => 20, 'checkmo' => 30, 'razorpay' => 40, 'free' => 50, 'roundoff' => 60, 'bankcharges' => 70, 'cash' => 80, 'creditnote' => 85, 'writeoff' => 90, 'Transfer Acct' => 95}
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts.csv')
    service.loop(limit) do |x|
      sales_invoice = SalesInvoice.find_by_legacy_id(x.get_column('invoice_legacy_id'))
      sales_receipt = SalesReceipt.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
      if sales_receipt.new_record? || update_if_exists
        sales_receipt.sales_invoice = sales_invoice
        sales_receipt.is_legacy = true
        sales_receipt.remote_reference = x.get_column('remote_reference')
        sales_receipt.metadata = x.get_row
        sales_receipt.payment_method = payment_method[x.get_column('payment_method')]
        sales_receipt.payment_type = 20
        sales_receipt.save!
      end
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_on_account.csv')
    service.loop(limit) do |x|
      company = Company.acts_as_customer.find_by_legacy_id(x.get_column('company'))
      sales_receipt = SalesReceipt.where(legacy_id: x.get_column('legacy_id')).first_or_initialize
      if sales_receipt.new_record? || update_if_exists
        sales_receipt.company = company
        sales_receipt.is_legacy = true
        sales_receipt.remote_reference = x.get_column('remote_reference')
        sales_receipt.metadata = x.get_row
        sales_receipt.payment_method = payment_method[x.get_column('payment_method')]
        sales_receipt.payment_type = 10
        sales_receipt.save!
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
      url = URI.parse(file_url)
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = true
      res = req.request_head(url.path)
      puts "---------------------------------"
      if res.code == '200'
        file = open(file_url)
        inquiry.send(field_name).attach(io: file, filename: filename)
      else
        puts res.code
      end
    end
  end

  def update_addresses_remote_uid
    Addresses.update_all("remote_uid=legacy_uid")
  end
end
