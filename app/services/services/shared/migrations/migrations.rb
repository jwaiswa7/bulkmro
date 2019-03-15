require 'csv'
require 'net/http'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  attr_accessor :limit, :secondary_limit, :custom_methods, :update_if_exists, :folder

  def initialize(custom_methods = nil, limit = nil, secondary_limit = nil, update_if_exists: true, folder: nil)
    @custom_methods = custom_methods
    @limit = limit
    @secondary_limit = secondary_limit
    @update_if_exists = update_if_exists
    @folder = folder
  end

  def generate_csv(array_of_ids, object_type)
    file = "#{Rails.root}/public/#{object_type}_data.csv"
    column_headers = ['ID']
    calculated_total(file, 'w', write_headers: true, headers: column_headers) do |writer|
      array_of_ids.each do |i|
        writer << [i]
      end
    end
  end

  def call
    methods = if custom_methods.present?
                custom_methods
              elsif Rails.env.production?
                %w(inquiry_attachments)
              elsif Rails.env.development?
                %w(overseers overseers_smtp_config measurement_unit lead_time_option currencies states payment_options industries accounts contacts companies_acting_as_customers company_contacts addresses companies_acting_as_suppliers supplier_contacts supplier_addresses warehouse brands tax_codes categories products inquiries inquiry_terms inquiry_details sales_order_drafts sales_order_items activities inquiry_attachments sales_invoices sales_shipments purchase_orders sales_receipts product_categories update_purchase_orders)
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
    Overseer.where(email: 'ashwin.goyal@bulkmro.com').first_or_create! do |overseer|
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
        'Sales Manager' => :outside_sales_team_leader,
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

    service = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv', folder)
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
                            :inside_sales_executive
                          elsif identifier == 'outside'
                            :outside_sales_executive
                          elsif identifier == 'outside/manager'
                            :outside_sales_team_leader
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

      overseer.update_attributes(parent: Overseer.find_by_first_name(actual_business_head.split(' ')[0]))
    end
  end

  def overseers_smtp_config
    service = Services::Shared::Spreadsheets::CsvImporter.new('smtp_conf.csv', folder)
    service.loop(secondary_limit) do |x|
      email = x.get_column('email')
      next if email.in? %w(shailesh.salekar@bulkmro.com service@bulkmro.com)
      overseer = Overseer.find_by_email!(email)
      overseer.update_attributes(smtp_password: x.get_column('password'))
    end
  end


  def measurement_unit
    measurement_units = ['EA', 'SET', 'PK', 'KG', 'M', 'FT', 'Pack', 'Pair', 'PR', 'BOX', 'LTR', 'LT', 'MTR', 'ROLL', 'Nos', 'PKT', 'REEL', 'FEET', 'Meter', '1 ROLL', 'ml', 'MAT', 'LOT', 'No', 'RFT', 'Bundle', 'NPkt', 'Metre', 'CAN', 'SQ.Ft', 'BOTTLE', 'BOTTEL', 'CUBIC METER', 'PC', 'GRAM', 'EACH', 'FOOT', 'Dozen', 'INCH', 'Ream', 'Bag', 'Unit', 'MT', 'KIT', 'SQ INCH', 'CASE']
    MeasurementUnit.first_or_create! measurement_units.map {|mu| {name: mu}}
  end

  def lead_time_option
    LeadTimeOption.first_or_create!([
                                        {name: '2-3 DAYS', min_days: 2, max_days: 3},
                                        {name: '1 WEEK', min_days: 7, max_days: 7},
                                        {name: '8-10 DAYS', min_days: 8, max_days: 10},
                                        {name: '1-2 WEEKS', min_days: 7, max_days: 14},
                                        {name: '2 WEEKS', min_days: 14, max_days: 14},
                                        {name: '2-3 WEEK', min_days: 14, max_days: 21},
                                        {name: '3 WEEKS', min_days: 21, max_days: 21},
                                        {name: '3-4 WEEKS', min_days: 21, max_days: 28},
                                        {name: '4 WEEKS', min_days: 28, max_days: 28},
                                        {name: '5 WEEKS', min_days: 35, max_days: 35},
                                        {name: '4-6 WEEKS', min_days: 28, max_days: 42},
                                        {name: '6-8 WEEKS', min_days: 42, max_days: 56},
                                        {name: '8 WEEKS', min_days: 56, max_days: 56},
                                        {name: '20 WEEKS', min_days: 140, max_days: 140},
                                        {name: '24 WEEKS', min_days: 168, max_days: 168},
                                        {name: '6-10 WEEKS', min_days: 42, max_days: 70},
                                        {name: '10-12 WEEKS', min_days: 70, max_days: 84},
                                        {name: '12-14 WEEKS', min_days: 84, max_days: 98},
                                        {name: '14-16 WEEKS', min_days: 98, max_days: 112},
                                        {name: 'MORE THAN 14 WEEKS', min_days: 98, max_days: nil},
                                        {name: 'MORE THAN 12 WEEKS', min_days: 84, max_days: nil},
                                        {name: 'MORE THAN 6 WEEKS', min_days: 42, max_days: nil},
                                        {name: '60 days from the date of order for 175MT, and 60 days for remaining from the date of call', min_days: 60, max_days: 120},
                                        {name: 'In Stock', min_days: 0, max_days: 0},
                                        {name: 'Refer T&C', min_days: 0, max_days: 0}
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('industries.csv', folder)
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
    Account.where(remote_uid: 101, name: 'Trade', alias: 'TRD', account_type: :is_supplier).first_or_create!
    Account.where(remote_uid: 102, name: 'Non-Trade', alias: 'NTRD', account_type: :is_supplier).first_or_create!

    Account.where(name: 'Legacy Account').first_or_create! do |account|
      account.remote_uid = 99999999
      account.alias = 'LGA'
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv', folder)
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
        account.created_at = x.get_column('created_at', to_datetime: true) if x.get_column('created_at').present?
        account.updated_at = x.get_column('updated_at', to_datetime: true) if x.get_column('updated_at').present?
        account.save!
      end
    end
  end

  def contacts
    password = Devise.friendly_token
    Contact.where(email: 'legacy@bulkmro.com').first_or_create! do |contact|
      contact.assign_attributes(account: Account.legacy, first_name: 'Fake', last_name: 'Name', telephone: '9999999999', password: password, password_confirmation: password)
    end

    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv', folder)

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
    legacy_company = Company.where(name: 'Legacy Company').first_or_create! do |company|
      company.account = legacy_account
      company.remote_uid = 99999999
      company.is_customer = true
      company.is_supplier = true
    end

    company_contact = CompanyContact.first_or_create!(company: legacy_company, contact: legacy_account.contacts.first)
    legacy_company.company_contacts << company_contact
    legacy_company.update_attributes(default_company_contact: company_contact)

    service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv', folder)
    service.loop(limit) do |x|
      id = x.get_column('Magento Id')
      # next if id.in? %w(3275)

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
        company.inside_sales_owner = inside_sales_owner
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contact_mapping.csv', folder)

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      company_id = x.get_column('cmp_id')
      # next if company_id.in? %w(1764)

      contact_email = x.get_column('email', downcase: true)
      if contact_email && company_name
        company = Company.acts_as_customer.find_by_name(company_name)

        if company.present?
          company_contact = CompanyContact.where(company: company, contact: Contact.find_by_email(contact_email)).first_or_initialize
          company_contact.remote_uid = x.get_column('sap_id')
          company_contact.legacy_metadata = x.get_row
          company_contact.save!
          if company.legacy_metadata.present?
            company.update_attributes(default_company_contact: company_contact) if company.legacy_metadata['default_contact'] == x.get_column('entity_id')
          end
        end
      end
    end
  end

  def addresses
    legacy_state = AddressState.where(name: 'Legacy Indian State', country_code: 'IN').first_or_create
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv', folder)
    gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    legacy_company = Company.legacy
    legacy_company.addresses.where(name: 'Legacy Address').first_or_create! do |address|
      address.assign_attributes(
          gst: '2AAAAAAAAAAAAAA',
          country_code: 'IN',
          state: AddressState.find_by_name('Maharashtra'),
          state_name: nil,
          city_name: 'Mumbai',
          pincode: '400001',
          street1: 'Lower Parel'
      )
    end

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      legacy_id = x.get_column('cmp_id')

      next if legacy_id.in? %w(1764)
      company = Company.acts_as_customer.find_by_name(company_name)
      # company = Company.find_by_legacy_id!(legacy_id)
      address = Address.where(legacy_id: x.get_column('idcompany_gstinfo')).first_or_initialize
      if address.new_record? || update_if_exists
        address.remote_uid = x.get_column('idcompany_gstinfo')
        address.company = company
        address.name = company.name
        address.gst = x.get_column('gst_num')
        address.country_code = x.get_column('country')
        address.state = AddressState.find_by_name(x.get_column('state_name')) || legacy_state
        address.state_name = x.get_column('country') != 'IN' ? x.get_column('state_name') : nil
        address.city_name = x.get_column('city')
        address.pincode = x.get_column('pincode')
        address.street1 = x.get_column('address')
        # address.street2 = x.get_column('gst_num')
        address.cst = x.get_column('cst_num')
        address.vat = x.get_column('vat_num')
        address.excise = x.get_column('ed_num')
        address.telephone = x.get_column('telephone')
        # address.mobile = x.get_column('gst_num')
        address.gst_type = gst_type[x.get_column('gst_type').to_i]
        address.legacy_metadata = x.get_row
        address.save!
      end

      address.update_attributes(
          billing_address_uid: x.get_column('sap_row_num').split(',')[0],
          shipping_address_uid: x.get_column('sap_row_num').split(',')[1],
      ) if x.get_column('sap_row_num').present?

      if company.legacy_metadata.present?
        if company.legacy_metadata['default_billing'] == x.get_column('idcompany_gstinfo')
          company.default_billing_address = address
        end

        if company.legacy_metadata['default_shipping'] == x.get_column('idcompany_gstinfo')
          company.default_shipping_address = address
        end
      end
      company.save!
    end
  end

  def companies_acting_as_suppliers
    supplier_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers.csv', folder)
    supplier_service.loop(limit) do |x|
      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      supplier_name = x.get_column('sup_name')

      next if x.get_column('sup_id').in? %w(5406)

      company_type_mapping = {'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110}
      is_msme_mapping = {'N' => false, 'Y' => true}
      urd_mapping = {'N' => false, 'Y' => true}

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
    service = Services::Shared::Spreadsheets::CsvImporter.new('supplier_contacts.csv', folder)

    service.loop(limit) do |x|
      supplier_remote_uid = x.get_column('sup_code')
      next if supplier_remote_uid.in? ['SC-9192', 'SC-9195', 'SC-9201', 'SC-9202', 'SC-9205', 'SC-9206', 'SC-9207']

      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      entity_id = x.get_column('pc_num')
      next if supplier_remote_uid.blank?

      supplier_name = x.get_column('sup_name')
      contact_email = x.get_column('pc_email', downcase: true, remove_whitespace: true)
      contact_email = [entity_id, '@bulkmro.com'].join if !contact_email.present? || contact_email.match(Devise.email_regexp).blank?

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
    supplier_address_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers_address.csv', folder)
    gst_type_mapping = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60}

    supplier_address_service.loop(limit) do |x|
      company = Company.acts_as_supplier.find_by_legacy_id(x.get_column('cmp_id'))

      next if company.blank? # todo remove
      # next if x.get_column('NULL').nil?

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
    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses.csv', folder)
    service.loop(limit) do |x|
      warehouse = Warehouse.where(name: x.get_column('Warehouse Name')).first_or_initialize
      if warehouse.new_record? || update_if_exists
        warehouse.remote_uid = x.get_column('Warehouse Code')
        warehouse.legacy_id = x.get_column('Warehouse Code')
        warehouse.location_uid = x.get_column('Location')
        warehouse.remote_branch_name = x.get_column('Warehouse Name')
        warehouse.remote_branch_code = x.get_column('Business Place ID')
        warehouse.legacy_metadata = x.get_row
        warehouse.build_address(
            name: x.get_column('Account Name'),
            street1: x.get_column('Street'),
            street2: x.get_column('Block'),
            pincode: x.get_column('Zip Code'),
            city_name: x.get_column('City'),
            country_code: x.get_column('Country'),
            gst: x.get_column('GST'),
            state: AddressState.find_by_region_code(x.get_column('State'))
        )
        warehouse.save!
      end
    end
  end

  def brands
    Brand.where(name: 'Legacy Brand').first_or_create!
    service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('hsn_codes.csv', folder)
    service.loop(limit) do |x|
      chapter = x.get_column('chapter')
      tax_code = x.get_column('tax_code')

      if chapter && tax_code

        tax = TaxCode.where(legacy_id: x.get_column('idbmro_sap_hsn_mapping')).first_or_initialize
        if tax.new_record? || update_if_exists
          tax.chapter = chapter
          tax.remote_uid = x.get_column('internal_key')
          tax.code = ((x.get_column('hsn') == 'NULL') || (x.get_column('hsn') == nil) ? x.get_column('chapter') : x.get_column('hsn').gsub('.', ''))
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('categories.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv', folder)
    service.loop(limit) do |x|
      brand = Brand.find_by_legacy_option_id(x.get_column('product_brand'))
      measurement_unit = MeasurementUnit.find_by_name(x.get_column('uom_name'))
      name = x.get_column('name')
      legacy_id = x.get_column('entity_id')
      sku = x.get_column('sku')
      tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code'))
      next if legacy_id.in? %w(677812 720307 736619 736662 736705)
      next if Product.where(sku: sku).exists?

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
      product.create_approval(comment: product.comments.create!(overseer: Overseer.default, message: 'Legacy product, being preapproved'), overseer: Overseer.default) if product.approval.blank?
    end
  end

  def product_categories
    service = Services::Shared::Spreadsheets::CsvImporter.new('category_product_mapping.csv', folder)
    service.loop(limit) do |x|
      product = Product.find_by_legacy_id(x.get_column('product_legacy_id'))
      product.update_attributes(category: Category.find_by_legacy_id(x.get_column('category_legacy_id'))) if product.present?
    end
  end

  def inquiries
    legacy_company = Company.legacy
    opportunity_type = {'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80}
    quote_category = {'bmro' => 10, 'ong' => 20}
    opportunity_source = {1 => 10, 2 => 20, 3 => 30, 4 => 40}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries.csv', folder)
    service.loop(limit) do |x|
      company = Company.find_by_name(x.get_column('cmp_name')) || legacy_company
      contact_legacy_id = x.get_column('customer_id')
      contact_email = x.get_column('email', downcase: true)

      contact = Contact.find_by_legacy_id(contact_legacy_id) || Contact.find_by_email(contact_email) || company.contacts.first

      if company.industry.blank?
        industry_uid = x.get_column('industry_sap_id')

        if industry_uid
          industry = Industry.find_by_remote_uid(industry_uid)
          company.update_attributes!(industry: industry) if industry.present?
        end
      end

      if company != legacy_company
        shipping_address = company.account.addresses.find_by_legacy_id(x.get_column('shipping_address')) if (x.get_column('shipping_address')) != nil
        billing_address = company.account.addresses.find_by_legacy_id(x.get_column('billing_address')) if (x.get_column('billing_address')) != nil
      end

      if company == legacy_company && shipping_address.blank?
        shipping_address = company.addresses.first
      end

      if company == legacy_company && billing_address.blank?
        billing_address = company.addresses.first
      end

      inquiry_number = x.get_column('increment_id', downcase: true, remove_whitespace: true)
      legacy_id = x.get_column('quotation_id', downcase: true, remove_whitespace: true)

      next if inquiry_number.nil? || inquiry_number == '0' || inquiry_number == 0

      inquiry = Inquiry.where(inquiry_number: inquiry_number).first_or_initialize
      if inquiry.new_record? || update_if_exists
        inquiry.company = company
        inquiry.contact = contact
        inquiry.legacy_contact_name = x.get_column('customer_name')
        inquiry.status = x.get_column('bought').to_i
        inquiry.opportunity_type = (opportunity_type[x.get_column('quote_type').gsub(' ', '_').downcase] if x.get_column('quote_type').present?)
        inquiry.potential_amount = x.get_column('potential_amount')
        inquiry.opportunity_source = (opportunity_source[x.get_column('opportunity_source').to_i] if x.get_column('opportunity_source').present?)
        inquiry.subject = x.get_column('caption')
        inquiry.gross_profit_percentage = x.get_column('grossprofitp')
        inquiry.inside_sales_owner = Overseer.find_by_username(x.get_column('manager', downcase: true))
        inquiry.outside_sales_owner = Overseer.find_by_username(x.get_column('outside', downcase: true))
        inquiry.sales_manager = Overseer.find_by_username(x.get_column('powermanager', downcase: true))
        inquiry.quote_category = (quote_category[x.get_column('category').downcase] if x.get_column('category').present?)
        inquiry.billing_company = company
        inquiry.shipping_company = company
        inquiry.shipping_contact = contact
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
        inquiry.quotation_date = (x.get_column('quotation_date', to_datetime: true) if x.get_column('quotation_date') != '0000-00-00')
        inquiry.quotation_expected_date = x.get_column('quotation_expected_date', to_datetime: true)
        inquiry.valid_end_time = (x.get_column('valid_end_time', to_datetime: true) if x.get_column('valid_end_time') != '0000-00-00')
        inquiry.quotation_followup_date = x.get_column('quotation_followup_date', to_datetime: true)
        inquiry.customer_order_date = (x.get_column('customer_order_date', to_datetime: true) if x.get_column('customer_order_date') != '0000-00-00')
        inquiry.customer_committed_date = (x.get_column('committed_customer_date', to_datetime: true) if x.get_column('committed_customer_date') != '0000-00-00')
        inquiry.procurement_date = (x.get_column('procurement_date', to_datetime: true) if x.get_column('procurement_date') != '0000-00-00')
        inquiry.is_sez = x.get_column('sez')
        inquiry.is_kit = x.get_column('is_kit')
        inquiry.weight_in_kgs = x.get_column('weight')
        inquiry.legacy_metadata = x.get_row
        inquiry.created_at = x.get_column('created_time', to_datetime: true)
        inquiry.updated_at = x.get_column('update_time', to_datetime: true)
        inquiry.save!
      end
      inquiry.update_attributes!(legacy_bill_to_contact: company.contacts.where('first_name ILIKE ? AND last_name ILIKE ?', "%#{x.get_column('billing_name').split(' ').first}%", "%#{x.get_column('billing_name').split(' ').last}%").first) if x.get_column('billing_name').present? && inquiry.legacy_bill_to_contact_id.blank?
      inquiry.update_attributes!(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_legacy_id(x.get_column('currency')))) if inquiry.inquiry_currency_id.blank?
    end
  end

  def legacy_inquiries
    errors = []
    opportunity_type = {'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80}
    quote_category = {'bmro' => 10, 'ong' => 20}
    opportunity_source = {1 => 10, 2 => 20, 3 => 30, 4 => 40}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries_without_amazon.csv', folder)
    service.loop(limit) do |x|
      start_date = Date.new(2018, 04, 01)
      inquiry_updated_date = Date.new(2018, 10, 19)

      next if x.get_column('created_time', to_datetime: true) < start_date

      company = Company.find_by_remote_uid(x.get_column('customer_company'))
      contact_legacy_id = x.get_column('customer_id')
      contact_email = x.get_column('email', downcase: true)

      contact = Contact.find_by_legacy_id(contact_legacy_id) || Contact.find_by_email(contact_email) || company.contacts.first

      # if company.industry.blank?
      #   industry_uid = x.get_column('industry_sap_id')
      #
      #   if industry_uid
      #     industry = Industry.find_by_remote_uid(industry_uid)
      #     company.update_attributes!(:industry => industry) if industry.present?
      #   end
      # end


      shipping_address = company.account.addresses.find_by_legacy_id(x.get_column('shipping_address')) if (x.get_column('shipping_address')) != nil
      billing_address = company.account.addresses.find_by_legacy_id(x.get_column('billing_address')) if (x.get_column('billing_address')) != nil


      # if company == legacy_company && shipping_address.blank?
      #   shipping_address = company.addresses.first
      # end
      #
      # if company == legacy_company && billing_address.blank?
      #   billing_address = company.addresses.first
      # end

      inquiry_number = x.get_column('increment_id', downcase: true, remove_whitespace: true)
      legacy_id = x.get_column('quotation_id', downcase: true, remove_whitespace: true)

      # next if (inquiry_number.nil? || inquiry_number == '0' || inquiry_number == 0)

      inquiry = Inquiry.where(inquiry_number: inquiry_number).first_or_initialize

      next if inquiry.updated_at > inquiry_updated_date

      if inquiry.new_record? || update_if_exists
        inquiry.company = company
        inquiry.contact = contact
        inquiry.legacy_contact_name = x.get_column('customer_name')
        inquiry.status = x.get_column('bought').to_i
        inquiry.opportunity_type = (opportunity_type[x.get_column('quote_type').gsub(' ', '_').downcase] if x.get_column('quote_type').present?)
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
        inquiry.quotation_date = (x.get_column('quotation_date', to_datetime: true) if x.get_column('quotation_date') != '0000-00-00')
        inquiry.quotation_expected_date = x.get_column('quotation_expected_date', to_datetime: true)
        inquiry.valid_end_time = (x.get_column('valid_end_time', to_datetime: true) if x.get_column('valid_end_time') != '0000-00-00')
        inquiry.quotation_followup_date = x.get_column('quotation_followup_date', to_datetime: true)
        inquiry.customer_order_date = (x.get_column('customer_order_date', to_datetime: true) if x.get_column('customer_order_date') != '0000-00-00')
        inquiry.customer_committed_date = (x.get_column('committed_customer_date', to_datetime: true) if x.get_column('committed_customer_date') != '0000-00-00')
        inquiry.procurement_date = (x.get_column('procurement_date', to_datetime: true) if x.get_column('procurement_date') != '0000-00-00')
        inquiry.is_sez = x.get_column('sez')
        inquiry.is_kit = x.get_column('is_kit')
        inquiry.weight_in_kgs = x.get_column('weight')
        inquiry.legacy_metadata = x.get_row
        inquiry.created_at = x.get_column('created_time', to_datetime: true)
        inquiry.updated_at = x.get_column('update_time', to_datetime: true)
        inquiry.save!
      end
      inquiry.update_attributes!(legacy_bill_to_contact: company.contacts.where('first_name ILIKE ? AND last_name ILIKE ?', "%#{x.get_column('billing_name').split(' ').first}%", "%#{x.get_column('billing_name').split(' ').last}%").first) if x.get_column('billing_name').present? && inquiry.legacy_bill_to_contact_id.blank?
      inquiry.update_attributes!(inquiry_currency: InquiryCurrency.create!(inquiry: inquiry, currency: Currency.find_by_legacy_id(x.get_column('currency')))) if inquiry.inquiry_currency_id.blank?
    end
  end

  def inquiry_terms
    price_type_mapping = {'CIF' => 30, 'CIP Mumbai Airport' => 80, 'DAP' => 50, 'DD' => 60, 'Door Delivery' => 60, 'EXW' => 10, 'FCA Mumbai' => 70, 'FOB' => 20, 'CFR' => 40}
    freight_option_mapping = {'Extra as per Actual' => 20, 'Included' => 10}
    packing_and_forwarding_option_mapping = {'Included' => 10, 'Not Included' => 20}

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_terms.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_items.csv', folder)
    service.loop(limit) do |x|
      puts "#{x.get_column('quotation_item_id')}"
      # next if (x.get_column('quotation_item_id').to_i < 3189 )
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
      inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(supplier: supplier).first_or_initialize
      if inquiry_product_supplier.new_record? || update_if_exists
        inquiry_product_supplier.unit_cost_price = x.get_column('cost').try(:to_i) || 0
        inquiry_product_supplier.save!
      end

      quotation_uid = x.get_column('doc_entry')
      sales_quote = inquiry.sales_quote

      if sales_quote.blank?
        inquiry.update_attributes(quotation_uid: quotation_uid)
        sales_quote = inquiry.sales_quotes.create!(overseer: inquiry.inside_sales_owner)
      end

      if inquiry.status_before_type_cast >= 5
        sales_quote.update_attributes!(sent_at: sales_quote.created_at)
      end

      row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
      if row.new_record? || update_if_exists
        row.measurement_unit = MeasurementUnit.default
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv', folder)
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
          sales_order.rows.where(sales_quote_row: row).first_or_create!
        end
      end

      # todo handle cancellation, etc
      request_status = x.get_column('request_status')

      if !sales_order.approved?
        if request_status.in? %w(approved requested)
          sales_order.create_approval(
              comment: sales_order.inquiry.comments.create!(overseer: Overseer.default, message: 'Legacy sales order, being preapproved'),
              overseer: Overseer.default,
              metadata: Serializers::InquirySerializer.new(sales_order.inquiry)
          )
        elsif request_status == 'rejected'
          sales_order.create_rejection(
              comment: sales_order.inquiry.comments.create!(overseer: Overseer.default, message: 'Legacy sales order, being rejected'),
              overseer: Overseer.default
          )
        else
          sales_order.inquiry.comments.create(overseer: Overseer.default, message: "Legacy sales order, being #{request_status}")
        end
      end
    end
  end

  def sales_order_items
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_items.csv', folder)
    service.loop(limit) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order_number'))
      product = Product.find_by_sku(x.get_column('sku'))
      if sales_order.present?
        if product.present?
          sales_order_rows = sales_order.rows.joins(:inquiry_product).where(inquiry_products: {product_id: product.id})
          if sales_order_rows.present?
            if sales_order.id == 3195
              sales_order_rows.first.update_attributes!(quantity: 1)
            else
              sales_order_rows.first.update_attributes!(quantity: x.get_column('qty_ordered'))
            end
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

    service = Services::Shared::Spreadsheets::CsvImporter.new('activity_reports.csv', folder)
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
        activity.purpose = purpose[x.get_column('purpose')] || :'Others'
        activity.activity_type = activity_type[x.get_column('activity')]
        activity.activity_status = activity_status[x.get_column('activitystatus')]
        activity.points_discussed = x.get_column('comment')
        activity.actions_required = x.get_column('actionrequired')
        activity.reference_number = x.get_column('refno')
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_attachments.csv', folder)
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
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_invoice.csv', folder)
    service.loop(limit) do |x|
      next if x.get_column('order_number') != 2003414
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
        attach_file(sales_invoice, filename: x.get_column('original_file_name'), field_name: 'original_invoice', file_url: x.get_column('original_file_path')) if !sales_invoice.original_invoice.attached?
        attach_file(sales_invoice, filename: x.get_column('duplicate_file_name'), field_name: 'duplicate_invoice', file_url: x.get_column('duplicate_file_path')) if !sales_invoice.duplicate_invoice.attached?
        attach_file(sales_invoice, filename: x.get_column('triplicate_file_name'), field_name: 'triplicate_invoice', file_url: x.get_column('triplicate_file_path')) if !sales_invoice.triplicate_invoice.attached?
      end
    end
  end

  def sales_shipments
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_shipment.csv', folder)
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
        attach_file(sales_shipment, filename: x.get_column('file_name'), field_name: 'shipment_pdf', file_url: x.get_column('file_path')) if !sales_shipment.shipment_pdf.attached?
      end
    end
  end

  def purchase_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('purchase_orders.csv', folder)
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
          attach_file(purchase_order, filename: x.get_column('file_name'), field_name: 'document', file_url: x.get_column('file_path')) if !purchase_order.document.attached?
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('legacy_id')}")
      end
    end
    puts errors
  end

  def sales_receipts
    payment_method = {'banktransfer' => 10, 'Cheque' => 20, 'checkmo' => 30, 'razorpay' => 40, 'free' => 50, 'roundoff' => 60, 'bankcharges' => 70, 'cash' => 80, 'creditnote' => 85, 'writeoff' => 90, 'Transfer Acct' => 95}
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts.csv', folder)
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

    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_receipts_on_account.csv', folder)
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

  def update_created_po_requests_with_no_po_order
    po_requests = PoRequest.where(status: 'PO Created', purchase_order_id: nil)
    po_requests.each do |po_request|
      if !po_request.purchase_order_number.present?
        po_request.status = 'Cancelled'
        po_request.comments.create(message: 'Migration Cancelled: Status was PO created but PO number not assigned to PO requests', overseer: Overseer.default)
      end
    end
  end

  def update_existing_po_requests_with_purchase_order
    PoRequest.where.not(status: ['PO Created', 'Requested', 'Cancelled']).update_all(status: 'Cancelled')
    skips = [47, 50, 83, 86, 12, 64, 72]
    PoRequest.where.not(purchase_order_id: nil).each do |po_request|
      next if skips.include?(po_request.id)
      if po_request.status != 'Cancelled'
        next if !po_request.sales_order.present?
        rows = po_request.sales_order.rows.inject({}) {|hash, row| ; hash[row.sales_quote_row.product.sku] = row.id; hash}
        if po_request.status != 'Requested'
          if !po_request.status != 'PO Created'
            purchase_order = po_request.purchase_order || PurchaseOrder.find_by_po_number(po_request.purchase_order_id)
            if purchase_order.present?
              service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: purchase_order.inquiry.company.name)
              purchase_order.rows.each do |line_item|
                product_sku = line_item.sku
                if rows[product_sku] != nil
                  row = po_request.sales_order.rows.find(rows[product_sku])
                  quantity = line_item.metadata['PopQty'].present? ? line_item.metadata['PopQty'].to_i : row.quantity
                  if po_request.purchase_order.blank?
                    if row.supplier.blank? || row.supplier.addresses.blank?
                      po_request.is_legacy = true
                      po_request.save(validate: false)
                      next
                    end
                    if purchase_order.po_request.present?
                      po_request.update!(status: 'Cancelled')
                    else
                      po_request.update!(supplier_id: row.supplier.id, purchase_order: purchase_order, bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: purchase_order.inquiry.bill_from_id, ship_to_id: purchase_order.inquiry.ship_from_id, logistics_owner: service.call, is_legacy: true)
                    end
                  else
                    if row.supplier.blank? || row.supplier.addresses.blank?
                      po_request.is_legacy = true
                      po_request.save(validate: false)
                      next
                    end
                    po_request.update!(supplier_id: row.supplier.id, bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: purchase_order.inquiry.bill_from_id, ship_to_id: purchase_order.inquiry.ship_from_id, is_legacy: true)
                    po_request.rows.where(sales_order_row_id: row.id, quantity: quantity, product_id: row.product.id, brand_id: row.product.try(:brand_id), tax_code: row.tax_code, tax_rate: row.best_tax_rate, measurement_unit: row.measurement_unit).first_or_create!
                  end
                end
              end
            end
          end
        else
          service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: po_request.sales_order.inquiry.company.name)
          po_request.sales_order.rows.each do |row|
            if row.supplier.blank? || row.supplier.addresses.blank?
              po_request.is_legacy = true
              po_request.save(validate: false)
              next
            end
            po_request.update!(supplier_id: row.supplier.id, bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: po_request.sales_order.inquiry.bill_from_id, ship_to_id: po_request.sales_order.inquiry.ship_from_id, logistics_owner: service.call, is_legacy: true)
            po_request.rows.where(sales_order_row_id: row.id, quantity: row.quantity).first_or_create!
          end
        end
      end
    end
  end

  def create_po_request_for_purchase_orders
    SalesOrder.remote_approved.each do |sales_order|
      rows = sales_order.rows.inject({}) {|hash, row| ; hash[row.sales_quote_row.product.sku] = row.id; hash}
      # service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: sales_order.inquiry.company.name)
      sales_order.inquiry.purchase_orders.each do |purchase_order|
        if purchase_order.rows.present?
          purchase_order.rows.each do |line_item|
            product_sku = line_item.sku
            if rows[product_sku] != nil
              row = sales_order.rows.find(rows[product_sku])
              if row.supplier.present? && row.supplier.addresses.present?
                quantity = line_item.metadata['PopQty'].present? ? line_item.metadata['PopQty'].to_i : row.quantity
                if purchase_order.po_request.blank?
                  po_request = PoRequest.where(sales_order_id: sales_order.id, inquiry_id: sales_order.inquiry.id, supplier_id: row.supplier_id, status: 'PO Created', purchase_order_id: purchase_order.id, bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: sales_order.inquiry.bill_from_id || Warehouse.default.id, ship_to_id: sales_order.inquiry.ship_from_id || Warehouse.default.id, is_legacy: true).first_or_create!
                else
                  po_request = PoRequest.where(sales_order_id: sales_order.id, inquiry_id: sales_order.inquiry.id, status: 'PO Created').first
                  if po_request
                    po_request.update_attributes(sales_order_id: sales_order.id, inquiry_id: sales_order.inquiry.id, supplier_id: row.supplier_id, status: 'PO Created', purchase_order_id: purchase_order.id, bill_from_id: row.supplier.addresses.first.id, ship_from_id: row.supplier.addresses.first.id, bill_to_id: sales_order.inquiry.bill_from_id || Warehouse.default.id, ship_to_id: sales_order.inquiry.ship_from_id || Warehouse.default.id, is_legacy: true)
                  end
                end
                po_request.rows.create!(sales_order_row_id: row.id, quantity: quantity, product_id: row.product.id, brand_id: row.product.try(:brand_id), tax_code: row.tax_code, tax_rate: row.best_tax_rate, measurement_unit: row.measurement_unit) if po_request
              else
                po_request = PoRequest.where(sales_order_id: sales_order.id, inquiry_id: sales_order.inquiry.id, status: 'PO Created').first
                if po_request.present?
                  po_request.is_legacy = true
                  po_request.save(validate: false)
                end
              end
            end
          end
        end
      end
    end
  end

  def update_payment_requests_statuses
    PaymentRequest.where(status: 10).update_all(request_owner: 'Logistics', status: :'Payment Pending')
    PaymentRequest.where(status: 20).update_all(request_owner: 'Logistics', status: :'Payment Pending')
    PaymentRequest.where(status: 30).update_all(request_owner: 'Accounts', status: :'Payment Pending')
    PaymentRequest.where(status: 40).update_all(request_owner: 'Accounts', status: :'Payment Made')
  end

  def add_completed_po_to_material_followup_queue
    service = Services::Shared::Spreadsheets::CsvImporter.new('purchase_order_list.csv', folder)
    service.loop(limit) do |x|
      current_overseer = Overseer.where(email: 'approver@bulkmro.com').last
      purchase_order = PurchaseOrder.find_by_po_number(x.get_column('PO#'))
      if purchase_order.po_request.present?
        if purchase_order.po_request != 'PO Created'
          purchase_order.po_request.assign_attributes(status: 'PO Created')
          purchase_order.po_request.save(validate: false)
        end

        if purchase_order.material_status == nil
          purchase_order.set_defaults
        end

        if purchase_order.material_status != 'Material Delivered'
          if purchase_order.email_messages.present? || !purchase_order.email_messages.where(purchase_order: purchase_order, email_type: 'Sending PO to Supplier').present?

            email_message = purchase_order.email_messages.build(
                overseer: current_overseer,
                inquiry: purchase_order.inquiry,
                purchase_order: purchase_order,
                sales_order: purchase_order.po_request.sales_order,
                email_type: 'Sending PO to Supplier'
            )
            email_message.assign_attributes(from: current_overseer.email, to: current_overseer.email, subject: "Internal Ref Inq ##{purchase_order.inquiry.inquiry_number} Purchase Order ##{purchase_order.po_number}")
            email_message.save!
          end
        end
      else
        puts "po request not available for #{purchase_order.po_number}"
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
      puts '---------------------------------'
      if res.code == '200'
        file = open(file_url)
        inquiry.send(field_name).attach(io: file, filename: filename)
      else
        puts res.code
      end
    end
  end

  def update_addresses_remote_uid
    Addresses.update_all('remote_uid=legacy_uid')
  end

  def warehouse_update_remote_uids
    service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses_remote_uids.csv', 'seed_files')
    service.loop(limit) do |x|
      Warehouse.where(name: x.get_column('Warehouse Name')).first_or_create do |warehouse|
        warehouse.legacy_metadata = x.get_row
        warehouse.build_address(
            name: x.get_column('Account Name'),
            street1: x.get_column('Street'),
            street2: x.get_column('Block'),
            pincode: x.get_column('Zip Code'),
            city_name: x.get_column('City'),
            country_code: x.get_column('Country'),
            gst: x.get_column('GST'),
            state: AddressState.find_by_region_code(x.get_column('State'))
        )
      end.update_attributes!(remote_uid: x.get_column('Warehouse Code'),
                             legacy_id: x.get_column('Warehouse Code'),
                             location_uid: x.get_column('Location'),
                             remote_branch_name: x.get_column('Warehouse Name'),
                             remote_branch_code: x.get_column('Business Place ID')
      )
    end
  end

  def target_reports
    target_type = {'1' => 10, '4' => 20, '7' => 30, '2' => 40, '3' => 50, '6' => 60}

    service = Services::Shared::Spreadsheets::CsvImporter.new('target_reports.csv', 'seed_files')
    service.loop(nil) do |x|
      beginning_of_month = "#{x.get_column('period_month')}-01".to_date
      target_period = TargetPeriod.where(period_month: beginning_of_month).first_or_initialize
      if target_period.new_record? || update_if_exists
        target_period.save!
      end

      overseer = Overseer.find_by_legacy_id(x.get_column('legacy_overseer_id'))
      if x.get_column('Manager')
        manager = Overseer.where(first_name: x.get_column('Manager').split(' ').first, last_name: x.get_column('Manager').split(' ').last).first
      else
        manager = overseer.parent.present? ? overseer.parent : overseer
      end

      if x.get_column('Head')
        business_head = Overseer.where(first_name: x.get_column('Head').split(' ').first, last_name: x.get_column('Head').split(' ').last).first
      else
        business_head = manager.parent.present? ? manager.parent : manager
      end


      target = Target.where(overseer: overseer, manager: manager, business_head: business_head, target_period: target_period, target_type: target_type[x.get_column('legacy_type_id')]).first_or_initialize
      if target.new_record? || update_if_exists
        target.target_value = x.get_column('target')
        target.legacy_id = x.get_column('target_legacy_id')
        target.created_by_id = Overseer.default.id
        target.updated_by_id = Overseer.default.id
        target.save!
      end
    end
  end

  def update_sales_orders_for_legacy_inquiries
    objects = []
    folders = ['seed_files', 'seed_files_2']
    folders.each do |folder|
      legacy_request_status_mapping = {'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70}
      remote_status = {'Supplier PO: Request Pending' => 17, 'Supplier PO: Partially Created' => 18, 'Partially Shipped' => 19, 'Partially Invoiced' => 20, 'Partially Delivered: GRN Pending' => 21, 'Partially Delivered: GRN Received' => 22, 'Supplier PO: Created' => 23, 'Shipped' => 24, 'Invoiced' => 25, 'Delivered: GRN Pending' => 26, 'Delivered: GRN Received' => 27, 'Partial Payment Received' => 28, 'Payment Received (Closed)' => 29, 'Cancelled by SAP' => 30, 'Short Close' => 31, 'Processing' => 32, 'Material Ready For Dispatch' => 33, 'Order Deleted' => 70}
      service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_drafts.csv', folder)
      service.loop(nil) do |x|
        inquiry_number = x.get_column('inquiry_number').to_i
        next if inquiry_number == 11505
        inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
        next if inquiry.blank?

        requested_by = Overseer.find_by_legacy_id!(x.get_column('requested_by')) || Overseer.default

        sales_quote = inquiry.sales_quotes.last
        next if sales_quote.blank?
        sales_orders_legacy_metadata = inquiry.sales_orders.pluck(:legacy_metadata)
        if !sales_orders_legacy_metadata.include?(x.get_row)
          sales_order = sales_quote.sales_orders.new
          sales_order.remote_uid = x.get_column('remote_uid')
          sales_order.overseer = requested_by
          sales_order.order_number = x.get_column('order_number')
          sales_order.created_at = x.get_column('requested_time').to_datetime
          sales_order.draft_uid = x.get_column('doc_num')
          sales_order.legacy_request_status = legacy_request_status_mapping[x.get_column('request_status')]
          sales_order.status = legacy_request_status_mapping[x.get_column('request_status')]
          sales_order.remote_status = remote_status[x.get_column('remote_status')]
          sales_order.legacy_metadata = x.get_row
          sales_order.sent_at = sales_quote.created_at
          sales_order.save!

          product_skus = x.get_column('skus')

          sales_quote.rows.each do |row|
            if product_skus.include? row.product.sku
              sales_order.rows.where(sales_quote_row: row).first_or_create!
            end
          end

          # todo handle cancellation, etc
          request_status = x.get_column('request_status')

          if !sales_order.approved?
            if request_status.in? %w(approved requested)
              sales_order.create_approval(
                  comment: sales_order.inquiry.comments.create!(overseer: Overseer.default, message: 'Legacy sales order, being preapproved'),
                  overseer: Overseer.default,
                  metadata: Serializers::InquirySerializer.new(sales_order.inquiry)
              )
            elsif request_status == 'rejected'
              sales_order.create_rejection(
                  comment: sales_order.inquiry.comments.create!(overseer: Overseer.default, message: 'Legacy sales order, being rejected'),
                  overseer: Overseer.default
              )
            else
              sales_order.inquiry.comments.create(overseer: Overseer.default, message: "Legacy sales order, being #{request_status}")
            end
          end
        end
      end
    end
  end

  def sales_invoice_callback_data
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_invoice_callback_data.csv', 'seed_files')
    service.loop(nil) do |x|
      begin
        # next if (x.get_column('increment_id').in? %w(20210348 20200030 20200031 20200038 20200052 20200054 20400024 20200188 20200196 20200206 20200209 20200214 20210056 20210107 20210150 20610026 21010017 21210001 21210003 21210005 20610084 20910005 20610091 20210250 20210257 20210266 20210301 21210009 20210327))

        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('increment_id'))
        if sales_invoice.present?
          meta_data = JSON.parse(x.get_column('meta_data'))
          sales_invoice.update_attributes(status: 1, metadata: meta_data, created_at: meta_data['created_at'].to_datetime)
          puts meta_data['ItemLine'].count
          puts '<---------------------------------------------->'
          meta_data['ItemLine'].each do |remote_row|
            sales_invoice.rows.where(sku: remote_row['sku']).first_or_create! do |row|
              row.assign_attributes(
                  quantity: remote_row['qty'],
                  metadata: remote_row
              )
            end
          end
        end
      rescue => e
        errors.push("#{x.get_column('increment_id')}")
      end
    end
    puts errors
  end

  def purchase_order_callback_data
    tax_rates = {'14' => 0, '15' => 12, '16' => 18, '17' => 28, '18' => 5}
    errors = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('purchase_order_callback.csv', 'seed_files')
    i = 0
    service.loop(nil) do |x|
      i = i + 1
      begin
        puts "<----------------------- #{i}"
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('purchase_order_number'))
        if purchase_order.present?
          purchase_order.rows.delete_allputs x.get_column('purchase_order_number')
          meta_data = JSON.parse(x.get_column('meta_data'))

          purchase_order.assign_attributes(metadata: meta_data, created_at: meta_data['PoDate'])

          meta_data['ItemLine'].each do |remote_row|
            purchase_order.rows.build do |row|
              row.assign_attributes(
                  metadata: remote_row
              )
              tax = nil
              if remote_row['PopTaxRate'].to_i >= 14
                supplier = purchase_order.get_supplier(remote_row['PopProductId'].to_i)
                if supplier.present?
                  bill_from = supplier.billing_address
                  ship_from = supplier.shipping_address
                  bill_to = purchase_order.inquiry.bill_from.address

                  if bill_from.present? && ship_from.present? && bill_to.present?
                    purchase_order.metadata['PoTaxRate'] = TaxRateString.for(bill_to, bill_from, ship_from, tax_rates[remote_row['PopTaxRate'].to_s])
                    row.metadata['PopTaxRate'] = tax_rates[remote_row['PopTaxRate'].to_s].to_s
                    row.save
                  end
                end
              end
              puts tax
              puts "\n\n"
            end
          end
          purchase_order.save!
        end
      rescue => e
        errors.push("#{x.get_column('purchase_order_number')} - #{e}")
      end
    end
    puts errors
    puts errors.count
  end


  def legacy_sales_order_reporting_data
    service = Services::Shared::Spreadsheets::CsvImporter.new('legacy_sales_order.csv', 'seed_files')

    skips = []
    total = 0
    service.loop(nil) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_no').to_i)
      sales_order = SalesOrder.where(order_number: x.get_column('order_number').to_i) || SalesOrder.find_by_remark(x.get_column('order_number'))
      if sales_order.blank?
        sales_quote = nil
        if inquiry.present?
          sales_quote = inquiry.final_sales_quote.present? ? inquiry.final_sales_quote : inquiry.sales_quotes.last
        end

        sales_order = SalesOrder.new
        sales_order.sales_quote = sales_quote
        begin
          sales_order.save(validate: false)
        rescue

          puts '-----------------------'
          puts "Missed Sales Quote #{x.get_column('order_number')} x.get_column('mis_date')"
          puts '-----------------------'
        end
        sales_order.order_number = x.get_column('order_number').is_a?(Numeric) ? x.get_column('order_number') : sales_order.id
        sales_order.remark = x.get_column('order_number')
        sales_order.report_total = x.get_column('report_total').to_f
        sales_order.mis_date = x.get_column('mis_date')
        sales_order.status = 'Approved'
        begin
          sales_order.save(validate: false)
        rescue
          skips << x.get_column('order_number')
          puts '-----------------------'
          puts "Missed Sales Quote #{x.get_column('order_number')} x.get_column('mis_date')"
          puts '-----------------------'
        end
      else
        sales_order.each do |so|
          so.report_total = so.report_total.present? ? so.report_total + x.get_column('report_total').to_f : x.get_column('report_total').to_f
          so.mis_date = x.get_column('mis_date')
          begin
            so.save(validate: false)
          rescue
            skips << x.get_column('order_number')
            puts '-----------------------'
            puts "Missed Sales Quote #{x.get_column('order_number')} x.get_column('mis_date')"
            puts '-----------------------'
          end
        end
      end
    end
  end


  def sales_order_mis_date
  end

  def sales_invoices_reporting_data
    service = Services::Shared::Spreadsheets::CsvImporter.new('reporting_sales_invoice.csv', 'seed_files')
    service.loop(nil) do |x|
      sales_invoice = SalesInvoice.where(invoice_number: x.get_column('invoice_number'))


      if sales_invoice.present?

        sales_invoice.each do |si|
          si.is_legacy = true
          if si.report_total.present?
            si.report_total = si.report_total + x.get_column('report_total').to_f
          else
            si.report_total = x.get_column('report_total')
          end
          si.mis_date = x.get_column('mis_date')
          si.save(validate: false)
        end
      else
        sales_invoice = SalesInvoice.new
        sales_invoice.is_legacy = true
        sales_invoice.invoice_number = x.get_column('invoice_number')
        if sales_invoice.report_total.present?
          sales_invoice.report_total = sales_invoice.report_total + x.get_column('report_total').to_f
        else
          sales_invoice.report_total = x.get_column('report_total')
        end
        sales_invoice.mis_date = x.get_column('mis_date')
        sales_invoice.save(validate: false)
      end
    end
  end

  def update_products_with_legacy_brand
    service = Services::Shared::Spreadsheets::CsvImporter.new('products_data_with_legacy_brand.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find(x.get_column('product_id'))
      brand = Brand.find_by_name(x.get_column('brand_name').upcase)
      if !brand.present?
        brand = Brand.new(name: x.get_column('brand_name').upcase)
        brand.save_and_sync
      end
      if product.present?
        product.name = x.get_column('product_name')
        product.brand = brand
        product.save
      end
    end
  end

  def save_and_sync_products_with_legacy_brand
    service = Services::Shared::Spreadsheets::CsvImporter.new('products_data_with_legacy_brand.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find(x.get_column('product_id'))
      product.save_and_sync
    end
  end

  def brand_remote_uids
    Brand.update_all remote_uid: nil
    service = Services::Shared::Spreadsheets::CsvImporter.new('brand_remote_uids.csv', folder)
    service.loop(nil) do |x|
      name = x.get_column('Manufacturer Name')
      brand = Brand.find_by_name(name)
      if brand.present?
        brand.remote_uid = x.get_column('Code')
        brand.save_and_sync
      end
      next if name == nil
    end
  end

  def product_images
    service = Services::Shared::Spreadsheets::CsvImporter.new('product_images.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find_by_legacy_id(x.get_column('legacy_id'))
      next if product.blank?
      sheet_columns = [
          ['image_path', 'images']
      ]
      sheet_columns.each do |file|
        file_url = x.get_column(file[0])
        begin
          puts '<-------------------------->'
          attach_file(product, filename: x.get_column(file[0]).split('/').last, field_name: file[1], file_url: file_url)
        rescue URI::InvalidURIError => e
          puts "Help! #{e} did not migrate."
        end
      end
    end
  end

  def get_product_price(product_id, company)
    company_inquiries = company.inquiries.includes(:sales_quote_rows, :sales_order_rows)
    sales_order_rows = company_inquiries.map {|i| i.sales_order_rows.includes(:product).joins(:product).where('products.id = ?', product_id)}.flatten.compact
    sales_order_row_price = sales_order_rows.map {|r| r.unit_selling_price}.flatten if sales_order_rows.present?
    return sales_order_row_price.min if sales_order_row_price.present?
    sales_quote_rows = company_inquiries.map {|i| i.sales_quote_rows.includes(:product).joins(:product).where('products.id = ?', product_id)}.flatten.compact
    sales_quote_row_price = sales_quote_rows.pluck(:unit_selling_price)
    return sales_quote_row_price.min
  end

  def generate_customer_products_from_existing_products
    overseer = Overseer.default
    customers = Contact.all
    customers.each do |customer|
      customer_companies = customer.companies
      inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company: customer_companies).map {|i| i.inquiry_products}.flatten
      inquiry_products.each do |inquiry_product|
        CustomerProduct.where(company_id: inquiry_product.inquiry.company_id, product_id: inquiry_product.product_id).first_or_create do |customer_product|
          customer_product.category_id = inquiry_product.product.category_id
          customer_product.brand_id = inquiry_product.product.brand_id
          customer_product.name = inquiry_product.bp_catalog_name || inquiry_product.product.name
          customer_product.sku = inquiry_product.bp_catalog_sku || inquiry_product.product.sku
          # customer_product.customer_price = get_product_price(inquiry_product.product_id, inquiry_product.inquiry.company)
          customer_product.created_by = overseer
        end
      end
    end
  end

  def chandan_products
    skus = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('Chandan Steel NEW.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find_by_sku(x.get_column('BM'))
      if !product.present?
        brand = Brand.find_by_name(x.get_column('Make'))
        category = Category.find_by_name(x.get_column('Category'))
        measurement_unit = MeasurementUnit.find_by_name(x.get_column('UOM'))
        name = x.get_column('Client Description')
        sku = x.get_column('BM')
        tax_code = TaxCode.find_by_chapter(x.get_column('HSN Code'))

        next if Product.where(sku: sku).exists?

        product = Product.new
        product.brand = brand
        product.category = category
        product.sku = sku || product.generate_sku
        product.tax_code = tax_code || TaxCode.default
        product.mpn = x.get_column('MFR')
        product.description = x.get_column('BULK MRO Description')
        product.name = name
        product.measurement_unit = measurement_unit
        product.legacy_metadata = x.get_row
        product.save_and_sync

        product.create_approval(comment: product.comments.create!(overseer: Overseer.default, message: 'Product, being preapproved'), overseer: Overseer.default) if product.approval.blank?
      end

      sheet_columns = [
          ['img_links', 'images']
      ]

      sheet_columns.each do |file|
        file_url = x.get_column(file[0])
        begin
          sleep(1.5)
          puts '-------------------------------------------'
          attach_file(product, filename: x.get_column(file[0]).split('/').last, field_name: file[1], file_url: file_url)
        rescue URI::InvalidURIError => e
          puts "Help! #{e} did not migrate."
        end
      end
      skus.push product.sku
    end

    puts skus
  end

  def sales_invoices_reporting_data_update_mis_date
    service = Services::Shared::Spreadsheets::CsvImporter.new('reporting_sales_invoice.csv', 'seed_files')
    service.loop(nil) do |x|
      sales_invoice = SalesInvoice.where(invoice_number: x.get_column('invoice_number'))
      if sales_invoice.present?
        sales_invoice.each do |si|
          si.mis_date = x.get_column('mis_date')
          si.save(validate: false)
        end
      end
    end
  end

  def sales_orders_reporting_data_update_mis_date
    service = Services::Shared::Spreadsheets::CsvImporter.new('order_mis_date.csv', 'seed_files')
    added = []
    service.loop(2000) do |x|
      sales_order = SalesOrder.where(order_number: x.get_column('order_number'))
      if sales_order.present?
        sales_order.each do |so|
          so.mis_date = x.get_column('mis_date')
          added << so.order_number
          so.save(validate: false)
        end
      end
    end
    added.uniq
  end

  def update_products_description
    service = Services::Shared::Spreadsheets::CsvImporter.new('SO DATA_15000 Ready to Upload.csv', 'seed_files')
    service.loop(nil) do |x|
      puts "-----------------#{x.get_column('SKU')}"
      product = Product.find_by_sku(x.get_column('SKU'))
      is_duplicate = x.get_column('IS Duplicate')
      if product.present?
        if is_duplicate == 'TRUE'
          product.is_active = false
          product.save
        else
          product.name = x.get_column('New Discription')
          product.save_and_sync
        end
      end
    end
  end

  def update_products_tax_rate_hsn
    service = Services::Shared::Spreadsheets::CsvImporter.new('Piramal Stationary.csv', 'seed_files')
    service.loop(nil) do |x|
      puts "-----------------#{x.get_column('SKU')}"
      product = Product.find_by_sku(x.get_column('SKU'))
      if product.present?
        tax_rate = TaxRate.find_by_tax_percentage(x.get_column('Tax Rate').split('%').first.to_i)
        tax_code = TaxCode.where(chapter: x.get_column('HSN').to_i, is_service: product.is_service).first
        product.tax_rate = tax_rate || nil
        product.tax_code = tax_code || nil
        product.save
      end
    end
  end

  def create_customer_product(company, product, x)
    product_name = x.get_column('New Description')
    customer_cost = x.get_column('Cost').to_f
    category_3 = Category.find_by_name(x.get_column('Category 3')) if x.get_column('Category 3').present?
    category_2 = Category.find_by_name(x.get_column('Category 2')) if x.get_column('Category 2').present?
    category_1 = Category.find_by_name(x.get_column('Category 1')) if x.get_column('Category 1').present?
    category = category_3 || category_2 || category_1
    brand = Brand.find_by_name(x.get_column('Brand'))
    tax_code = TaxCode.find_by_chapter(x.get_column('HSN'))
    tax_rate = TaxRate.find_by_tax_percentage(x.get_column('GST').to_i)
    measurement_unit = MeasurementUnit.find_by_name(x.get_column('UOM'))

    puts product_name, customer_cost
    puts '<--------------->'
    CustomerProduct.where(company_id: company.id, product_id: product.id, customer_price: (customer_cost || 0)).first_or_create! do |customer_product|
      customer_product.category_id = (category.id if category.present?) || product.category_id
      customer_product.brand_id = (brand.id if brand.present?) || product.brand_id
      customer_product.name = product_name
      customer_product.sku = product.sku
      customer_product.measurement_unit_id = (measurement_unit.id if measurement_unit.present?) || product.measurement_unit_id
      customer_product.tax_rate_id = (tax_rate.id if tax_rate.present?) || product.tax_rate_id
      customer_product.tax_code_id = (tax_code.id if tax_code.present?) || product.tax_code_id
      customer_product.moq = 1
      customer_product.created_by = Overseer.default
    end
  end

  def add_products_and_customer_products_to_company
    company = Company.find_by_name('CHANDAN STEEL')
    products = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('Chandan Steel - Bulkmro.csv', 'seed_files')
    service.loop(nil) do |x|
      sku = x.get_column('SKU')

      if sku.present?
        product = Product.find_by_sku(sku)
        if product.present?
          create_customer_product(company, product, x)
        end
      else
        name = x.get_column('New Description')
        product = Product.find_by_name(name)
        if product.blank?
          category_3 = Category.find_by_name(x.get_column('Category 3')) if x.get_column('Category 3').present?
          category_2 = Category.find_by_name(x.get_column('Category 2')) if x.get_column('Category 2').present?
          category_1 = Category.find_by_name(x.get_column('Category 1')) if x.get_column('Category 1').present?
          brand = Brand.find_by_name(x.get_column('Brand'))

          category = category_3 || category_2 || category_1
          measurement_unit = MeasurementUnit.find_by_name(x.get_column('UOM'))
          tax_code = TaxCode.find_by_chapter(x.get_column('HSN'))

          product = Product.new
          product.brand = brand
          product.category = category
          product.sku = product.generate_sku
          product.tax_code = tax_code || TaxCode.default
          product.mpn = x.get_column('MPN')
          product.description = x.get_column('New Description')
          product.name = name
          product.measurement_unit = measurement_unit
          product.legacy_metadata = x.get_row
          product.save!

          product.create_approval(comment: product.comments.create!(overseer: Overseer.default, message: 'Product, being preapproved'), overseer: Overseer.default) if product.approval.blank?
        end
        create_customer_product(company, product, x)
      end
    end
  end

  def update_inquiries_status
    service = Services::Shared::Spreadsheets::CsvImporter.new('Inquiries Status to be updated 12 Dec.csv', 'seed_files')
    service.loop(nil) do |x|
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      inquiry.update_attribute(:status, x.get_column('Before Change Status'))
    end
  end


  def update_sales_orders_mis_date
    no_inquiries = []
    no_sales_orders = []

    service = Services::Shared::Spreadsheets::CsvImporter.new('MIS Dates - Sheet1.csv', 'seed_files')
    service.loop(nil) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('SO No.'))
      if sales_order.present?
        sales_order.mis_date = x.get_column('MIS Date')
        sales_order.save(validate: false)
      else
        inquiry = Inquiry.find_by_inquiry_number(x.get_column('Inquiry No.'))
        if inquiry.present?
          no_sales_orders.push x.get_column('SO No.')
        else
          no_inquiries.push x.get_column(x.get_column('Inquiry No.'))
        end
      end
    end
    puts no_inquiries.uniq
    puts no_sales_orders.uniq
  end

  def purchase_order_to_po_request
    po_requests = PoRequest.where.not(purchase_order_number: nil)
    po_requests.each do |po_request|
      if po_request.purchase_order_number.present?
        purchase_order = PurchaseOrder.find_by_po_number(po_request.purchase_order_number)
        po_request.update_attribute(:purchase_order, purchase_order)
      end
    end
  end

  def payment_option_to_purchase_order
    purchase_orders = PurchaseOrder.where(payment_option_id: nil)
    purchase_orders.each do |purchase_order|
      if purchase_order.metadata.present? && purchase_order.metadata['PoPaymentTerms'].present?
        payment_term_name = purchase_order.metadata['PoPaymentTerms'].to_s.strip
        payment_option = PaymentOption.find_by_name(payment_term_name)
        purchase_order.update_attribute(:payment_option, payment_option)
      end
    end
  end


  def create_reliance_products
    service = Services::Shared::Spreadsheets::CsvImporter.new('Reliance-product-images.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find_by_sku(x.get_column('SKU'))
      company_1 = Company.find('ezBtA4')
      company_2 = Company.find('Pn4t8O')
      companies = [company_1, company_2]
      if product.present? && product.has_images?
        companies.each do |company|
          CustomerProduct.where(company_id: company.id, product_id: product.id, customer_price: (x.get_column('Last Buying Price').to_f || 0)).first_or_create! do |customer_product|
            customer_product.category_id = product.try(:category_id)
            customer_product.brand_id = product.try(:brand_id)
            customer_product.name = product.try(:name)
            customer_product.sku = x.get_column('SKU')
            customer_product.measurement_unit_id = product.measurement_unit_id
            customer_product.tax_rate_id = product.try(:tax_rate_id)
            customer_product.tax_code_id = product.try(:tax_code_id)
            customer_product.moq = 1
            customer_product.created_by = Overseer.default
          end
        end
      end
    end
  end

  def create_image_readers
    service = Services::Shared::Spreadsheets::CsvImporter.new('image_readers.csv', folder)
    errors = []
    service.loop(nil) do |x|
      begin
        image_reader = ImageReader.where(reference_id: x.get_column('reference_id')).first_or_initialize
        if image_reader.new_record? || update_if_exists
          image_reader.meter_number = x.get_column('meter_number')
          image_reader.meter_reading = x.get_column('meter_reading')
          image_reader.image_url = x.get_column('image_url')
          image_reader.status = x.get_column('status')
          image_reader.save!
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('reference_id')}")
      end
    end
    puts errors
  end

  def update_images_for_reliance_products
    service = Services::Shared::Spreadsheets::CsvImporter.new('Reliance-product-images.csv', 'seed_files')
    service.loop(nil) do |x|
      puts x.get_column('Image Link')
      if x.get_column('Image Link').present?
        if x.get_column('Image Link').split(':').first != 'http'
          product = Product.find_by_sku(x.get_column('SKU'))
          if product.present?
            sheet_columns = [
                ['Image Link', 'images']
            ]
            sheet_columns.each do |file|
              file_url = x.get_column(file[0])
              begin
                puts '<-------------------------->'
                if !product.has_images?
                  attach_file(product, filename: x.get_column(file[0]).split('/').last, field_name: file[1], file_url: file_url)
                end
              rescue URI::InvalidURIError => e
                puts "Help! #{e} did not migrate."
              end
            end
          end
        end
      else
        puts 'false'
      end
    end
  end

  def update_online_order_numbers
    CustomerOrder.all.each do |co|
      co.update_attributes(online_order_number: Services::Resources::Shared::UidGenerator.online_order_number(co.id))
    end
  end

  def update_is_international_field_in_company
    Company.update_all(is_international: false)
    Company.all.includes(:addresses).each do |company|
      if company.addresses.present? && !company.addresses.map {|address| address.country_code}.include?('IN')
        company.update_attribute('is_international', true)
      end
    end
  end

  def create_company_banks
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_banks.csv', folder)
    errors = []
    service.loop(nil) do |x|
      begin
        company = Company.find_by_remote_uid(x.get_column('bp_code'))
        bank = Bank.find_by_code(x.get_column('bank_code'))
        if company
          company_bank = CompanyBank.where(remote_uid: x.get_column('internal_key')).first_or_initialize
          if company_bank.new_record? || update_if_exists
            company_bank.company = company
            company_bank.bank = bank
            company_bank.account_name = x.get_column('account_name')
            company_bank.account_number = x.get_column('account_no')
            company_bank.branch = x.get_column('branch')
            company_bank.mandate_id = x.get_column('mandate_id')
            company_bank.metadata = x.get_row
            company_bank.save!
          end
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('internal_key')}")
      end
    end
    puts errors
  end

  def create_banks
    service = Services::Shared::Spreadsheets::CsvImporter.new('banks.csv', folder)
    errors = []
    service.loop(nil) do |x|
      begin
        bank = Bank.where(code: x.get_column('Bank Code')).first_or_initialize
        if bank.new_record? || update_if_exists
          bank.name = x.get_column('Bank Name')
          bank.country_code = x.get_column('Country Code')
          bank.remote_uid = x.get_column('Absolute entry')
          bank.save!
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('Bank Code')}")
      end
    end
    puts errors
  end


  def missing_inquiries
    file = "#{Rails.root}/tmp/missing_increment_ids.csv"

    service = Services::Shared::Spreadsheets::CsvImporter.new('legacy_inquiry_numbers.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: ['missing_increment_ids']) do |writer|
      service.loop(nil) do |x|
        inquiry = Inquiry.find_by_inquiry_number(x.get_column('increment_id'))
        if inquiry.blank?
          writer << [x.get_column('increment_id')]
        end
      end
    end
  end

  def missing_bible_sales_orders
    file = "#{Rails.root}/tmp/missing_orders.csv"
    column_headers = ['inquiry_number', 'order_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_sales_orders.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('SO #'))
        if sales_order.blank?
          writer << [x.get_column('Inquiry Number'), x.get_column('SO #')]
        end
      end
    end
  end

  def bible_sales_orders_totals_mismatch
    file = "#{Rails.root}/tmp/bible_totals_mismatch.csv"
    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('bible_sales_orders.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('SO #'))
        if sales_order.present? && ((sales_order.calculated_total.to_f != x.get_column('SUM of Selling Price (as per SO / AR Invoice)').to_f) || (sales_order.calculated_total_with_tax.to_f != x.get_column('SUM of Gross Total Selling').to_f))
          writer << [sales_order.order_number, sales_order.calculated_total, sales_order.calculated_total_with_tax, x.get_column('SUM of Selling Price (as per SO / AR Invoice)'), x.get_column('SUM of Gross Total Selling')]
        end
      end
    end
  end

  def missing_sap_orders
    file = "#{Rails.root}/tmp/sap_missing_orders.csv"
    column_headers = ['inquiry_number', 'order_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_sales_orders.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#'))
        if sales_order.blank?
          writer << [x.get_column('Project'), x.get_column('#')]
        end
      end
    end
  end

  def purchase_orders_total_mismatch
    file = "#{Rails.root}/tmp/purchase_orders_total_mismatch.csv"
    column_headers = ['PO_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax', 'is_legacy']
    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_mismatch_purchase_orders.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        purchase_order = PurchaseOrder.find_by_po_number(x.get_column('Po number'))
        if purchase_order.present? && ((purchase_order.calculated_total_with_tax.to_f != x.get_column('Document Total').to_f) || (purchase_order.calculated_total.to_f != (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f).to_f))
          writer << [purchase_order.po_number, purchase_order.calculated_total.to_f, purchase_order.calculated_total_with_tax.to_f, (x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f), x.get_column('Document Total').to_f, purchase_order.is_legacy?]
        end
        # if !purchase_order.present?
        #   writer << [x.get_column('Po number'), x.get_column('Date'), x.get_column('Project'), x.get_column('Document Total'), x.get_column('Project Code'),x.get_column('Tax Amount (SC)'),x.get_column('Canceled')]
        # end
      end
    end
  end

  def sap_sales_orders_totals_mismatch
    file = "#{Rails.root}/tmp/sap_orders_totals_mismatch.csv"
    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'sap_total', 'sap_total_with_tax']
    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_sales_orders.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('#'))
        sap_total_without_tax = 0
        sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f

        if sales_order.present? && ((sales_order.calculated_total.to_f != sap_total_without_tax) || (sales_order.calculated_total_with_tax.to_f != x.get_column('Document Total').to_f))
          writer << [sales_order.order_number, sales_order.calculated_total, sales_order.calculated_total_with_tax, sap_total_without_tax, x.get_column('Document Total')]
        end
      end
    end
  end

  def missing_sap_invoices
    file = "#{Rails.root}/tmp/sap_missing_invoices.csv"
    column_headers = ['invoice_number']

    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_sales_invoices.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#'))
        if sales_invoice.blank?
          writer << [x.get_column('#')]
        end
      end
    end
  end

  def sap_sales_invoices_totals_mismatch
    file = "#{Rails.root}/tmp/sap_invoices_totals_mismatch.csv"
    column_headers = ['invoice_number', 'sprint_total', 'sprint_tax', 'sprint_total_with_tax', 'sap_total', 'sap_tax', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_sales_invoices.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#'))
        sap_total_without_tax = 0
        total_without_tax = 0

        if sales_invoice.present? && !sales_invoice.is_legacy?
          total_without_tax = sales_invoice.metadata['base_grand_total'].to_f - sales_invoice.metadata['base_tax_amount'].to_f
          sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f
          if (total_without_tax != sap_total_without_tax) || (sales_invoice.metadata['base_grand_total'].to_f != x.get_column('Document Total').to_f)

            writer << [
                sales_invoice.invoice_number,
                total_without_tax,
                sales_invoice.metadata['base_tax_amount'].to_f,
                sales_invoice.metadata['base_grand_total'].to_f,
                sap_total_without_tax,
                x.get_column('Tax Amount (SC)').to_f,
                x.get_column('Document Total')
            ]
          end
        end
      end
    end
  end

  def update_total_cost_in_sales_order
    SalesOrder.all.each do |so|
      so.order_total = so.calculated_total
      so.invoice_total = so.invoices.map {|i| i.metadata.present? ? (i.metadata['base_grand_total'].to_f - i.metadata['base_tax_amount'].to_f) : 0.0}.inject(0) {|sum, x| sum + x}
      so.save
    end
  end

  def update_row(product_sku, row, x)
    if product_sku.include? row.product.sku
      row.quantity = x.get_column('quantity').to_i
      row.margin_percentage = x.get_column('margin percentage')
      row.unit_selling_price = x.get_column('unit selling price').to_f
      row.converted_unit_selling_price = x.get_column('unit selling price').to_f
      row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
      row.measurement_unit = MeasurementUnit.find_by_name(x.get_column('measurement unit')) || MeasurementUnit.default
      row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
      row.tax_percentage = TaxRate.find_by_tax_percentage(x.get_column('tax rate')) || nil
      # row.tax_percentage
      row.save!
      puts '**************** QUOTE ROW SAVED ********************'
    end
  end


  def create_missing_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-02-15 Bible Sales Order Rows.csv', 'seed_files')
    i = 0
    # inquiry_numbers = [2239,1742,1487,1463,1451,1431,919,11,2998,918,1021,203,1011,1273,2216,1443,3526,288,129,2776,4478,4380,4351,4342,4234,4233,4232,4231,4003,3625,3496,3248,3244,3088,3086,3053,2967,2958,2950,2903,2645,2644,2643,1342,1323,1293,542,4589,4693,4757,4799,4800,4801,4803,4804,4805,4806,4807,4808,4813,4815,4851,4875,4876,4877,4881,4888,4920,4924,4925,4926,4927,4928,4929,4930,4931,4932,4939,4940,4948,4964,4990,4994,4996,5017,5019,5020,5033,5035,5055,5056,5057,5058,5059,5060,5061,5067,5118,5120,5121,5124,5127,5128,5129,5130,5131,5132,5133,5172,5174,5175,5178,5186,5187,5265,5266,5290,5296,5297,5330,5353,5406,5407,5408,5709,5710,5768,5796,5810,5863,3307,6342,6663,8618,8790,10282,10317,10318,10330,10332,10333,10334,10336,10337,10338,10339,10340,10341,10342,10345,10347,10353,10355,10357,10358,10359,10360,10361,10366,10368,10370,10372,10373,10377,10378,10380,10381,10384,10387,10389,10397,10404,10411,10412,10414,10415,10416,10417,10524,10527,10579,10607,10609,10625,10634,10638,10639,10658,10661,10665,10668,10669,10670,10672,10673,10742,10744,10745,10777,10784,10804,10805,10807,10810,10811,10813,10815,10828,10830,10837,10861,10862,10902,10903,10905,10906,10911,10912,10913,10914,10915,11005,11007,11012,11013,11014,11022,11023,11029,11041,11043,11073,11080,11081,11082,11142,11164,11184,11207,11231,11233,11237,11239,11240,11254,11266,11275,11276,11297,11307,11312,11313,11314,11318,11360,11365,11371,11376,11431,11432,11440,11517,11547,11548,11554,11555,11556,11557,11558,11560,11561,11562,11570,11572,11574,11575,11578,11581,11584,11611,11613,11614,11615,11617,11618,11620,11622,11623,11629,11631,11634,11635,11636,11638,11639,11641,11644,11645,11674,11675,11677,11680,11681,11682,11683,11685,11686,11689,11690,11717,11718,11719,11733,11734,11741,11821,11826,11828,11832,11833,11834,11835,11836,11837,11838,11839,11843,11846,11847,11848,11850,11852,11853,11854,11855,11857,11858,11860,11861,11862,11864,11867,11869,11870,11873,11894,11898,11899,11901,11909,11910,11912,11914,11915,11917,11920,11928,11972,11973,11974,11975,11976,11978,11979,11980,11981,11982,11983,11985,11987,11988,11989,11990,11991,11993,11996,11998,12001,12002,12004,12007,12008,12010,12011,12013,12014,12016,12021,12041,12042,12043,12044,12046,12047,12048,12050,12052,12053,12054,12056,12057,12058,12060,12065,12070,12071,12072,12073,12074,12075,12076,12077,12080,12088,12089,12090,12091,12092,12093,12095,12096,12097,12123,12125,12126,12127,12129,12130,12131,12132,12133,12135,12141,12144,12146,12149,12156,12158,12159,12164,12235,12236,12274,12275,12372,12373,12378,12380,12381,12382,12383,12386,12387,12388,12389,12394,12395,12396,12397,12399,12400,12401,12402,12403,12404,12405,12406,12407,12408,12409,12410,12411,12414,12417,12418,12421,12424,12426,12427,12428,12430,12431,12433,12434,12436,12458,12459,12461,12462,12463,12465,12466,12467,12468,12470,12471,12473,12475,12477,12478,12480,12481,12482,12484,12485,12487,12489,12490,12491,12493,12494,12495,12496,12497,12499,12500,12501,12503,12504,12506,12507,12508,12509,12510,12511,12512,12513,12514,12515,12517,12519,12520,12521,12524,12526,12527,12528,12529,12530,12531,12532,12533,12535,12536,12537,12539,12545,12546,12547,12548,12549,12550,12552,12553,12565,12566,12568,12569,12571,12572,12574,12575,12577,12581,12583,12584,12585,12586,12588,12589,12590,12591,12592,12594,12596,12599,12601,12602,12605,12616,12617,12618,12619,12621,12622,12626,12627,12628,12629,12641,12642,12645,12646,12647,12648,12649,12650,12651,12652,12665,12667,12668,12669,12696,12698,12700,12701,12702,12703,12704,12714,12715,12716,12718,12719,12720,12721,12722,12723,12724,12725,12726,12727,12728,12730,12732,12733,12734,12735,12761,12762,12763,12764,12765,12767,12768,12769,12770,12829,12835,12836,12840,12852,12853,12855,12857,12894,12898,12919,12920,12924,12926,12927,12928,12954,12955,12957,12958,12960,12964,13063,13064,13065,13066,13067,13068,13069,13070,13071,13072,13073,13074,13075,13076,13077,13078,13079,13080,13081,13082,13083,13084,13085,13086,13087,13088,13089,13090,13091,13092,13093,13094,13095,13096,13097,13098,13099,13100,13101,13102,13103,13104,13105,13106,13107,13108,13109,13110,13111,13112,13113,13114,13115,13116,13117,13118,13119,13120,13121,13122,13123,13124,13125,13126,13127,13128,13129,13130,13131,13132,13133,13134,13135,13136,13137,13138,13139,13140,13141,13142,13143,13144,13145,13146,13147,13148,13149,13150,13151,13152,13153,13154,13155,13156,13157,13158,13159,13160,13161,13162,13163,13164,13165,13166,13167,13168,13169,13170,13171,13172,13173,13174,13175,13176,13177,13178,13179,13180,13181,13182,13183,13184,13185,13186,13187,13188,13189,13190,13191,13192,13193,13194,13195,13196,13197,13198,13199,13200,13201,13202,13203,13204,13205,13206,13207,13208,13209,13210,13211,13212,13213,13214,13215,13216,13217,13218,13219,13220,13221,13222,13223,13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13239,13240,13241,13242,13243,13244,13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,13257,13258,13259,13260,13261,13262,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,13274,13275,13276,13277,13278,13282,13283,13284,13285,13286,13287,13288,13289,13290,13291,13292,13293,13294,13295,13296,13297,13298,13299,13300,13301,13302,13303,13304,13305,13306,13307,13308,13309,13310,13311,13312,13313,13314,13315,13316,13317,13318,13319,13320,13321,13356,13357,13358,13359,13360,13361,13362,13363,13364,13365,13366,13428,13429,13430,13431,13432,13433,13434,13435,13448,13449,13450,13451,13486,13487,13488,13489,13537,13538,13539,13540,13613,13614,13635,13636,13637,13638,13639,13640,13641,13642,13643,13644,13645,13646,13647,13662,13663,13694,13704,13731,13732,13737,13764,13765,13767,13819,13820,13824,13825,13836,13837,13838,13839,13840,13869,13877,13878,13879,13910,13912,13913,13959,13960,13961,13978,13979,13980,13981,13982,13986,13987,13988,13989,13990,13991,13992,13993,13994,13995,13996,13997,14028,14029,14030,14031,14059,14086,14087,14088,14139,14168,14169,14173,14205,14206,14207,14208,14209,14210,14228,14229,14230,14268,14270,14271,14272,14273,14274,14296,14297,14300,14301,14302,14308,14309,14310,14311,14312,14314,14315,14316,14317,14318,14319,14324,14356,14357,14358,14361,14362,14363,14382,14384,14385,14386,14412,14413,14414,14417,14418,14419,14420,14431,14462,14463,14464,14467,14468,14469,14472,14512,14518,14519,14520,14544,14547,14548,14549,14550,14551,14585,14586,14587,14588,14594,14595,14596,14597,14613,14614,14645,14646,14650,14651,14652,14667,14668,14669,14686,14689,14690,14713,14714,14715,14716,14741,14742,14743,14744,14745,14750,14751,14752,14754,14769,14770,14796,14797,14798,14817,14819,14820,14826,14827,14828,14829,14832,14850,14852,14853,14854,14855,14877,14878,14879,14880,14881,14882,14902,14903,14927,14928,14929,14931,14936,14937,14938,14941,14942,14943,14984,14985,14986,14987,14988,15007,15008,15009,15010,15011,15012,15013,15014,15015,15016,15017,15018,15019,15020,15041,15042,15043,15044,15045,15068,15092,15093,15094,15096,15097,15098,15099,15100,15115,15116,15117,15118,15119,15136,15137,15138,15140,15157,15158,15166,15167,15168,15174,15218,15219,15220,15221,15222,15223,15224,15227,15228,15250,15251,15252,15256,15257,15258,15259,15260,15261,15262,15263,15264,15265,15266,15267,15268,15269,15270,15271,15272,15273,15274,15275,15276,15277,15278,15279,15280,15281,15282,15283,15284,15285,15286,15287,15288,15289,15290,15291,15292,15293,15294,15295,15296,15297,15298,15299,15300,15301,15302,15303,15304,15305,15306,15307,15308,15311,15312,15313,15314,15315,15316,15317,15318,15319,15320,15321,15322,15323,15324,15325,15326,15327,15328,15329,15330,15331,15332,15333,15334,15335,15336,15337,15338,15339,15340,15341,15342,15343,15344,15345,15346,15347,15348,15349,15350,15351,15352,15353,15354,15355,15356,15357,15358,15359,15360,15361,15362,15363,15364,15365,15367,15368,15369,15370,15371,15372,15373,15374,15375,15376,15377,15378,15379,15380,15381,15382,15383,15384,15386,15387,15388,15392,15398,15399,15400,15401,15403,15404,15428,15429,15430,15431,15432,15433,15434,15435,15436,15437,15438,15439,15440,15441,15442,15443,15444,15518,15519,15520,15521,15522,15523,15525,15526,15545,15547,15568,15569,15570,15571,15573,15596,15603,15609,15610,15611,15612,15613,15614,15615,15616,15617,15618,15619,15620,15621,15622,15623,15624,15625,15626,15627,15628,15638,15639,15640,15641,15642,15643,15644,15684,15685,15686,15687,15689,15690,15691,15708,15709,15710,15711,15712,15713,15714,15715,15716,15719,15720,15726,15727,15728,15729,15730,15731,15732,15733,15734,15757,15758,15759,15760,15761,15762,15765,15766,15792,15793,15795,15796,15797,15816,15817,15818,15841,15861,15862,15863,15865,15866,15893,15912,15913,15914,15915,15916,15917,15954,15956,15957,15981,15982,15986,15987,15988,16010,16011,16021,16029,16054,16055,16056,16057,16058,16059,16060,16077,16081,16100,16102,16103,16104,16116,16117,16133,16148,16169,16170,16171,16172,16173,16174,16175,16176,16177,16178,16179,16180,16195,16196,16217,16218,16219,16226,16237,16241,16242,16252,16253,16254,16255,16256,16257,16258,16259,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,16301,16302,16303,16304,16305,16306,16317,16337,16338,16339,16340,16355,16356,16379,16380,16381,16395,16396,16399,16413,16423,16424,16425,16429,16430,16431,16432,16434,16436,16443,16468,16469,16470,16471,16472,16473,16474,16475,16476,16477,16478,16479,16480,16481,16482,16483,16484,16485,16486,16487,16488,16489,16490,16492,16493,16494,16495,16496,16497,16498,16499,16500,16501,16502,16503,16504,16505,16506,16507,16508,16509,16510,16511,16512,16513,16514,16515,16516,16517,16518,16519,16520,16521,16522,16523,16524,16525,16526,16527,16528,16539,16590,16607,16633,16634,16635,16636,16637,16638,16640,16663,16677,16680,16681,16682,16701,16702,16703,16708,16709,16710,16711,16712,16713,16717,16718,16719,16720,16721,16801,16722,16723,16724,16725,16726,16727,16728,16729,16730,16731,16732,16733,16734,16735,16736,16737,16738,16739,16740,16741,16742,16743,16759,16777,16778,16779,16780,16781,16782,16783,16787,16788,16831,16832,16833,16834,16835,16836,16848,16867,16869,16873,16915,16937,16960,16961,16962,16963,16964,16965,16983,16984,16985,16987,16988,16989,16990,16991,17019,17020,17025,17026,17042,17043,17044,17045,17051,17052,17053,17054,17061,17062,17081,17082,17083,17084,17085,17139,17140,17141,17142,17143,17160,17164,17185,17186,17187,17188,17189,17190,17191,17192,17202,17203,17204,17220,17221,17222,17227,17228,17230,17231,17234,17251,17252,17253,17254,17255,17256,17257,17258,17259,17260,17261,17269,17294,17295,17296,17298,17299,17319,17346,17347,17348,17349,17350,17373,17382,17383,17395,17396,17398,17399,17400,17401,17403,17444,17446,17447,17448,17450,17451,17453,17469,17470,17471,17502,17521,17522,17524,17549,17550,17551,17552,17553,17599,17600,17601,17602,17603,17605,17635,17636,17637,17638,17639,17652,17661,17662,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,17677,17678,17679,17680,17681,17682,17683,17684,17685,17686,17687,17688,17689,17690,17691,17692,17693,17694,17695,17696,17697,17698,17699,17700,17701,17702,17703,17704,17705,17706,17707,17711,17712,17713,17731,17732,17763,17764,17765,17766,17767,17783,17805,17806,17807,17810,17811,17823,17824,17825,17826,17848,17849,17850,17851,17852,17853,17854,17855,17856,17857,17870,17871,17872,17873,17902,17903,17904,17907,17908,17909,17910,17911,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17922,17923,17924,17925,17926,17927,17928,18604,18610,18611,18612,18613,18614,18615,18618,18621,18666,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18942,18943,18944,18945,18946,18947,18948,18949,18950,18951,18952,18953,18954,18955,18956,18957,18958,18959,18960,18961,18962,18963,18964,18965,18966,18967,18968,18969,18970,18971,18972,18973,18974,18975,18976,18977,18978,18979,18980,18981,18982,18983,18984,18985,18986,18987,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19002,19003,19004,19005,19006,19007,19008,19009,19010,19011,19012,19013,19014,19015,19016,19017,19018,19019,19020,19021,19022,19023,19024,19025,19026,19027,19028,19029,19030,19031,19032,19033,19034,19035,19036,19037,19038,19039,19040,19041,19042,19043,19044,19045,19046,19047,19048,19049,19050,19051,19052,19053,19054,19055,19056,19057,19058,19059,19060,19061,19062,19063,19064,19065,19066,19067,19068,19069,19070,19071,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19082,19083,19084,19085,19086,19087,19088,19089,19090,19091,19092,19093,19094,19095,19096,19097,19098,19099,19100,19101,19102,19103,19104,19105,19106,19107,19108,19109,19110,19111,19112,19113,19114,19115,19116,19117,19118,19119,19120,19121,19122,19123,19124,19125,19126,19127,19128,19129,19130,19131,19132,19133,19134,19135,19136,19137,19138,19139,19140,19141,19142,19143,19144,19145,19146,19147,19148,19149,19150,19151,19152,19153,19154,19155,19156,19157,19158,19159,19160,19161,19162,19163,19164,19165,19166,19167,19168,19169,19170,19279,19280,19281,19282,19283,19284,19285,19286,19287,19288,20172,20173,20174,20175,20176,20177,20178,20179,20180,20181,20182,20183,20184,20185,20186,20187,20188,20189,20190,20191,20192,20193,20194,20195,20196,20198,20199,20200,20201,20202,20203,20204,20205,20206,20207,20208,20209,20210,20211,20212,20213,20214,20215,20216,20217,20218,20219,20220,20221,20222,20223,20224,20225,20226,20227,20228,20229,20230,20231,20232,20233,20234,20235,20236,20237,20238,20239,20240,20241,20242,20243,20244,20245,20247,20248,20249,20251,20252,20253,20254,20255,20256,20257,20258,20259,20260,20261,20262,20263,20264,20265,20266,20267,20268,20269,20270,20808,20272,20273,20274,20275,20276,20277,20278,20279,20280,20281,20282,20283,20284,20285,20286,20287,20288,20289,20290,20291,20292,20293,20294,20295,20296,20297,20298,20299,20300,20301,20302,20303,20304,20305,20306,20307,20308,20309,20310,20311,20312,20313,20314,20315,20316,20317,20318,20319,20320,20321,20323,20324,20325,20326,20327,20328,20329,20330,20331,20332,20333,20334,20335,20336,20337,20338,20339,20340,20341,20342,20343,20344,20345,20346,20347,20348,20349,20350,20351,20352,20353,20354,20355,20356,20357,20358,20360,20361,20362,20363,20364,20365,20366,20367,20368,20369,20370,20371,20372,20373,20374,20375,20376,20377,20378,20379,20380,20381,20382,20383,20384,20385,20386,20387,20388,20389,20390,20391,20392,20393,20394,20395,20396,20397,20398,20399,20400,20401,20402,20403,20404,20405,20406,20407,20408,20409,20410,20411,20446,20519,20524,20525,20526,20527,20528,20529,20530,20531,20532,20533,20534,20535,20536,20537,20538,20539,20540,20541,20542,20543,20544,20545,20546,20547,20548,20549,20550,20551,20552,20553,20554,20555,20556,20557,20558,20559,20560,20561,20562,20563,20564,20565,20566,20567,20569,20570,20571,20572,20573,20574,20575,20576,20590,20591,20592,20593,20594,20595]
    # skips = [10709, 17619, 10541, 19229, 20001, 20037, 19232, 20029, 21413, 19412, 25097, 25239, 30037, 30040, 30041, 30042, 30034, 30035, 30045, 30083, 30098, 25003, 25361, 19523, 19636, 19717, 20004, 20583, 20612, 20916, 20973, 20975, 21455, 21473, 25329, 25373, 26285, 20627, 25698, 26430, 26901, 10491, 21447, 27044, 27013, 25042, 26062, 19875, 18840, 20132, 28767, 27782, 21030, 26771]

    # inquiry_numbers = [26289, 29944]
    totals = {}
    inquiry_not_found = []
    odd_order_names = []
    sales_order_exists = []
    service.loop(nil) do |x|
      i = i + 1
      # next if i < 11729
      next if !x.get_column('product sku').upcase.in?(['BM1A9O9', 'BM1Z9F4', 'BM1Z8Z7', 'BM0Z1F1', 'BM0P0K2', 'BM0Z0I8', 'BM0P0J9', 'BM0Z0I9', 'BM9C4D9', 'BM9B7R8', 'BM0L0D8', 'BM9B7M5', 'BM9C9L6', 'BM0C718', 'BM0Q7E2', 'BM9C4F8', 'BM00038', 'BM00039', 'BM00034', 'BM00035', 'BM00036', 'BM00037', 'BM9Y7F5', 'BM9U9M5', 'BM9Y6Q3', 'BM9P8F4', 'BM9P8G5', 'CUM01', 'BM5P9Y7'])
      # next if !inquiry_numbers.include?(x.get_column('inquiry number').to_i)
      # next if Product.where(sku: x.get_column('product sku')).present? == false
      puts '*********************** INQUIRY ', x.get_column('inquiry number')
      o_number = x.get_column('order number')
      if o_number.include?('.') || o_number.include?('/') || o_number.include?('-') || o_number.match?(/[a-zA-Z]/)
        odd_order_names.push(o_number)
      end
      puts "<-------------------#{o_number}"
      next if odd_order_names.include?(o_number)

      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry number'))
      if inquiry.present?

        if !inquiry.billing_address.present?
          inquiry.update(billing_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_address.present?
          inquiry.update(shipping_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_contact.present?
          inquiry.update(shipping_contact: inquiry.billing_contact)
        end

        sales_quote = inquiry.sales_quotes.last
        if sales_quote.blank?
          sales_quote = inquiry.sales_quotes.create!(overseer: inquiry.inside_sales_owner)
        end

        product_sku = x.get_column('product sku').upcase
        puts 'SKU', product_sku
        product = Product.find_by_sku(product_sku)

        inquiry_products = inquiry.inquiry_products.where(product_id: product.id)
        if inquiry_products.blank?
          similar_products = Product.where(name: product.name).where.not(sku: product.sku)
          if similar_products.present?
            similar_products.update_all(is_active: false)
          end
          sr_no = inquiry.inquiry_products.present? ? (inquiry.inquiry_products.last.sr_no + 1) : 1
          inquiry_product = inquiry.inquiry_products.where(product_id: product.id, sr_no: sr_no, quantity: x.get_column('quantity')).first_or_create!
        else
          inquiry_product = inquiry_products.first
          inquiry_product.update_attribute('quantity', inquiry_product.quantity + x.get_column('quantity').to_f)
        end

        supplier = Company.acts_as_supplier.find_by_name(x.get_column('supplier')) || Company.acts_as_supplier.find_by_name('Local')
        inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
        inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('unit cost price').to_f)
        row = nil
        if inquiry.sales_orders.pluck(:order_number).include?(x.get_column('order number').to_i)
          so = SalesOrder.find_by_order_number(x.get_column('order number').to_i)
          if so.rows.map {|r| r.product.sku}.include?(x.get_column('product sku'))
            row = sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('product sku')).first
          end
        end
        if row.blank?
          row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
        end

        tax_rate = TaxRate.where(tax_percentage: x.get_column('tax rate').to_f).first_or_create!
        row.unit_selling_price = x.get_column('unit selling price (INR)').to_f
        row.quantity = x.get_column('quantity')
        row.margin_percentage = x.get_column('margin percentage')
        row.converted_unit_selling_price = x.get_column('unit selling price (INR)').to_f
        row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
        row.measurement_unit = MeasurementUnit.find_by_name(x.get_column('measurement unit')) || MeasurementUnit.default
        row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
        row.tax_rate = tax_rate || nil
        row.created_at = x.get_column('created at', to_datetime: true)

        row.save!

        puts '**************** QUOTE ROW SAVED ********************'


        sales_order = sales_quote.sales_orders.where(order_number: x.get_column('order number')).first_or_create!
        sales_order.overseer = inquiry.inside_sales_owner
        sales_order.order_number = x.get_column('order number')
        sales_order.created_at = x.get_column('created at', to_datetime: true)
        sales_order.mis_date = x.get_column('created at', to_datetime: true)

        sales_order.status = x.get_column('status') || 'Approved'
        sales_order.remote_status = x.get_column('SAP status') || 'Processing'
        sales_order.sent_at = sales_quote.created_at
        sales_order.save!
        row_object = {sku: product_sku, supplier: x.get_column('supplier'), total_with_tax: row.total_selling_price_with_tax.to_f}
        totals[sales_order.order_number] ||= []
        totals[sales_order.order_number].push(row_object)
        puts '************************** ORDER SAVED *******************************'
        so_row = sales_order.rows.where(sales_quote_row: row).first_or_create!

        puts '****************** ORDER TOTAL ****************************', sales_order.order_number, sales_order.calculated_total_with_tax
      else
        if !inquiry.present?
          inquiry_not_found.push(x.get_column('inquiry number'))
        end
      end
      puts totals
      puts '<----------------------------------------INQUIRIES--------------------------------------------------->'
      puts inquiry_not_found.inspect
    end
  end

  def update_invoice_statuses
    missing_invoices = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('cancelled_sales_invoices.csv', folder)
    service.loop(limit) do |x|
      sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('Invoice Number'))
      if sales_invoice.present? && sales_invoice.sales_order.present?
        sales_invoice.status = 3
        sales_invoice.metadata['state'] = 3 if sales_invoice.metadata.present?
        sales_invoice.save!
      else
        missing_invoices << x.get_column('Invoice Number')
      end
    end
    puts 'Missing Invoices', missing_invoices
  end

  def update_cancelled_po_statuses
    missing_po = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('cancelled_purchase_orders.csv', folder)
    service.loop(limit) do |x|
      po = PurchaseOrder.find_by_po_number(x.get_column('Purchase Order Number'))
      if po.present?
        po.metadata['PoStatus'] = 95
        po.save!
      else
        missing_po << x.get_column('Purchase Order Number')
      end
    end
    puts 'Missing PO', missing_po
  end

  def update_po_status
    PurchaseOrder.all.each do |po|
      if po.metadata['PoStatus'].present?
        if po.metadata['PoStatus'].to_i > 0
          po.status = po.metadata['PoStatus'].to_i
        else
          po.status = PurchaseOrder.statuses[po.metadata['PoStatus']]
        end
        po.save
      end
    end
  end

  def update_mis_date_of_missing_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('mis_date_for_missing_orders.csv', 'seed_files')
    missing_so = []
    service.loop(nil) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order number'))
      if sales_order.present?
        sales_order.update_attribute('mis_date', x.get_column('mis date', to_datetime: true))
      else
        missing_so.push(x.get_column('order number'))
      end
    end
    puts '<--------------------------------------------------------------------------------------------->'
    puts missing_so
  end

  # SalesOrder.where(:manager_so_status_date => nil).count
  def sup_emails
    Company.acts_as_supplier.each do |supplier|
      name = supplier.name
      sup_code = supplier.remote_uid
      email = if supplier.default_company_contact_id.blank? && supplier.company_contacts.first.present?
                supplier.company_contacts.first.contact.email
              elsif supplier.default_company_contact_id.present?
                supplier.default_company_contact.contact.email
              else
                supplier.legacy_email
              end
    end
  end

  def add_manager_approved_date
    SalesOrder.approved.each do |sales_order|
      sales_order.update_attributes!(manager_so_status_date: sales_order.approval.created_at) if sales_order.approval.present?
    end
  end


  def add_manager_rejected_date
    SalesOrder.rejected.each do |sales_order|
      sales_order.update_attributes!(manager_so_status_date: sales_order.rejection.created_at) if sales_order.rejection.present?
    end
  end

  def draft_sync_date
    SalesOrder.all.each do |sales_order|
      if sales_order.manager_so_status_date.present?
        draft_remote_request = RemoteRequest.where(subject_type: 'SalesOrder', subject_id: sales_order.id, status: 'success').first
        if draft_remote_request.present?
          sales_order.update_attributes!(draft_sync_date: draft_remote_request.created_at)
        end
      end
    end
  end

  def generate_review_questions
    service = Services::Shared::Spreadsheets::CsvImporter.new('review_questions.csv', 'seed_files')

    service.loop() do |x|
      question = x.get_column('Question')
      type = x.get_column('Type')
      weightage = x.get_column('Weightage')
      ReviewQuestion.where(question: question, question_type: type, weightage: weightage).first_or_create!
    end
  end

  def create_company_banks
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_banks.csv', folder)
    errors = []
    service.loop(nil) do |x|
      begin
        company = Company.find_by_remote_uid(x.get_column('bp_code'))
        bank = Bank.find_by_code(x.get_column('bank_code'))
        if company
          company_bank = CompanyBank.where(remote_uid: x.get_column('internal_key')).first_or_initialize
          if company_bank.new_record? || update_if_exists
            company_bank.company = company
            company_bank.bank = bank
            company_bank.account_name = x.get_column('account_name')
            company_bank.account_number = x.get_column('account_no')
            company_bank.account_number_confirmation = x.get_column('account_no')
            company_bank.branch = x.get_column('branch')
            company_bank.mandate_id = x.get_column('mandate_id')
            company_bank.metadata = x.get_row
            company_bank.save!
          end
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('internal_key')}")
      end
    end
    puts errors
  end

  def create_banks
    service = Services::Shared::Spreadsheets::CsvImporter.new('banks.csv', folder)
    errors = []
    service.loop(nil) do |llx|
      begin
        bank = Bank.where(code: x.get_column('Bank Code')).first_or_initialize
        if bank.new_record? || update_if_exists
          bank.name = x.get_column('Bank Name')
          bank.country_code = x.get_column('Country Code')
          bank.remote_uid = x.get_column('Absolute entry')
          bank.save!
        end
      rescue => e
        errors.push("#{e.inspect} - #{x.get_column('Bank Code')}")
      end
    end
    puts errors
  end

  def update_purchase_order_material_status
    PurchaseOrder.where(material_status: nil).update_all(material_status: 'Material Readiness Follow-Up')
    PurchaseOrder.all.each do |po|
      if po.material_pickup_requests.any?
        partial = true
        if po.rows.sum(&:get_pickup_quantity) <= 0
          partial = false
        end
        status = if 'Material Pickup'.in? po.material_pickup_requests.map(&:status)
                   partial ? 'Material Partially Pickup' : 'Material Pickedup'
                 elsif 'Material Delivered'.in? po.material_pickup_requests.map(&:status)
                   partial ? 'Material Partially Delivered' : 'Material Delivered'
                 end
        po.update_attribute(:material_status, status)
      else
        po.update_attribute(:material_status, 'Material Readiness Follow-Up')
      end
      po.save
    end
  end

  def update_total_cost_in_sales_order
    SalesOrder.all.each do |so|
      so.order_total = so.calculated_total
      so.invoice_total = so.invoices.map {|i| i.metadata.present? ? (i.metadata['base_grand_total'].to_f - i.metadata['base_tax_amount'].to_f) : 0.0}.inject(0) {|sum, x| sum + x}
      so.save
    end
  end


  def add_logistics_owner_to_companies
    Company.all.each do |company|
      service = Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(nil, company_name: company.name)
      company.logistics_owner = service.call
      company.save(validate: false)
    end
  end

  def update_mis_date_of_missing_orders
    service = Services::Shared::Spreadsheets::CsvImporter.new('mis_date_for_missing_orders.csv', 'seed_files')
    missing_so = []
    service.loop(nil) do |x|
      sales_order = SalesOrder.find_by_order_number(x.get_column('order number'))
      if sales_order.present?
        sales_order.update_attribute('mis_date', x.get_column('mis date', to_datetime: true))
      else
        missing_so.push(x.get_column('order number'))
      end
    end
    puts '<--------------------------------------------------------------------------------------------->'
    puts missing_so
  end

  def sup_emails
    Company.acts_as_supplier.each do |supplier|
      name = supplier.name
      sup_code = supplier.remote_uid
      email = if supplier.default_company_contact_id.blank? && supplier.company_contacts.first.present?
                supplier.company_contacts.first.contact.email
              elsif supplier.default_company_contact_id.present?
                supplier.default_company_contact.contact.email
              else
                supplier.legacy_email
              end
    end
  end

  def create_missing_invoices
    kit_products = []
    missing_product = []
    missing_bible_orders = []
    odd_invoice_names = []
    missing_bible_invoices = []
    created_or_updated_invoices = []
    duplicate_invoices = [20710032]
    inquiry_numbers = [1, 2, 25, 2978, 3329, 48, 53, 66, 67, 27, 213, 203, 222, 246, 14, 145, 211, 228, 90, 139, 200, 235, 11, 171, 254, 270, 96, 99, 269, 281, 283, 297, 307, 271, 305, 314, 377, 147, 253, 309, 350, 217, 30, 34, 138, 402, 3, 12, 15, 82, 84, 86, 100, 103, 107, 129, 159, 321, 405, 395, 469, 470, 432, 452, 480, 373, 478, 10, 426, 425, 453, 404, 16, 809, 688, 511, 207, 672, 722, 287, 515, 919, 407, 784, 311, 886, 791, 585, 959, 960, 1007, 1018, 995, 1016, 255, 419, 532, 915, 1032, 901, 1071, 1021, 1081, 481, 554, 971, 975, 1033, 957, 1017, 690, 1011, 1020, 1066, 1273, 1116, 1117, 1133, 1138, 257, 858, 1053, 568, 675, 1008, 1044, 1048, 1097, 1173, 352, 660, 729, 831, 832, 1039, 1152, 1178, 1015, 1189, 1057, 1204, 1293, 1200, 1201, 648, 865, 1260, 968, 1218, 1268, 520, 652, 820, 918, 1122, 1323, 1342, 667, 1358, 1350, 967, 972, 1083, 1373, 1431, 1443, 288, 961, 1175, 1420, 1451, 735, 1487, 1037, 1078, 1228, 1483, 516, 196, 1159, 1432, 969, 1353, 1447, 796, 1417, 1507, 1636, 1674, 1376, 1389, 1513, 1555, 1147, 1532, 1742, 1242, 1476, 1481, 1214, 1778, 1727, 1746, 1517, 1788, 1406, 1805, 1397, 1779, 1591, 1827, 1844, 1864, 1315, 1318, 1401, 1687, 897, 1459, 1574, 1824, 1266, 2008, 1546, 1829, 1272, 966, 993, 1042, 1763, 1868, 1901, 540, 1221, 1494, 1667, 1710, 2118, 2065, 1770, 1461, 1740, 1986, 2216, 994, 2188, 2239, 892, 1775, 813, 819, 893, 1463, 2108, 2120, 2202, 2208, 2210, 2298, 1430, 1900, 1975, 2270, 2236, 1163, 2005, 2014, 1696, 1885, 2226, 2367, 2018, 2212, 2420, 1887, 1840, 2195, 1473, 1073, 1639, 2408, 1691, 1831, 2550, 2597, 817, 1671, 2616, 1893, 2636, 1197, 2211, 2643, 2644, 2645, 2306, 2658, 1851, 2439, 2137, 2237, 2429, 2460, 2522, 2674, 2058, 2052, 2241, 2336, 2691, 2503, 2338, 2170, 2462, 2479, 2514, 2668, 2049, 2722, 2424, 2734, 2048, 1426, 2744, 2755, 1765, 2647, 814, 2507, 1054, 2776, 2617, 2794, 2772, 2801, 2800, 2826, 2833, 1871, 2257, 2534, 2678, 2729, 2732, 2779, 2361, 2588, 2036, 2723, 2903, 932, 2867, 2914, 2864, 2942, 1558, 2843, 2950, 2927, 2957, 2958, 2962, 2861, 2967, 2981, 2992, 2134, 2730, 2952, 2995, 2050, 2997, 2998, 2999, 2349, 2725, 7278, 3025, 2865, 3021, 2505, 2777, 2119, 3053, 2838, 2859, 1587, 3068, 3085, 3086, 3088, 3092, 2947, 3098, 2918, 3028, 3089, 3136, 3115, 2953, 2963, 3043, 3081, 3120, 3124, 3142, 7689, 7695, 3060, 3105, 3111, 3157, 6448, 7119, 2848, 3225, 3564, 3083, 3117, 3190, 3033, 3073, 3178, 3242, 3244, 3248, 3185, 3006, 3041, 3270, 3097, 3186, 3263, 3159, 3237, 3252, 3285, 3308, 3291, 3305, 2912, 3289, 3304, 3307, 3152, 3158, 3287, 3354, 3355, 3361, 3367, 3370, 2915, 3351, 1398, 3224, 3397, 3074, 3141, 3202, 3234, 3328, 3333, 3411, 3099, 3261, 3401, 2685, 3079, 3163, 3228, 3412, 3428, 3058, 3439, 3070, 3444, 3458, 3461, 2917, 3403, 3437, 3539, 3035, 3238, 3391, 3485, 3491, 3496, 3463, 3126, 3295, 3402, 3423, 3467, 3457, 3500, 3515, 2448, 3425, 3494, 3534, 3550, 3560, 3571, 3250, 3473, 3573, 3478, 3532, 3483, 3489, 3526, 3540, 3586, 3601, 3452, 3594, 3625, 1760, 3456, 3630, 3638, 2908, 3525, 3616, 3455, 4009, 4044, 3169, 3618, 3624, 3627, 3662, 4003, 3245, 3216, 3544, 4008, 4010, 4017, 4018, 6362, 4280, 4032, 4042, 3535, 4050, 3347, 3605, 4040, 4029, 4054, 4087, 3659, 4006, 4103, 9746, 4120, 2925, 3667, 4132, 4136, 3474, 3609, 4031, 4104, 4106, 4166, 4167, 4170, 3635, 4080, 4093, 4096, 4124, 4184, 3531, 3577, 4130, 4187, 3592, 3613, 4062, 4147, 4153, 4239, 3612, 3626, 4081, 4192, 4216, 4238, 4242, 4140, 4156, 4266, 4245, 3528, 4247, 4267, 9744, 4024, 4112, 4161, 4168, 4272, 4099, 4150, 4033, 4077, 4231, 4232, 4233, 4234, 4243, 3617, 4076, 4172, 4223, 4296, 4316, 4072, 4177, 4330, 4336, 4342, 4351, 2804, 4064, 4107, 4194, 3221, 4290, 4307, 4327, 4663, 9913, 4193, 4230, 4365, 4367, 4368, 3426, 4375, 4162, 4333, 4376, 4380, 4382, 4384, 5868, 4256, 4390, 4405, 4407, 4455, 7106, 4195, 4430, 3005, 4423, 4439, 4446, 4448, 3541, 4289, 4297, 4299, 4572, 9740, 555, 4478, 8832, 479, 3663, 4090, 4422, 4479, 4489, 4491, 7105, 4277, 4203, 4226, 4228, 4349, 4483, 4485, 4493, 4507, 4523, 4211, 4308, 4498, 4521, 4531, 4532, 4311, 4381, 4389, 4403, 4435, 4582, 4583, 4854, 4340, 3523, 4292, 4320, 4440, 4459, 4509, 4510, 4540, 4588, 4589, 4590, 4608, 4613, 5096, 9748, 4458, 4543, 4609, 4648, 9747, 4352, 4477, 4606, 4668, 4434, 4505, 4682, 4269, 2784, 3542, 4447, 4693, 4702, 4710, 4241, 4656, 4661, 4684, 4734, 4777, 5481, 6708, 2721, 2739, 4373, 4468, 4541, 4652, 4714, 4721, 5047, 4525, 4747, 4755, 4758, 4662, 4763, 4659, 3632, 4810, 4687, 4824, 4914, 4374, 4610, 4735, 4814, 4842, 4733, 5355, 4469, 4499, 4893, 4899, 4904, 4909, 4598, 4649, 476, 4913, 5338, 4343, 4725, 4745, 4765, 4766, 4775, 4954, 5102, 4776, 4865, 4992, 5004, 4567, 4883, 4950, 4983, 4451, 4660, 4772, 5022, 5027, 5044, 5049, 5053, 4201, 4295, 4494, 4566, 4685, 4949, 5001, 5091, 4034, 4889, 5015, 6884, 6886, 6887, 6888, 5101, 5145, 4605, 5088, 5089, 5105, 5152, 5167, 4959, 5007, 5171, 4906, 5014, 5078, 5169, 5180, 5191, 4998, 5094, 5223, 5226, 4346, 4789, 5010, 5087, 5158, 4284, 4863, 5289, 9750, 4618, 4671, 4677, 4724, 4727, 4826, 4862, 4895, 5025, 5028, 5032, 5160, 5213, 5215, 5216, 5217, 5219, 5224, 5225, 5258, 5268, 5386, 5416, 5426, 5436, 5461, 5476, 5514, 5528, 5543, 5594, 5611, 5615, 5293, 3639, 4646, 4880, 5316, 3260, 4972, 5240, 5341, 5350, 5359, 5399, 5319, 5401, 9745, 5026, 5195, 5378, 4759, 5157, 5308, 3645, 5248, 5321, 5363, 6268, 4401, 5322, 5397, 5427, 5487, 5246, 5304, 5439, 5447, 4850, 5063, 5423, 5507, 4565, 5331, 5490, 542, 5008, 5005, 4436, 5155, 5496, 6167, 4275, 5214, 5393, 5405, 5465, 5505, 9752, 9753, 9754, 9755, 9756, 9757, 2847, 5108, 5260, 5470, 6273, 5469, 5415, 5610, 6172, 5534, 5634, 5653, 5572, 5574, 5064, 3383, 4073, 4670, 5066, 5349, 5616, 5671, 5680, 5800, 6283, 9758, 5269, 5518, 5535, 5612, 5637, 5645, 5677, 5732, 5674, 3404, 4961, 5351, 5409, 5477, 5688, 5701, 5702, 5704, 5777, 5249, 5691, 5725, 5593, 5733, 5545, 5683, 5717, 5744, 5747, 5749, 4966, 5369, 5403, 5494, 5557, 5585, 5676, 5751, 5766, 5779, 5199, 5257, 5726, 5786, 5303, 5785, 5805, 5817, 6063, 4963, 5686, 5763, 5816, 5340, 5720, 5853, 5699, 5782, 5875, 5780, 5897, 5824, 5913, 5924, 5776, 5847, 4465, 5442, 5938, 5940, 5673, 5958, 5959, 5960, 5950, 5822, 5978, 4370, 5463, 5670, 5791, 5865, 5966, 6010, 6001, 6007, 5997, 6029, 6087, 6044, 6030, 6037, 5267, 6076, 6118, 5956, 6069, 6075, 5951, 6048, 5718, 5806, 6068, 5510, 5635, 5819, 5922, 5957, 6051, 6119, 6129, 5775, 5781, 6130, 6215, 6755, 6046, 6143, 6156, 6168, 6169, 5970, 5971, 6176, 6177, 5618, 6085, 6116, 6131, 6138, 5920, 6222, 7343, 5252, 6039, 6158, 6109, 6247, 6249, 6148, 6150, 6212, 6214, 6274, 6282, 6544, 6547, 6548, 5553, 5928, 6106, 6296, 6314, 6315, 6133, 6170, 6206, 6245, 6250, 6306, 6327, 6210, 6269, 6330, 6489, 4986, 5006, 5279, 5480, 5834, 5921, 6045, 6052, 6070, 6297, 6331, 6338, 6344, 6354, 6681, 6712, 5728, 5730, 6700, 6233, 6320, 6346, 6349, 6477, 6523, 6270, 6279, 6364, 5475, 5944, 6055, 6395, 6678, 5692, 5988, 6195, 6251, 6418, 6425, 6484, 6217, 6456, 6471, 6293, 6437, 5807, 6018, 6278, 6253, 6280, 6496, 6292, 6366, 5916, 6160, 6322, 6332, 6472, 6533, 6541, 6737, 6027, 6517, 8839, 6382, 6487, 6500, 6525, 6585, 6591, 5998, 6077, 6213, 6025, 6071, 6307, 6328, 6378, 6386, 6394, 6572, 6748, 6242, 6658, 6260, 6570, 6615, 6632, 5184, 6256, 6539, 6573, 6661, 6670, 6677, 6729, 6735, 6650, 3138, 5450, 6705, 6758, 6787, 4903, 5643, 6183, 6611, 6674, 5040, 6577, 6767, 6575, 6581, 6772, 6184, 6299, 6733, 6824, 6103, 6859, 6667, 6727, 6908, 6646, 6815, 6868, 6934, 6962, 6072, 6954, 6821, 6432, 6854, 7036, 7053, 7382, 5198, 5678, 6102, 6141, 6171, 6255, 6302, 6313, 6340, 6361, 6392, 6410, 6450, 6495, 6590, 6603, 6626, 6653, 6671, 6673, 6691, 6696, 6723, 6738, 6741, 6762, 6771, 6773, 6784, 6785, 6789, 6792, 6800, 6801, 6802, 6803, 6808, 6809, 6810, 6813, 6814, 6816, 6825, 6836, 6842, 6851, 6852, 6853, 6855, 6856, 6858, 6869, 6870, 6879, 6881, 6882, 6885, 6889, 6894, 6895, 6898, 6902, 6903, 6904, 6914, 6918, 6921, 6945, 6947, 6948, 6949, 6950, 6961, 6969, 6975, 6976, 6978, 6980, 6981, 6985, 6988, 6991, 7000, 7013, 7017, 7019, 7022, 7031, 7038, 7044, 7047, 7048, 7054, 7055, 7481, 7008, 6933, 7033, 7083, 6923, 6953, 7081, 7103, 6805, 7128, 7129, 7135, 6560, 5736, 5961, 6628, 6807, 7139, 7144, 6843, 6901, 6958, 7158, 7163, 7165, 7167, 7168, 7169, 7170, 7171, 7174, 6512, 7096, 7113, 7160, 6946, 7104, 7178, 7189, 15076, 6796, 7037, 7161, 7176, 6494, 6710, 6957, 7251, 6337, 6797, 6910, 7003, 7166, 7221, 7242, 7250, 7230, 7243, 6768, 7256, 7164, 7248, 6878, 6907, 7127, 7203, 7240, 7238, 7281, 7293, 6779, 7325, 6876, 7492, 7493, 7494, 7496, 7498, 7500, 7501, 7502, 7503, 7148, 7347, 7357, 6774, 7182, 7237, 7442, 6717, 7086, 7390, 7408, 7537, 7548, 7591, 4870, 6311, 7249, 7483, 7485, 7486, 9495, 6909, 7149, 7193, 7317, 7322, 7272, 7460, 7467, 7126, 7266, 7463, 7488, 6982, 7437, 7441, 9063, 6405, 7216, 7363, 7423, 7425, 7529, 7530, 7547, 7553, 7563, 7569, 7571, 7576, 7590, 5604, 6140, 7134, 5483, 6602, 7592, 7603, 7605, 7606, 7723, 8144, 7452, 7526, 7620, 6526, 6652, 6719, 7056, 7074, 7210, 7361, 7424, 7554, 7565, 7582, 7583, 7595, 7602, 7633, 7635, 7642, 7645, 7647, 7648, 7650, 7651, 7664, 7669, 7782, 7297, 7400, 7528, 7142, 7688, 7701, 7705, 7562, 7622, 7697, 7698, 7740, 7743, 7329, 7506, 5672, 7247, 7326, 7406, 7409, 7418, 7513, 7653, 7658, 7683, 7755, 7792, 7866, 8027, 8109, 8116, 8157, 8159, 8161, 7555, 7943, 10173, 10264, 7752, 7794, 5989, 7444, 7745, 7549, 7639, 7741, 8206, 8211, 8213, 7287, 7346, 7834, 7871, 7737, 7084, 7889, 7825, 7540, 7445, 7702, 7798, 7828, 7939, 7623, 7453, 7564, 7732, 7809, 7860, 7941, 8201, 8200, 7535, 7691, 7909, 7976, 7982, 7729, 7735, 7978, 7979, 7990, 7993, 8029, 7818, 7995, 7996, 7997, 8004, 8005, 7822, 7937, 7988, 8003, 7699, 7829, 7878, 7896, 8028, 8051, 7801, 7864, 8083, 7627, 7874, 7992, 9096, 7942, 8033, 8006, 6604, 7271, 7433, 7624, 7795, 7814, 7821, 7832, 7908, 7935, 7944, 7968, 7969, 7985, 8008, 8016, 8018, 8067, 8104, 8110, 8123, 6616, 7852, 7873, 7980, 8082, 6931, 7913, 8112, 8137, 8147, 6530, 7471, 7607, 7608, 7807, 7975, 8015, 8156, 8162, 8163, 8164, 8165, 8166, 8167, 8168, 8172, 8173, 8175, 7262, 7826, 7827, 10096, 10119, 10184, 10237, 10260, 10266, 10268, 10269, 10270, 10275, 10276, 10277, 10281, 10316, 6701, 7212, 7754, 7926, 8044, 8105, 8139, 8154, 7918, 8107, 8129, 8205, 7760, 7931, 8313, 8214, 8235, 7376, 7970, 8176, 8194, 8232, 8250, 8252, 8108, 8249, 8251, 8267, 8191, 8270, 7831, 7994, 8098, 8177, 8285, 8287, 8294, 8295, 8296, 8073, 8089, 8299, 8300, 8301, 8302, 8303, 8305, 8306, 8178, 8284, 8322, 8288, 8315, 7550, 7915, 8337, 7815, 8141, 7455, 7574, 8025, 8212, 8223, 8225, 8293, 8325, 5923, 7930, 8304, 8341, 8282, 8283, 8385, 8386, 8387, 8388, 8390, 8391, 8392, 8393, 8395, 8047, 8350, 8394, 9853, 9856, 7999, 8317, 8334, 8353, 8039, 8382, 8427, 8368, 8400, 7929, 8198, 8414, 8415, 8196, 8399, 8406, 8430, 8439, 8444, 8043, 8195, 8209, 8364, 4791, 8229, 8236, 8434, 7392, 8142, 7446, 8445, 8446, 8482, 7981, 8336, 8423, 8525, 8475, 8521, 7107, 8314, 8805, 8373, 8515, 7817, 8361, 8455, 8500, 8506, 8548, 6713, 8558, 8700, 8727, 7644, 7781, 8278, 8498, 8630, 8633, 9158, 14834, 8024, 8053, 8389, 8404, 7015, 8349, 8460, 8510, 8531, 8536, 8572, 8253, 8491, 8557, 8604, 8615, 5869, 7244, 7899, 8226, 8310, 8338, 8362, 8443, 8489, 8517, 8579, 8626, 8631, 8638, 8640, 8643, 8658, 8665, 8666, 8667, 8668, 8670, 8671, 8680, 8682, 8689, 8694, 8738, 8331, 8818, 8599, 8701, 8743, 7367, 8088, 8355, 8359, 8486, 8563, 8605, 8706, 8709, 8713, 8718, 8721, 8728, 8731, 8881, 8509, 8705, 8740, 8744, 8553, 8595, 8757, 8808, 8524, 8755, 8777, 8662, 8779, 8202, 8342, 8762, 8795, 8874, 8636, 8761, 7265, 8546, 8838, 8845, 8215, 8565, 8632, 8733, 8788, 8854, 8900, 8907, 8407, 8865, 8915, 8985, 8986, 8124, 8193, 8577, 8677, 8751, 8823, 8852, 8890, 8912, 8931, 8138, 8481, 8710, 8724, 8827, 8952, 8965, 8971, 7407, 7638, 8372, 8408, 8613, 8820, 8928, 8934, 8953, 8754, 8975, 8990, 8810, 10279, 7998, 8570, 8809, 8883, 8923, 8471, 8518, 9002, 9003, 9012, 8989, 9016, 9026, 8741, 9039, 9048, 9056, 9069, 8409, 8562, 8817, 9011, 9073, 9078, 9082, 9084, 8940, 10055, 10056, 10057, 10058, 10059, 10060, 8679, 8765, 8867, 8948, 9075, 9102, 8541, 8842, 8844, 8927, 8996, 9119, 7448, 8782, 8853, 8930, 9038, 9107, 9141, 9157, 9162, 9168, 9175, 8153, 8970, 8549, 8739, 9079, 9148, 9163, 9195, 9196, 9213, 9050, 9216, 8477, 8868, 8878, 8904, 8946, 9153, 9174, 9181, 9197, 9212, 9227, 15693, 8345, 8429, 9022, 9133, 9139, 9198, 9221, 9224, 9254, 9259, 9263, 8367, 9122, 9207, 9266, 8939, 9186, 9295, 8145, 9028, 9305, 9312, 9319, 8760, 8869, 8902, 9006, 9334, 9340, 7558, 8894, 8995, 9185, 9256, 9337, 9343, 9323, 9359, 9099, 9129, 9137, 9292, 9375, 9389, 9390, 7617, 8602, 9335, 9360, 9387, 9406, 9425, 9448, 8753, 8949, 9047, 9205, 9366, 9374, 9429, 9455, 9459, 9502, 7630, 9023, 9190, 9275, 9316, 9371, 9376, 9433, 9434, 9435, 9478, 9479, 9480, 9481, 9482, 9885, 8742, 9074, 9493, 9503, 7785, 8785, 8836, 9302, 9357, 9444, 9490, 9517, 9518, 9543, 12302, 9321, 9549, 9160, 9559, 9818, 8857, 9324, 9403, 9487, 9540, 9593, 9120, 9431, 9797, 9849, 9892, 9897, 10285, 8806, 9064, 9365, 9569, 9571, 9579, 9586, 9598, 9608, 9619, 9627, 9628, 9809, 8369, 9247, 9331, 9465, 9630, 9643, 9661, 8898, 9381, 9574, 9621, 9652, 9666, 9668, 9671, 9672, 9597, 9609, 9614, 9654, 9662, 9688, 9329, 9412, 9451, 9568, 9575, 9696, 9714, 9729, 9663, 9667, 9690, 9770, 9787, 8273, 9034, 9499, 9796, 9541, 9223, 9469, 9485, 9580, 9615, 9673, 9713, 9788, 9829, 9721, 9739, 9838, 9845, 9183, 9664, 9706, 9836, 9851, 9870, 9877, 14847, 8886, 9884, 9647, 9709, 9875, 9904, 9911, 9917, 9918, 9920, 9925, 9927, 9928, 9678, 10823, 14776, 8698, 10491, 15408, 12443, 16209, 15529, 17875, 18666, 19279, 19280, 19281, 19282, 19283, 19284, 19285, 19286, 19287, 19288, 10541, 18840, 19903, 25373, 27392, 27461, 27705, 19875, 26888, 27244, 30094, 30568, 29424, 30718, 29459, 30850, 30973, 31231, 31550, 29944]

    # 20210421
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('14-02-bible-si.csv', 'seed_files')
    skips = [11563] # company_id -> xlktyVs
    service.loop(nil) do |x|
      i = i + 1
      # puts "<-------------#{i}----------->"
      next if !inquiry_numbers.include?(x.get_column('Inquiry Number').to_i)
      # next if i < 17653
      invoice_number = x.get_column('AR Invoice #')
      order_number = x.get_column('SO #')
      if x.get_column('AR Invoice Date') != nil
        # next if x.get_column('AR Invoice Date').to_date > Date.new(2018, 04, 01)
        puts "#{x.get_column('AR Invoice Date').to_date}"
      end

      if invoice_number.include?('.') || invoice_number.include?('/') || invoice_number.include?('-') || invoice_number.match?(/[a-zA-Z]/)
        odd_invoice_names.push(invoice_number)
      end
      puts "<-------------------#{invoice_number}"
      next if odd_invoice_names.include?(invoice_number)

      sales_order = SalesOrder.find_by_order_number(order_number)
      puts "<-------------------SALES ORDER #{sales_order.order_number if sales_order.present?}"
      next if invoice_number.to_i.in?([20200086, 3000875, 20200130, 20200209, 20200207, 20200206, 20200052, 20300132, 20710032, 20210047, 20212052, 20212053, 20610819, 20610946, 20610941, 20610900])
      if sales_order.present?
        puts '********************** Row *****************************', invoice_number
        inquiry = sales_order.inquiry
        unit_price = x.get_column('Unit Price').to_f
        sku = x.get_column('BM #')
        product = Product.find_by_sku(sku)

        if product.blank?
          missing_product.push(sku)
        end
        if product.present? && product.is_kit
          kit_products.push(invoice_number)
        end
        next if product.present? && product.is_kit

        if !inquiry.billing_address.present?
          inquiry.update_attributes(billing_address: inquiry.company.default_billing_address)
        end

        if !inquiry.shipping_address.present?
          inquiry.update(shipping_address: inquiry.company.default_shipping_address)
        end

        if !inquiry.shipping_contact.present?
          inquiry.update(shipping_contact: inquiry.billing_contact)
        end

        invoice = sales_order.invoices.where(invoice_number: invoice_number.to_i).first_or_create!
        quantity = x.get_column('Qty').to_f
        tax_amount = x.get_column('Tax Amount').to_f
        invoice_row_obj = {
            qty: quantity,
            sku: sku,
            name: (product.present? ? product.name.to_s : ''),
            price: unit_price,
            base_cost: nil,
            row_total: unit_price * quantity,
            base_price: unit_price,
            product_id: (product.present? ? product.id.to_param : nil),
            tax_amount: tax_amount,
            description: (product.present? ? product.description.to_s : ''),
            order_item_id: nil,
            base_row_total: unit_price * quantity,
            price_incl_tax: nil,
            additional_data: nil,
            base_tax_amount: tax_amount,
            discount_amount: nil,
            weee_tax_applied: nil,
            hidden_tax_amount: nil,
            row_total_incl_tax: (unit_price * quantity) + (tax_amount),
            base_price_incl_tax: (unit_price + (tax_amount / quantity)),
            base_discount_amount: nil,
            weee_tax_disposition: nil,
            base_hidden_tax_amount: nil,
            base_row_total_incl_tax: (unit_price * quantity) + (tax_amount),
            weee_tax_applied_amount: nil,
            weee_tax_row_disposition: nil,
            base_weee_tax_disposition: nil,
            weee_tax_applied_row_amount: nil,
            base_weee_tax_applied_amount: nil,
            base_weee_tax_row_disposition: nil,
            base_weee_tax_applied_row_amnt: nil
        }

        row = invoice.rows.where('metadata @> ?', {sku: sku}.to_json)
        if row.present?
          row.first.update_attributes(sku: sku, quantity: quantity, sales_invoice_id: invoice.id, metadata: invoice_row_obj)
        else
          SalesInvoiceRow.create!(sku: sku, quantity: quantity, sales_invoice_id: invoice.id, metadata: invoice_row_obj)
        end

        item_lines = invoice.rows.pluck(:metadata)
        metadata = {
            'state' => 1,
            'is_kit' => '',
            'qty_kit' => 0, # check
            'ItemLine' => item_lines,
            'desc_kit' => '', # check
            'order_id' => order_number,
            'store_id' => nil,
            'doc_entry' => invoice_number.to_i,
            'price_kit' => 0,
            'controller' => 'callbacks/sales_invoices',
            'created_at' => x.get_column('AR Invoice Date'),
            'grand_total' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'increment_id' => invoice_number,
            'sales_invoice' => {
                'created_at' => x.get_column('AR Invoice Date'),
                'updated_at' => nil
            },
            'unitprice_kit' => 0,
            'base_tax_amount' => item_lines.pluck('tax_amount').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'discount_amount' => '',
            'shipping_amount' => nil,
            'base_grand_total' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'customer_company' => nil,
            'hidden_tax_amount' => nil,
            'shipping_incl_tax' => nil,
            'base_subtotal' => item_lines.pluck('row_total').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'base_currency_code' => sales_order.inquiry.currency.try(:name),
            'base_to_order_rate' => sales_order.inquiry.currency.conversion_rate.to_f,
            'billing_address_id' => sales_order.inquiry.billing_address.present? ? sales_order.inquiry.billing_address.id : nil,
            'order_currency_code' => sales_order.inquiry.currency.try(:name),
            'shipping_address_id' => sales_order.inquiry.shipping_address.present? ? sales_order.inquiry.shipping_address.id : nil,
            'shipping_tax_amount' => nil,
            'store_currency_code' => '',
            'store_to_order_rate' => '',
            'base_discount_amount' => nil,
            'base_shipping_amount' => nil,
            'discount_description' => nil,
            'base_hidden_tax_amount' => nil,
            'base_shipping_incl_tax' => nil,
            'base_subtotal_incl_tax' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'base_shipping_tax_amount' => nil,
            'shipping_hidden_tax_amount' => nil,
            'base_shipping_hidden_tax_amnt' => nil
        }
        invoice.assign_attributes(status: 1, metadata: metadata, mis_date: x.get_column('AR Invoice Date'))
        invoice.save!
        created_or_updated_invoices.push(invoice.invoice_number)
        puts '********************** Saving Invoice *****************************', invoice_number
      else
        missing_bible_orders.push(order_number)
        missing_bible_invoices.push(invoice_number)
      end
    end
    puts 'M SKus', missing_product.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'kit products', kit_products.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'odd SI names', odd_invoice_names.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'Missing bible orders', missing_bible_orders.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'Created Or Updated Invoices', created_or_updated_invoices.join(',')
  end

  def missing_payment_options
    PaymentOption.where(is_active: nil).update_all(is_active: true)
    service = Services::Shared::Spreadsheets::CsvImporter.new('missing_payment_options.csv', 'seed_files')
    service.loop(limit = nil) do |x|
      payment_option = PaymentOption.where(remote_uid: x.get_column('group_code')).first_or_initialize
      if payment_option.new_record?
        payment_option_name = PaymentOption.find_by_name(x.get_column('value'))
        unless payment_option_name.present?
          payment_option.name = x.get_column('value')
          payment_option.remote_uid = x.get_column('group_code', nil_if_zero: true)
          payment_option.credit_limit = x.get_column('credit_limit').to_f
          payment_option.general_discount = x.get_column('general_discount').to_f
          payment_option.load_limit = x.get_column('load_limit').to_f
          payment_option.legacy_metadata = x.get_row
          payment_option.is_active = false
          payment_option.save!
        end
      else
        payment_option.update_attributes(name: x.get_column('value'))
      end
    end
  end


  def missing_sales_order_products
    skus = []
    service = Services::Shared::Spreadsheets::CsvImporter.new('Missing_Products.csv', 'seed_files')
    service.loop(nil) do |x|
      product = Product.find_by_sku(x.get_column('SKU'))
      if !product.present?
        brand = Brand.find_by_name(x.get_column('Brand')) || Brand.default
        category = Category.find_by_name(x.get_column('Category')) || Category.default
        measurement_unit = MeasurementUnit.find_by_name(x.get_column('UOM')) || MeasurementUnit.default
        name = x.get_column('BULK MRO Description')
        sku = x.get_column('SKU')
        tax_code = TaxCode.find_by_chapter(x.get_column('HSN'))
        tax_rate = TaxRate.first_or_create(tax_percentage: x.get_column('Tax Percentage'))

        next if Product.where(sku: sku).exists?

        product = Product.new
        product.brand = brand
        product.category = category
        product.sku = sku || product.generate_sku
        product.tax_code = tax_code || TaxCode.default
        product.mpn = x.get_column('MPN')
        product.description = x.get_column('BULK MRO Description')
        product.name = name
        product.is_service = false
        product.is_active = true
        product.measurement_unit = measurement_unit
        product.legacy_metadata = x.get_row
        product.save_and_sync

        product.create_approval(comment: product.comments.create!(overseer: Overseer.default, message: 'Product, being preapproved'), overseer: Overseer.default) if product.approval.blank?
      end


      skus.push product.sku
    end

    puts skus
  end

  def margin_miscalculation_sales_order_rows
    service = Services::Shared::Spreadsheets::CsvImporter.new('margin_miscalculation_sales_order_rows.csv', 'seed_files')
    service.loop(nil) do |x|
      SalesOrderRow.find(x.get_column('Sales Order Row ID')).sales_quote_row.update_attribute(:margin_percentage, x.get_column('Old Margin').to_f)
    end
  end


  def resync_missing_supplier_details
    service = Services::Shared::Spreadsheets::CsvImporter.new('missing_supplier_details.csv', 'seed_files')
    service.loop(nil) do |x|
      supplier = Company.find(x.get_column('Supplier id'))
      if supplier.present?
        if supplier.pan.blank?
          pan = x.get_column('Supplier id')
          if pan.match?(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
            supplier.update_attribute(:pan, pan)
          else
            supplier.update_attribute(:pan, 'PANNO1234O')
          end
        else
          pan = supplier.pan
          if pan.match?(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
            supplier.update_attribute(:pan, pan)
          else
            supplier.update_attribute(:pan, 'PANNO1234O')
          end
        end
        supplier.save!
      end
    end
  end

  def fix_missing_supplier_contacts
    service = Services::Shared::Spreadsheets::CsvImporter.new('missing_supplier_details.csv', 'seed_files')
    service.loop(nil) do |x|
      supplier = Company.find(x.get_column('Supplier id'))
      if supplier.present?
        if supplier.pan.blank?
          pan = x.get_column('Supplier id')
          if pan.match?(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
            supplier.update_attribute(:pan, pan)
          else
            supplier.update_attribute(:pan, 'PANNO1234O')
          end
        else
          pan = supplier.pan
          if pan.match?(/^[A-Z]{5}\d{4}[A-Z]{1}$/)
            supplier.update_attribute(:pan, pan)
          else
            supplier.update_attribute(:pan, 'PANNO1234O')
          end
        end
        supplier.save!
      end
    end
  end


  def migrate_orders_missing_addresses
    service = Services::Shared::Spreadsheets::CsvImporter.new('orders_billing_address.csv', 'seed_files')
    counter = 0
    rows = 0
    inquiry_missing = []
    company_not_found = []
    invalid = 0
    service.loop(nil) do |x|
      rows += 1
      if x.get_column('company').blank?
        company = Company.find_by_name('Legacy Company')
      else
        company = Company.find_by_name(x.get_column('company'))
      end

      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry_number'))
      if company.present?
        country_code = x.get_column('country_id')
        address = Address.new
        address.company = company
        address.name = company.name
        if x.get_column('gst').blank? || (x.get_column('gst').present? && x.get_column('gst').chars.length < 15)
          address.gst = 'No GST Number'
        else
          address.gst = x.get_column('gst')[0..14]
        end

        address.country_code = country_code
        address.state = AddressState.find_by_legacy_id(x.get_column('region_id'))
        if !address.state.present?
          address.state = AddressState.find_by_name('Maharashtra')
        end
        address.state_name = country_code == 'IN' ? nil : x.get_column('region')
        address.city_name = x.get_column('city')
        address.pincode = x.get_column('postcode')
        address.street1 = x.get_column('street')
        is_tel_valid = true if Float(x.get_column('telephone')) rescue false
        address.telephone = x.get_column('telephone').to_i if is_tel_valid
        address.legacy_metadata = x.get_row

        if !address.valid?
          invalid += 1
        end
        address.save!

        if inquiry.present?
          inquiry.update_attributes(billing_address: address)
          inquiry.update_attributes(shipping_address: address)
        else
          inquiry_missing << x.get_column('inquiry_number')
        end
        counter += 1
      else
        company_not_found << x.get_column('company')
      end
    end
    counter
  end

  def create_missing_orders_and_inquiries_with_string_literals
    service = Services::Shared::Spreadsheets::CsvImporter.new('Sales Order - Bible - Missing inquiries.csv', 'seed_files')
    i = 0
    # inquiry_numbers = [2239,1742,1487,1463,1451,1431,919,11,2998,918,1021,203,1011,1273,2216,1443,3526,288,129,2776,4478,4380,4351,4342,4234,4233,4232,4231,4003,3625,3496,3248,3244,3088,3086,3053,2967,2958,2950,2903,2645,2644,2643,1342,1323,1293,542,4589,4693,4757,4799,4800,4801,4803,4804,4805,4806,4807,4808,4813,4815,4851,4875,4876,4877,4881,4888,4920,4924,4925,4926,4927,4928,4929,4930,4931,4932,4939,4940,4948,4964,4990,4994,4996,5017,5019,5020,5033,5035,5055,5056,5057,5058,5059,5060,5061,5067,5118,5120,5121,5124,5127,5128,5129,5130,5131,5132,5133,5172,5174,5175,5178,5186,5187,5265,5266,5290,5296,5297,5330,5353,5406,5407,5408,5709,5710,5768,5796,5810,5863,3307,6342,6663,8618,8790,10282,10317,10318,10330,10332,10333,10334,10336,10337,10338,10339,10340,10341,10342,10345,10347,10353,10355,10357,10358,10359,10360,10361,10366,10368,10370,10372,10373,10377,10378,10380,10381,10384,10387,10389,10397,10404,10411,10412,10414,10415,10416,10417,10524,10527,10579,10607,10609,10625,10634,10638,10639,10658,10661,10665,10668,10669,10670,10672,10673,10742,10744,10745,10777,10784,10804,10805,10807,10810,10811,10813,10815,10828,10830,10837,10861,10862,10902,10903,10905,10906,10911,10912,10913,10914,10915,11005,11007,11012,11013,11014,11022,11023,11029,11041,11043,11073,11080,11081,11082,11142,11164,11184,11207,11231,11233,11237,11239,11240,11254,11266,11275,11276,11297,11307,11312,11313,11314,11318,11360,11365,11371,11376,11431,11432,11440,11517,11547,11548,11554,11555,11556,11557,11558,11560,11561,11562,11570,11572,11574,11575,11578,11581,11584,11611,11613,11614,11615,11617,11618,11620,11622,11623,11629,11631,11634,11635,11636,11638,11639,11641,11644,11645,11674,11675,11677,11680,11681,11682,11683,11685,11686,11689,11690,11717,11718,11719,11733,11734,11741,11821,11826,11828,11832,11833,11834,11835,11836,11837,11838,11839,11843,11846,11847,11848,11850,11852,11853,11854,11855,11857,11858,11860,11861,11862,11864,11867,11869,11870,11873,11894,11898,11899,11901,11909,11910,11912,11914,11915,11917,11920,11928,11972,11973,11974,11975,11976,11978,11979,11980,11981,11982,11983,11985,11987,11988,11989,11990,11991,11993,11996,11998,12001,12002,12004,12007,12008,12010,12011,12013,12014,12016,12021,12041,12042,12043,12044,12046,12047,12048,12050,12052,12053,12054,12056,12057,12058,12060,12065,12070,12071,12072,12073,12074,12075,12076,12077,12080,12088,12089,12090,12091,12092,12093,12095,12096,12097,12123,12125,12126,12127,12129,12130,12131,12132,12133,12135,12141,12144,12146,12149,12156,12158,12159,12164,12235,12236,12274,12275,12372,12373,12378,12380,12381,12382,12383,12386,12387,12388,12389,12394,12395,12396,12397,12399,12400,12401,12402,12403,12404,12405,12406,12407,12408,12409,12410,12411,12414,12417,12418,12421,12424,12426,12427,12428,12430,12431,12433,12434,12436,12458,12459,12461,12462,12463,12465,12466,12467,12468,12470,12471,12473,12475,12477,12478,12480,12481,12482,12484,12485,12487,12489,12490,12491,12493,12494,12495,12496,12497,12499,12500,12501,12503,12504,12506,12507,12508,12509,12510,12511,12512,12513,12514,12515,12517,12519,12520,12521,12524,12526,12527,12528,12529,12530,12531,12532,12533,12535,12536,12537,12539,12545,12546,12547,12548,12549,12550,12552,12553,12565,12566,12568,12569,12571,12572,12574,12575,12577,12581,12583,12584,12585,12586,12588,12589,12590,12591,12592,12594,12596,12599,12601,12602,12605,12616,12617,12618,12619,12621,12622,12626,12627,12628,12629,12641,12642,12645,12646,12647,12648,12649,12650,12651,12652,12665,12667,12668,12669,12696,12698,12700,12701,12702,12703,12704,12714,12715,12716,12718,12719,12720,12721,12722,12723,12724,12725,12726,12727,12728,12730,12732,12733,12734,12735,12761,12762,12763,12764,12765,12767,12768,12769,12770,12829,12835,12836,12840,12852,12853,12855,12857,12894,12898,12919,12920,12924,12926,12927,12928,12954,12955,12957,12958,12960,12964,13063,13064,13065,13066,13067,13068,13069,13070,13071,13072,13073,13074,13075,13076,13077,13078,13079,13080,13081,13082,13083,13084,13085,13086,13087,13088,13089,13090,13091,13092,13093,13094,13095,13096,13097,13098,13099,13100,13101,13102,13103,13104,13105,13106,13107,13108,13109,13110,13111,13112,13113,13114,13115,13116,13117,13118,13119,13120,13121,13122,13123,13124,13125,13126,13127,13128,13129,13130,13131,13132,13133,13134,13135,13136,13137,13138,13139,13140,13141,13142,13143,13144,13145,13146,13147,13148,13149,13150,13151,13152,13153,13154,13155,13156,13157,13158,13159,13160,13161,13162,13163,13164,13165,13166,13167,13168,13169,13170,13171,13172,13173,13174,13175,13176,13177,13178,13179,13180,13181,13182,13183,13184,13185,13186,13187,13188,13189,13190,13191,13192,13193,13194,13195,13196,13197,13198,13199,13200,13201,13202,13203,13204,13205,13206,13207,13208,13209,13210,13211,13212,13213,13214,13215,13216,13217,13218,13219,13220,13221,13222,13223,13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13239,13240,13241,13242,13243,13244,13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,13257,13258,13259,13260,13261,13262,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,13274,13275,13276,13277,13278,13282,13283,13284,13285,13286,13287,13288,13289,13290,13291,13292,13293,13294,13295,13296,13297,13298,13299,13300,13301,13302,13303,13304,13305,13306,13307,13308,13309,13310,13311,13312,13313,13314,13315,13316,13317,13318,13319,13320,13321,13356,13357,13358,13359,13360,13361,13362,13363,13364,13365,13366,13428,13429,13430,13431,13432,13433,13434,13435,13448,13449,13450,13451,13486,13487,13488,13489,13537,13538,13539,13540,13613,13614,13635,13636,13637,13638,13639,13640,13641,13642,13643,13644,13645,13646,13647,13662,13663,13694,13704,13731,13732,13737,13764,13765,13767,13819,13820,13824,13825,13836,13837,13838,13839,13840,13869,13877,13878,13879,13910,13912,13913,13959,13960,13961,13978,13979,13980,13981,13982,13986,13987,13988,13989,13990,13991,13992,13993,13994,13995,13996,13997,14028,14029,14030,14031,14059,14086,14087,14088,14139,14168,14169,14173,14205,14206,14207,14208,14209,14210,14228,14229,14230,14268,14270,14271,14272,14273,14274,14296,14297,14300,14301,14302,14308,14309,14310,14311,14312,14314,14315,14316,14317,14318,14319,14324,14356,14357,14358,14361,14362,14363,14382,14384,14385,14386,14412,14413,14414,14417,14418,14419,14420,14431,14462,14463,14464,14467,14468,14469,14472,14512,14518,14519,14520,14544,14547,14548,14549,14550,14551,14585,14586,14587,14588,14594,14595,14596,14597,14613,14614,14645,14646,14650,14651,14652,14667,14668,14669,14686,14689,14690,14713,14714,14715,14716,14741,14742,14743,14744,14745,14750,14751,14752,14754,14769,14770,14796,14797,14798,14817,14819,14820,14826,14827,14828,14829,14832,14850,14852,14853,14854,14855,14877,14878,14879,14880,14881,14882,14902,14903,14927,14928,14929,14931,14936,14937,14938,14941,14942,14943,14984,14985,14986,14987,14988,15007,15008,15009,15010,15011,15012,15013,15014,15015,15016,15017,15018,15019,15020,15041,15042,15043,15044,15045,15068,15092,15093,15094,15096,15097,15098,15099,15100,15115,15116,15117,15118,15119,15136,15137,15138,15140,15157,15158,15166,15167,15168,15174,15218,15219,15220,15221,15222,15223,15224,15227,15228,15250,15251,15252,15256,15257,15258,15259,15260,15261,15262,15263,15264,15265,15266,15267,15268,15269,15270,15271,15272,15273,15274,15275,15276,15277,15278,15279,15280,15281,15282,15283,15284,15285,15286,15287,15288,15289,15290,15291,15292,15293,15294,15295,15296,15297,15298,15299,15300,15301,15302,15303,15304,15305,15306,15307,15308,15311,15312,15313,15314,15315,15316,15317,15318,15319,15320,15321,15322,15323,15324,15325,15326,15327,15328,15329,15330,15331,15332,15333,15334,15335,15336,15337,15338,15339,15340,15341,15342,15343,15344,15345,15346,15347,15348,15349,15350,15351,15352,15353,15354,15355,15356,15357,15358,15359,15360,15361,15362,15363,15364,15365,15367,15368,15369,15370,15371,15372,15373,15374,15375,15376,15377,15378,15379,15380,15381,15382,15383,15384,15386,15387,15388,15392,15398,15399,15400,15401,15403,15404,15428,15429,15430,15431,15432,15433,15434,15435,15436,15437,15438,15439,15440,15441,15442,15443,15444,15518,15519,15520,15521,15522,15523,15525,15526,15545,15547,15568,15569,15570,15571,15573,15596,15603,15609,15610,15611,15612,15613,15614,15615,15616,15617,15618,15619,15620,15621,15622,15623,15624,15625,15626,15627,15628,15638,15639,15640,15641,15642,15643,15644,15684,15685,15686,15687,15689,15690,15691,15708,15709,15710,15711,15712,15713,15714,15715,15716,15719,15720,15726,15727,15728,15729,15730,15731,15732,15733,15734,15757,15758,15759,15760,15761,15762,15765,15766,15792,15793,15795,15796,15797,15816,15817,15818,15841,15861,15862,15863,15865,15866,15893,15912,15913,15914,15915,15916,15917,15954,15956,15957,15981,15982,15986,15987,15988,16010,16011,16021,16029,16054,16055,16056,16057,16058,16059,16060,16077,16081,16100,16102,16103,16104,16116,16117,16133,16148,16169,16170,16171,16172,16173,16174,16175,16176,16177,16178,16179,16180,16195,16196,16217,16218,16219,16226,16237,16241,16242,16252,16253,16254,16255,16256,16257,16258,16259,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,16301,16302,16303,16304,16305,16306,16317,16337,16338,16339,16340,16355,16356,16379,16380,16381,16395,16396,16399,16413,16423,16424,16425,16429,16430,16431,16432,16434,16436,16443,16468,16469,16470,16471,16472,16473,16474,16475,16476,16477,16478,16479,16480,16481,16482,16483,16484,16485,16486,16487,16488,16489,16490,16492,16493,16494,16495,16496,16497,16498,16499,16500,16501,16502,16503,16504,16505,16506,16507,16508,16509,16510,16511,16512,16513,16514,16515,16516,16517,16518,16519,16520,16521,16522,16523,16524,16525,16526,16527,16528,16539,16590,16607,16633,16634,16635,16636,16637,16638,16640,16663,16677,16680,16681,16682,16701,16702,16703,16708,16709,16710,16711,16712,16713,16717,16718,16719,16720,16721,16801,16722,16723,16724,16725,16726,16727,16728,16729,16730,16731,16732,16733,16734,16735,16736,16737,16738,16739,16740,16741,16742,16743,16759,16777,16778,16779,16780,16781,16782,16783,16787,16788,16831,16832,16833,16834,16835,16836,16848,16867,16869,16873,16915,16937,16960,16961,16962,16963,16964,16965,16983,16984,16985,16987,16988,16989,16990,16991,17019,17020,17025,17026,17042,17043,17044,17045,17051,17052,17053,17054,17061,17062,17081,17082,17083,17084,17085,17139,17140,17141,17142,17143,17160,17164,17185,17186,17187,17188,17189,17190,17191,17192,17202,17203,17204,17220,17221,17222,17227,17228,17230,17231,17234,17251,17252,17253,17254,17255,17256,17257,17258,17259,17260,17261,17269,17294,17295,17296,17298,17299,17319,17346,17347,17348,17349,17350,17373,17382,17383,17395,17396,17398,17399,17400,17401,17403,17444,17446,17447,17448,17450,17451,17453,17469,17470,17471,17502,17521,17522,17524,17549,17550,17551,17552,17553,17599,17600,17601,17602,17603,17605,17635,17636,17637,17638,17639,17652,17661,17662,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,17677,17678,17679,17680,17681,17682,17683,17684,17685,17686,17687,17688,17689,17690,17691,17692,17693,17694,17695,17696,17697,17698,17699,17700,17701,17702,17703,17704,17705,17706,17707,17711,17712,17713,17731,17732,17763,17764,17765,17766,17767,17783,17805,17806,17807,17810,17811,17823,17824,17825,17826,17848,17849,17850,17851,17852,17853,17854,17855,17856,17857,17870,17871,17872,17873,17902,17903,17904,17907,17908,17909,17910,17911,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17922,17923,17924,17925,17926,17927,17928,18604,18610,18611,18612,18613,18614,18615,18618,18621,18666,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18942,18943,18944,18945,18946,18947,18948,18949,18950,18951,18952,18953,18954,18955,18956,18957,18958,18959,18960,18961,18962,18963,18964,18965,18966,18967,18968,18969,18970,18971,18972,18973,18974,18975,18976,18977,18978,18979,18980,18981,18982,18983,18984,18985,18986,18987,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19002,19003,19004,19005,19006,19007,19008,19009,19010,19011,19012,19013,19014,19015,19016,19017,19018,19019,19020,19021,19022,19023,19024,19025,19026,19027,19028,19029,19030,19031,19032,19033,19034,19035,19036,19037,19038,19039,19040,19041,19042,19043,19044,19045,19046,19047,19048,19049,19050,19051,19052,19053,19054,19055,19056,19057,19058,19059,19060,19061,19062,19063,19064,19065,19066,19067,19068,19069,19070,19071,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19082,19083,19084,19085,19086,19087,19088,19089,19090,19091,19092,19093,19094,19095,19096,19097,19098,19099,19100,19101,19102,19103,19104,19105,19106,19107,19108,19109,19110,19111,19112,19113,19114,19115,19116,19117,19118,19119,19120,19121,19122,19123,19124,19125,19126,19127,19128,19129,19130,19131,19132,19133,19134,19135,19136,19137,19138,19139,19140,19141,19142,19143,19144,19145,19146,19147,19148,19149,19150,19151,19152,19153,19154,19155,19156,19157,19158,19159,19160,19161,19162,19163,19164,19165,19166,19167,19168,19169,19170,19279,19280,19281,19282,19283,19284,19285,19286,19287,19288,20172,20173,20174,20175,20176,20177,20178,20179,20180,20181,20182,20183,20184,20185,20186,20187,20188,20189,20190,20191,20192,20193,20194,20195,20196,20198,20199,20200,20201,20202,20203,20204,20205,20206,20207,20208,20209,20210,20211,20212,20213,20214,20215,20216,20217,20218,20219,20220,20221,20222,20223,20224,20225,20226,20227,20228,20229,20230,20231,20232,20233,20234,20235,20236,20237,20238,20239,20240,20241,20242,20243,20244,20245,20247,20248,20249,20251,20252,20253,20254,20255,20256,20257,20258,20259,20260,20261,20262,20263,20264,20265,20266,20267,20268,20269,20270,20808,20272,20273,20274,20275,20276,20277,20278,20279,20280,20281,20282,20283,20284,20285,20286,20287,20288,20289,20290,20291,20292,20293,20294,20295,20296,20297,20298,20299,20300,20301,20302,20303,20304,20305,20306,20307,20308,20309,20310,20311,20312,20313,20314,20315,20316,20317,20318,20319,20320,20321,20323,20324,20325,20326,20327,20328,20329,20330,20331,20332,20333,20334,20335,20336,20337,20338,20339,20340,20341,20342,20343,20344,20345,20346,20347,20348,20349,20350,20351,20352,20353,20354,20355,20356,20357,20358,20360,20361,20362,20363,20364,20365,20366,20367,20368,20369,20370,20371,20372,20373,20374,20375,20376,20377,20378,20379,20380,20381,20382,20383,20384,20385,20386,20387,20388,20389,20390,20391,20392,20393,20394,20395,20396,20397,20398,20399,20400,20401,20402,20403,20404,20405,20406,20407,20408,20409,20410,20411,20446,20519,20524,20525,20526,20527,20528,20529,20530,20531,20532,20533,20534,20535,20536,20537,20538,20539,20540,20541,20542,20543,20544,20545,20546,20547,20548,20549,20550,20551,20552,20553,20554,20555,20556,20557,20558,20559,20560,20561,20562,20563,20564,20565,20566,20567,20569,20570,20571,20572,20573,20574,20575,20576,20590,20591,20592,20593,20594,20595]
    # skips = [10709, 17619, 10541, 19229, 20001, 20037, 19232, 20029, 21413, 19412, 25097, 25239, 30037, 30040, 30041, 30042, 30034, 30035, 30045, 30083, 30098, 25003, 25361, 19523, 19636, 19717, 20004, 20583, 20612, 20916, 20973, 20975, 21455, 21473, 25329, 25373, 26285, 20627, 25698, 26430, 26901, 10491, 21447, 27044, 27013, 25042, 26062, 19875, 18840, 20132, 28767, 27782, 21030, 26771]

    # inquiry_numbers = [26289, 29944]
    totals = {}
    inquiry_not_found = []
    odd_order_names = []
    odd_inquiry_numbers = []
    last_generated_order_number = SalesOrder.where.not(old_order_number: nil).order(order_number: :asc).last.order_number
    last_generated_inquiry_number = 10000001
    sales_order_exists = []
    service.loop(nil) do |x|
      i = i + 1
      # next if i < 11729
      # next if !x.get_column('product sku').upcase.in?(['BM1A9O9','BM1Z9F4','BM1Z8Z7','BM0Z1F1','BM0P0K2','BM0Z0I8','BM0P0J9','BM0Z0I9','BM9C4D9','BM9B7R8','BM0L0D8','BM9B7M5','BM9C9L6','BM0C718','BM0Q7E2','BM9C4F8','BM00038','BM00039','BM00034','BM00035','BM00036','BM00037','BM9Y7F5','BM9U9M5','BM9Y6Q3','BM9P8F4','BM9P8G5','CUM01','BM5P9Y7'])
      # next if !inquiry_numbers.include?(x.get_column('inquiry number').to_i)
      # next if Product.where(sku: x.get_column('product sku')).present? == false
      puts '*********************** INQUIRY ', x.get_column('inquiry number')
      o_number = x.get_column('SO #')
      if o_number.include?('.') || o_number.include?('/') || o_number.include?('-') || o_number.match?(/[a-zA-Z]/)
        odd_order_names.push(o_number)
      end
      puts "<-------------------#{o_number}"

      if odd_order_names.include?(o_number)
        old_order_number = o_number
      end

      inquiry_number = x.get_column('Inquiry Number')

      if inquiry_number.include?('.') || inquiry_number.include?('/') || inquiry_number.include?('-') || inquiry_number.match?(/[a-zA-Z]/)
        odd_inquiry_numbers.push(inquiry_number)
      end
      if odd_inquiry_numbers.include?(inquiry_number)
        old_inquiry_number = inquiry_number
      end

      if old_inquiry_number.present?
        inquiry = Inquiry.find_by_old_inquiry_number(old_inquiry_number)
      else
        inquiry = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number'))
      end

      if !inquiry.present?
        legacy_company = Company.legacy
        opportunity_type = {'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80}
        quote_category = {'bmro' => 10, 'ong' => 20}
        opportunity_source = {1 => 10, 2 => 20, 3 => 30, 4 => 40}
        company = Company.find_by_name(x.get_column('Magento Company Name')) || legacy_company

        contact = company.contacts.first

        shipping_address = company.account.addresses.first
        billing_address = company.account.addresses.first

        if old_inquiry_number.present?
          if Inquiry.where(old_inquiry_number: old_inquiry_number).present?
            inquiry = Inquiry.where(inquiry_number: inquiry_number).first
          else
            new_inquiry_number = last_generated_inquiry_number + 1
            inquiry = Inquiry.where(inquiry_number: new_inquiry_number, old_inquiry_number: old_inquiry_number).first_or_initialize
            last_generated_inquiry_number = new_inquiry_number
          end
        else
          inquiry = Inquiry.where(inquiry_number: inquiry_number).first_or_initialize
        end

        if inquiry.new_record? || update_if_exists
          inquiry.company = company
          inquiry.contact = contact
          inquiry.status = 18
          inquiry.potential_amount = 1.0
          inquiry.subject = company.name + inquiry_number.to_s
          inquiry.inside_sales_owner = Overseer.find_by_username('lavanya.jamma')
          inquiry.outside_sales_owner = Overseer.find_by_username('devang.shah')
          inquiry.sales_manager = Overseer.find_by_username('devang.shah')
          inquiry.billing_company = company
          inquiry.shipping_company = company
          inquiry.shipping_contact = contact
          inquiry.billing_address = billing_address
          inquiry.shipping_address = shipping_address
          inquiry.legacy_id = inquiry.inquiry_number
          inquiry.legacy_metadata = x.get_row
          inquiry.created_at = x.get_column('Order Date', to_datetime: true)
          inquiry.updated_at = x.get_column('Order Date', to_datetime: true)
          inquiry.save!
        end
      end


      if inquiry.present?
        if !inquiry.billing_address.present?
          inquiry.update(billing_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_address.present?
          inquiry.update(shipping_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_contact.present?
          inquiry.update(shipping_contact: inquiry.billing_contact)
        end

        sales_quote = inquiry.sales_quotes.last
        if sales_quote.blank?
          sales_quote = inquiry.sales_quotes.create!(overseer: inquiry.inside_sales_owner)
        end

        product_sku = x.get_column('BM #').upcase
        puts 'SKU', product_sku
        product = Product.find_by_sku(product_sku)

        inquiry_products = inquiry.inquiry_products.where(product_id: product.id)
        if inquiry_products.blank?
          similar_products = Product.where(name: product.name).where.not(sku: product.sku)
          if similar_products.present?
            similar_products.update_all(is_active: false)
          end
          sr_no = inquiry.inquiry_products.present? ? (inquiry.inquiry_products.last.sr_no + 1) : 1
          inquiry_product = inquiry.inquiry_products.where(product_id: product.id, sr_no: sr_no, quantity: x.get_column('Qty')).first_or_create!
        else
          inquiry_product = inquiry_products.first
          inquiry_product.update_attribute('quantity', inquiry_product.quantity + x.get_column('Qty').to_f)
        end

        supplier = Company.acts_as_supplier.find_by_name(x.get_column('Magento Supplier Name')) || Company.acts_as_supplier.find_by_name('Local')
        inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
        inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('Buying Rate').to_f)
        row = nil

        if x.get_column('SO #').include?('-')
          dump_order = x.get_column('SO #').split('-')[0]
          if inquiry.sales_orders.pluck(:order_number).include?(dump_order.to_i)
            new_order_number = last_generated_order_number + 1
            updated_order = inquiry.sales_orders.where(order_number: dump_order.to_i).first.update(order_number: new_order_number, old_order_number: x.get_column('SO #'))
            last_generated_order_number = new_order_number
          end
        end


        if inquiry.sales_orders.pluck(:old_order_number).include?(x.get_column('SO #'))
          so = SalesOrder.find_by_old_order_number(x.get_column('SO #'))
          if so.rows.map {|r| r.product.sku}.include?(x.get_column('BM #'))
            row = sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('BM #')).first
          end
        end
        if row.blank?
          row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
        end

        tax_rate = TaxRate.where(tax_percentage: x.get_column('Tax Rate').to_f).first_or_create!
        row.unit_selling_price = x.get_column('Unit Price').to_f
        row.quantity = x.get_column('Qty')
        row.margin_percentage = x.get_column('Margin (in % )')
        row.converted_unit_selling_price = x.get_column('Unit Price').to_f
        row.inquiry_product_supplier.unit_cost_price = x.get_column('Buying Rate').to_f
        row.measurement_unit = MeasurementUnit.default
        row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
        row.tax_rate = tax_rate || nil
        row.legacy_applicable_tax_percentage = x.get_column('Tax Rate').to_f || nil
        row.created_at = x.get_column('Order Date', to_datetime: true)

        row.save!

        puts '**************** QUOTE ROW SAVED ********************'

        if old_order_number.present?
          sales_order = sales_quote.sales_orders.where(old_order_number: x.get_column('SO #')).first
          if !sales_order.present?
            new_order_number = last_generated_order_number + 1
            sales_order = sales_quote.sales_orders.create(old_order_number: x.get_column('SO #'), order_number: new_order_number)
            last_generated_order_number = new_order_number
          end
        else
          sales_order = sales_quote.sales_orders.where(order_number: x.get_column('SO #').to_i).first_or_create!
        end

        sales_order.overseer = inquiry.inside_sales_owner
        sales_order.created_at = x.get_column('Order Date', to_datetime: true)
        sales_order.mis_date = x.get_column('Order Date', to_datetime: true)

        sales_order.status = x.get_column('status') || 'Approved'
        sales_order.remote_status = x.get_column('SAP status') || 'Processing'
        sales_order.sent_at = sales_quote.created_at
        sales_order.save!
        row_object = {sku: product_sku, supplier: x.get_column('Magento Supplier Name'), total_with_tax: row.total_selling_price_with_tax.to_f}
        totals[sales_order.order_number] ||= []
        totals[sales_order.order_number].push(row_object)
        puts '************************** ORDER SAVED *******************************'
        so_row = sales_order.rows.where(sales_quote_row: row).first_or_create!

        puts '****************** ORDER TOTAL ****************************', sales_order.order_number, sales_order.calculated_total_with_tax
      else
        if !inquiry.present?
          inquiry_not_found.push(x.get_column('Inquiry Number'))
        end
      end
      puts totals
      puts '<----------------------------------------INQUIRIES--------------------------------------------------->'
      puts inquiry_not_found.inspect
    end
  end

  def create_missing_orders_with_string_literals
    service = Services::Shared::Spreadsheets::CsvImporter.new('7. Sales Order Number is not a Number (B4 Amzn).csv', 'seed_files')
    i = 0
    # inquiry_numbers = [2239,1742,1487,1463,1451,1431,919,11,2998,918,1021,203,1011,1273,2216,1443,3526,288,129,2776,4478,4380,4351,4342,4234,4233,4232,4231,4003,3625,3496,3248,3244,3088,3086,3053,2967,2958,2950,2903,2645,2644,2643,1342,1323,1293,542,4589,4693,4757,4799,4800,4801,4803,4804,4805,4806,4807,4808,4813,4815,4851,4875,4876,4877,4881,4888,4920,4924,4925,4926,4927,4928,4929,4930,4931,4932,4939,4940,4948,4964,4990,4994,4996,5017,5019,5020,5033,5035,5055,5056,5057,5058,5059,5060,5061,5067,5118,5120,5121,5124,5127,5128,5129,5130,5131,5132,5133,5172,5174,5175,5178,5186,5187,5265,5266,5290,5296,5297,5330,5353,5406,5407,5408,5709,5710,5768,5796,5810,5863,3307,6342,6663,8618,8790,10282,10317,10318,10330,10332,10333,10334,10336,10337,10338,10339,10340,10341,10342,10345,10347,10353,10355,10357,10358,10359,10360,10361,10366,10368,10370,10372,10373,10377,10378,10380,10381,10384,10387,10389,10397,10404,10411,10412,10414,10415,10416,10417,10524,10527,10579,10607,10609,10625,10634,10638,10639,10658,10661,10665,10668,10669,10670,10672,10673,10742,10744,10745,10777,10784,10804,10805,10807,10810,10811,10813,10815,10828,10830,10837,10861,10862,10902,10903,10905,10906,10911,10912,10913,10914,10915,11005,11007,11012,11013,11014,11022,11023,11029,11041,11043,11073,11080,11081,11082,11142,11164,11184,11207,11231,11233,11237,11239,11240,11254,11266,11275,11276,11297,11307,11312,11313,11314,11318,11360,11365,11371,11376,11431,11432,11440,11517,11547,11548,11554,11555,11556,11557,11558,11560,11561,11562,11570,11572,11574,11575,11578,11581,11584,11611,11613,11614,11615,11617,11618,11620,11622,11623,11629,11631,11634,11635,11636,11638,11639,11641,11644,11645,11674,11675,11677,11680,11681,11682,11683,11685,11686,11689,11690,11717,11718,11719,11733,11734,11741,11821,11826,11828,11832,11833,11834,11835,11836,11837,11838,11839,11843,11846,11847,11848,11850,11852,11853,11854,11855,11857,11858,11860,11861,11862,11864,11867,11869,11870,11873,11894,11898,11899,11901,11909,11910,11912,11914,11915,11917,11920,11928,11972,11973,11974,11975,11976,11978,11979,11980,11981,11982,11983,11985,11987,11988,11989,11990,11991,11993,11996,11998,12001,12002,12004,12007,12008,12010,12011,12013,12014,12016,12021,12041,12042,12043,12044,12046,12047,12048,12050,12052,12053,12054,12056,12057,12058,12060,12065,12070,12071,12072,12073,12074,12075,12076,12077,12080,12088,12089,12090,12091,12092,12093,12095,12096,12097,12123,12125,12126,12127,12129,12130,12131,12132,12133,12135,12141,12144,12146,12149,12156,12158,12159,12164,12235,12236,12274,12275,12372,12373,12378,12380,12381,12382,12383,12386,12387,12388,12389,12394,12395,12396,12397,12399,12400,12401,12402,12403,12404,12405,12406,12407,12408,12409,12410,12411,12414,12417,12418,12421,12424,12426,12427,12428,12430,12431,12433,12434,12436,12458,12459,12461,12462,12463,12465,12466,12467,12468,12470,12471,12473,12475,12477,12478,12480,12481,12482,12484,12485,12487,12489,12490,12491,12493,12494,12495,12496,12497,12499,12500,12501,12503,12504,12506,12507,12508,12509,12510,12511,12512,12513,12514,12515,12517,12519,12520,12521,12524,12526,12527,12528,12529,12530,12531,12532,12533,12535,12536,12537,12539,12545,12546,12547,12548,12549,12550,12552,12553,12565,12566,12568,12569,12571,12572,12574,12575,12577,12581,12583,12584,12585,12586,12588,12589,12590,12591,12592,12594,12596,12599,12601,12602,12605,12616,12617,12618,12619,12621,12622,12626,12627,12628,12629,12641,12642,12645,12646,12647,12648,12649,12650,12651,12652,12665,12667,12668,12669,12696,12698,12700,12701,12702,12703,12704,12714,12715,12716,12718,12719,12720,12721,12722,12723,12724,12725,12726,12727,12728,12730,12732,12733,12734,12735,12761,12762,12763,12764,12765,12767,12768,12769,12770,12829,12835,12836,12840,12852,12853,12855,12857,12894,12898,12919,12920,12924,12926,12927,12928,12954,12955,12957,12958,12960,12964,13063,13064,13065,13066,13067,13068,13069,13070,13071,13072,13073,13074,13075,13076,13077,13078,13079,13080,13081,13082,13083,13084,13085,13086,13087,13088,13089,13090,13091,13092,13093,13094,13095,13096,13097,13098,13099,13100,13101,13102,13103,13104,13105,13106,13107,13108,13109,13110,13111,13112,13113,13114,13115,13116,13117,13118,13119,13120,13121,13122,13123,13124,13125,13126,13127,13128,13129,13130,13131,13132,13133,13134,13135,13136,13137,13138,13139,13140,13141,13142,13143,13144,13145,13146,13147,13148,13149,13150,13151,13152,13153,13154,13155,13156,13157,13158,13159,13160,13161,13162,13163,13164,13165,13166,13167,13168,13169,13170,13171,13172,13173,13174,13175,13176,13177,13178,13179,13180,13181,13182,13183,13184,13185,13186,13187,13188,13189,13190,13191,13192,13193,13194,13195,13196,13197,13198,13199,13200,13201,13202,13203,13204,13205,13206,13207,13208,13209,13210,13211,13212,13213,13214,13215,13216,13217,13218,13219,13220,13221,13222,13223,13224,13225,13226,13227,13228,13229,13230,13231,13232,13233,13234,13235,13236,13237,13239,13240,13241,13242,13243,13244,13245,13246,13247,13248,13249,13250,13251,13252,13253,13254,13255,13256,13257,13258,13259,13260,13261,13262,13263,13264,13265,13266,13267,13268,13269,13270,13271,13272,13273,13274,13275,13276,13277,13278,13282,13283,13284,13285,13286,13287,13288,13289,13290,13291,13292,13293,13294,13295,13296,13297,13298,13299,13300,13301,13302,13303,13304,13305,13306,13307,13308,13309,13310,13311,13312,13313,13314,13315,13316,13317,13318,13319,13320,13321,13356,13357,13358,13359,13360,13361,13362,13363,13364,13365,13366,13428,13429,13430,13431,13432,13433,13434,13435,13448,13449,13450,13451,13486,13487,13488,13489,13537,13538,13539,13540,13613,13614,13635,13636,13637,13638,13639,13640,13641,13642,13643,13644,13645,13646,13647,13662,13663,13694,13704,13731,13732,13737,13764,13765,13767,13819,13820,13824,13825,13836,13837,13838,13839,13840,13869,13877,13878,13879,13910,13912,13913,13959,13960,13961,13978,13979,13980,13981,13982,13986,13987,13988,13989,13990,13991,13992,13993,13994,13995,13996,13997,14028,14029,14030,14031,14059,14086,14087,14088,14139,14168,14169,14173,14205,14206,14207,14208,14209,14210,14228,14229,14230,14268,14270,14271,14272,14273,14274,14296,14297,14300,14301,14302,14308,14309,14310,14311,14312,14314,14315,14316,14317,14318,14319,14324,14356,14357,14358,14361,14362,14363,14382,14384,14385,14386,14412,14413,14414,14417,14418,14419,14420,14431,14462,14463,14464,14467,14468,14469,14472,14512,14518,14519,14520,14544,14547,14548,14549,14550,14551,14585,14586,14587,14588,14594,14595,14596,14597,14613,14614,14645,14646,14650,14651,14652,14667,14668,14669,14686,14689,14690,14713,14714,14715,14716,14741,14742,14743,14744,14745,14750,14751,14752,14754,14769,14770,14796,14797,14798,14817,14819,14820,14826,14827,14828,14829,14832,14850,14852,14853,14854,14855,14877,14878,14879,14880,14881,14882,14902,14903,14927,14928,14929,14931,14936,14937,14938,14941,14942,14943,14984,14985,14986,14987,14988,15007,15008,15009,15010,15011,15012,15013,15014,15015,15016,15017,15018,15019,15020,15041,15042,15043,15044,15045,15068,15092,15093,15094,15096,15097,15098,15099,15100,15115,15116,15117,15118,15119,15136,15137,15138,15140,15157,15158,15166,15167,15168,15174,15218,15219,15220,15221,15222,15223,15224,15227,15228,15250,15251,15252,15256,15257,15258,15259,15260,15261,15262,15263,15264,15265,15266,15267,15268,15269,15270,15271,15272,15273,15274,15275,15276,15277,15278,15279,15280,15281,15282,15283,15284,15285,15286,15287,15288,15289,15290,15291,15292,15293,15294,15295,15296,15297,15298,15299,15300,15301,15302,15303,15304,15305,15306,15307,15308,15311,15312,15313,15314,15315,15316,15317,15318,15319,15320,15321,15322,15323,15324,15325,15326,15327,15328,15329,15330,15331,15332,15333,15334,15335,15336,15337,15338,15339,15340,15341,15342,15343,15344,15345,15346,15347,15348,15349,15350,15351,15352,15353,15354,15355,15356,15357,15358,15359,15360,15361,15362,15363,15364,15365,15367,15368,15369,15370,15371,15372,15373,15374,15375,15376,15377,15378,15379,15380,15381,15382,15383,15384,15386,15387,15388,15392,15398,15399,15400,15401,15403,15404,15428,15429,15430,15431,15432,15433,15434,15435,15436,15437,15438,15439,15440,15441,15442,15443,15444,15518,15519,15520,15521,15522,15523,15525,15526,15545,15547,15568,15569,15570,15571,15573,15596,15603,15609,15610,15611,15612,15613,15614,15615,15616,15617,15618,15619,15620,15621,15622,15623,15624,15625,15626,15627,15628,15638,15639,15640,15641,15642,15643,15644,15684,15685,15686,15687,15689,15690,15691,15708,15709,15710,15711,15712,15713,15714,15715,15716,15719,15720,15726,15727,15728,15729,15730,15731,15732,15733,15734,15757,15758,15759,15760,15761,15762,15765,15766,15792,15793,15795,15796,15797,15816,15817,15818,15841,15861,15862,15863,15865,15866,15893,15912,15913,15914,15915,15916,15917,15954,15956,15957,15981,15982,15986,15987,15988,16010,16011,16021,16029,16054,16055,16056,16057,16058,16059,16060,16077,16081,16100,16102,16103,16104,16116,16117,16133,16148,16169,16170,16171,16172,16173,16174,16175,16176,16177,16178,16179,16180,16195,16196,16217,16218,16219,16226,16237,16241,16242,16252,16253,16254,16255,16256,16257,16258,16259,16291,16292,16293,16294,16295,16296,16297,16298,16299,16300,16301,16302,16303,16304,16305,16306,16317,16337,16338,16339,16340,16355,16356,16379,16380,16381,16395,16396,16399,16413,16423,16424,16425,16429,16430,16431,16432,16434,16436,16443,16468,16469,16470,16471,16472,16473,16474,16475,16476,16477,16478,16479,16480,16481,16482,16483,16484,16485,16486,16487,16488,16489,16490,16492,16493,16494,16495,16496,16497,16498,16499,16500,16501,16502,16503,16504,16505,16506,16507,16508,16509,16510,16511,16512,16513,16514,16515,16516,16517,16518,16519,16520,16521,16522,16523,16524,16525,16526,16527,16528,16539,16590,16607,16633,16634,16635,16636,16637,16638,16640,16663,16677,16680,16681,16682,16701,16702,16703,16708,16709,16710,16711,16712,16713,16717,16718,16719,16720,16721,16801,16722,16723,16724,16725,16726,16727,16728,16729,16730,16731,16732,16733,16734,16735,16736,16737,16738,16739,16740,16741,16742,16743,16759,16777,16778,16779,16780,16781,16782,16783,16787,16788,16831,16832,16833,16834,16835,16836,16848,16867,16869,16873,16915,16937,16960,16961,16962,16963,16964,16965,16983,16984,16985,16987,16988,16989,16990,16991,17019,17020,17025,17026,17042,17043,17044,17045,17051,17052,17053,17054,17061,17062,17081,17082,17083,17084,17085,17139,17140,17141,17142,17143,17160,17164,17185,17186,17187,17188,17189,17190,17191,17192,17202,17203,17204,17220,17221,17222,17227,17228,17230,17231,17234,17251,17252,17253,17254,17255,17256,17257,17258,17259,17260,17261,17269,17294,17295,17296,17298,17299,17319,17346,17347,17348,17349,17350,17373,17382,17383,17395,17396,17398,17399,17400,17401,17403,17444,17446,17447,17448,17450,17451,17453,17469,17470,17471,17502,17521,17522,17524,17549,17550,17551,17552,17553,17599,17600,17601,17602,17603,17605,17635,17636,17637,17638,17639,17652,17661,17662,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,17676,17677,17678,17679,17680,17681,17682,17683,17684,17685,17686,17687,17688,17689,17690,17691,17692,17693,17694,17695,17696,17697,17698,17699,17700,17701,17702,17703,17704,17705,17706,17707,17711,17712,17713,17731,17732,17763,17764,17765,17766,17767,17783,17805,17806,17807,17810,17811,17823,17824,17825,17826,17848,17849,17850,17851,17852,17853,17854,17855,17856,17857,17870,17871,17872,17873,17902,17903,17904,17907,17908,17909,17910,17911,17912,17913,17914,17915,17916,17917,17918,17919,17920,17921,17922,17923,17924,17925,17926,17927,17928,18604,18610,18611,18612,18613,18614,18615,18618,18621,18666,18928,18929,18930,18931,18932,18933,18934,18935,18936,18937,18938,18939,18940,18941,18942,18943,18944,18945,18946,18947,18948,18949,18950,18951,18952,18953,18954,18955,18956,18957,18958,18959,18960,18961,18962,18963,18964,18965,18966,18967,18968,18969,18970,18971,18972,18973,18974,18975,18976,18977,18978,18979,18980,18981,18982,18983,18984,18985,18986,18987,18988,18989,18990,18991,18992,18993,18994,18995,18996,18997,18998,18999,19000,19001,19002,19003,19004,19005,19006,19007,19008,19009,19010,19011,19012,19013,19014,19015,19016,19017,19018,19019,19020,19021,19022,19023,19024,19025,19026,19027,19028,19029,19030,19031,19032,19033,19034,19035,19036,19037,19038,19039,19040,19041,19042,19043,19044,19045,19046,19047,19048,19049,19050,19051,19052,19053,19054,19055,19056,19057,19058,19059,19060,19061,19062,19063,19064,19065,19066,19067,19068,19069,19070,19071,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19082,19083,19084,19085,19086,19087,19088,19089,19090,19091,19092,19093,19094,19095,19096,19097,19098,19099,19100,19101,19102,19103,19104,19105,19106,19107,19108,19109,19110,19111,19112,19113,19114,19115,19116,19117,19118,19119,19120,19121,19122,19123,19124,19125,19126,19127,19128,19129,19130,19131,19132,19133,19134,19135,19136,19137,19138,19139,19140,19141,19142,19143,19144,19145,19146,19147,19148,19149,19150,19151,19152,19153,19154,19155,19156,19157,19158,19159,19160,19161,19162,19163,19164,19165,19166,19167,19168,19169,19170,19279,19280,19281,19282,19283,19284,19285,19286,19287,19288,20172,20173,20174,20175,20176,20177,20178,20179,20180,20181,20182,20183,20184,20185,20186,20187,20188,20189,20190,20191,20192,20193,20194,20195,20196,20198,20199,20200,20201,20202,20203,20204,20205,20206,20207,20208,20209,20210,20211,20212,20213,20214,20215,20216,20217,20218,20219,20220,20221,20222,20223,20224,20225,20226,20227,20228,20229,20230,20231,20232,20233,20234,20235,20236,20237,20238,20239,20240,20241,20242,20243,20244,20245,20247,20248,20249,20251,20252,20253,20254,20255,20256,20257,20258,20259,20260,20261,20262,20263,20264,20265,20266,20267,20268,20269,20270,20808,20272,20273,20274,20275,20276,20277,20278,20279,20280,20281,20282,20283,20284,20285,20286,20287,20288,20289,20290,20291,20292,20293,20294,20295,20296,20297,20298,20299,20300,20301,20302,20303,20304,20305,20306,20307,20308,20309,20310,20311,20312,20313,20314,20315,20316,20317,20318,20319,20320,20321,20323,20324,20325,20326,20327,20328,20329,20330,20331,20332,20333,20334,20335,20336,20337,20338,20339,20340,20341,20342,20343,20344,20345,20346,20347,20348,20349,20350,20351,20352,20353,20354,20355,20356,20357,20358,20360,20361,20362,20363,20364,20365,20366,20367,20368,20369,20370,20371,20372,20373,20374,20375,20376,20377,20378,20379,20380,20381,20382,20383,20384,20385,20386,20387,20388,20389,20390,20391,20392,20393,20394,20395,20396,20397,20398,20399,20400,20401,20402,20403,20404,20405,20406,20407,20408,20409,20410,20411,20446,20519,20524,20525,20526,20527,20528,20529,20530,20531,20532,20533,20534,20535,20536,20537,20538,20539,20540,20541,20542,20543,20544,20545,20546,20547,20548,20549,20550,20551,20552,20553,20554,20555,20556,20557,20558,20559,20560,20561,20562,20563,20564,20565,20566,20567,20569,20570,20571,20572,20573,20574,20575,20576,20590,20591,20592,20593,20594,20595]
    # skips = [10709, 17619, 10541, 19229, 20001, 20037, 19232, 20029, 21413, 19412, 25097, 25239, 30037, 30040, 30041, 30042, 30034, 30035, 30045, 30083, 30098, 25003, 25361, 19523, 19636, 19717, 20004, 20583, 20612, 20916, 20973, 20975, 21455, 21473, 25329, 25373, 26285, 20627, 25698, 26430, 26901, 10491, 21447, 27044, 27013, 25042, 26062, 19875, 18840, 20132, 28767, 27782, 21030, 26771]

    # inquiry_numbers = [26289, 29944]
    totals = {}
    inquiry_not_found = []
    odd_order_names = []
    last_generated_order_number = 10000
    sales_order_exists = []
    service.loop(nil) do |x|
      i = i + 1
      # next if i < 11729
      # next if !x.get_column('product sku').upcase.in?(['BM1A9O9','BM1Z9F4','BM1Z8Z7','BM0Z1F1','BM0P0K2','BM0Z0I8','BM0P0J9','BM0Z0I9','BM9C4D9','BM9B7R8','BM0L0D8','BM9B7M5','BM9C9L6','BM0C718','BM0Q7E2','BM9C4F8','BM00038','BM00039','BM00034','BM00035','BM00036','BM00037','BM9Y7F5','BM9U9M5','BM9Y6Q3','BM9P8F4','BM9P8G5','CUM01','BM5P9Y7'])
      # next if !inquiry_numbers.include?(x.get_column('inquiry number').to_i)
      # next if Product.where(sku: x.get_column('product sku')).present? == false
      puts '*********************** INQUIRY ', x.get_column('inquiry number')
      o_number = x.get_column('order number')
      if o_number.include?('.') || o_number.include?('/') || o_number.include?('-') || o_number.match?(/[a-zA-Z]/)
        odd_order_names.push(o_number)
      end
      puts "<-------------------#{o_number}"

      if odd_order_names.include?(o_number)
        old_order_number = o_number
      end

      inquiry = Inquiry.find_by_inquiry_number(x.get_column('inquiry number'))
      if inquiry.present?

        if !inquiry.billing_address.present?
          inquiry.update(billing_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_address.present?
          inquiry.update(shipping_address: inquiry.company.addresses.first)
        end

        if !inquiry.shipping_contact.present?
          inquiry.update(shipping_contact: inquiry.billing_contact)
        end

        sales_quote = inquiry.sales_quotes.last
        if sales_quote.blank?
          sales_quote = inquiry.sales_quotes.create!(overseer: inquiry.inside_sales_owner)
        end

        product_sku = x.get_column('product sku').upcase
        puts 'SKU', product_sku
        product = Product.find_by_sku(product_sku)

        inquiry_products = inquiry.inquiry_products.where(product_id: product.id)
        if inquiry_products.blank?
          similar_products = Product.where(name: product.name).where.not(sku: product.sku)
          if similar_products.present?
            similar_products.update_all(is_active: false)
          end
          sr_no = inquiry.inquiry_products.present? ? (inquiry.inquiry_products.last.sr_no + 1) : 1
          inquiry_product = inquiry.inquiry_products.where(product_id: product.id, sr_no: sr_no, quantity: x.get_column('quantity')).first_or_create!
        else
          inquiry_product = inquiry_products.first
          inquiry_product.update_attribute('quantity', inquiry_product.quantity + x.get_column('quantity').to_f)
        end

        supplier = Company.acts_as_supplier.find_by_name(x.get_column('supplier')) || Company.acts_as_supplier.find_by_name('Local')
        inquiry_product_supplier = InquiryProductSupplier.where(supplier_id: supplier.id, inquiry_product: inquiry_product).first_or_create!
        inquiry_product_supplier.update_attribute('unit_cost_price', x.get_column('unit cost price').to_f)
        row = nil

        if x.get_column('order number').include?('-')
          dump_order = x.get_column('order number').split('-')[0]
          if inquiry.sales_orders.pluck(:order_number).include?(dump_order.to_i)
            new_order_number = last_generated_order_number + 1
            updated_order = inquiry.sales_orders.where(order_number: dump_order.to_i).first.update(order_number: new_order_number, old_order_number: x.get_column('order number'))
            last_generated_order_number = new_order_number
          end
        end


        if inquiry.sales_orders.pluck(:old_order_number).include?(x.get_column('order number'))
          so = SalesOrder.find_by_old_order_number(x.get_column('order number'))
          if so.rows.map {|r| r.product.sku}.include?(x.get_column('product sku'))
            row = sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('product sku')).first
          end
        end
        if row.blank?
          row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
        end

        tax_rate = TaxRate.where(tax_percentage: x.get_column('tax rate').to_f).first_or_create!
        row.unit_selling_price = x.get_column('unit selling price (INR)').to_f
        row.quantity = x.get_column('quantity')
        row.margin_percentage = x.get_column('margin percentage')
        row.converted_unit_selling_price = x.get_column('unit selling price (INR)').to_f
        row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
        row.measurement_unit = MeasurementUnit.find_by_name(x.get_column('measurement unit')) || MeasurementUnit.default
        row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
        row.tax_rate = tax_rate || nil
        row.legacy_applicable_tax_percentage = x.get_column('tax rate').to_f || nil
        row.created_at = x.get_column('created at', to_datetime: true)

        row.save!

        puts '**************** QUOTE ROW SAVED ********************'

        if old_order_number.present?
          sales_order = sales_quote.sales_orders.where(old_order_number: x.get_column('order number')).first
          if !sales_order.present?
            new_order_number = last_generated_order_number + 1
            sales_order = sales_quote.sales_orders.create(old_order_number: x.get_column('order number'), order_number: new_order_number)
            last_generated_order_number = new_order_number
          end
        else
          sales_order = sales_quote.sales_orders.where(order_number: x.get_column('order number').to_i).first
        end

        sales_order.overseer = inquiry.inside_sales_owner
        sales_order.created_at = x.get_column('created at', to_datetime: true)
        sales_order.mis_date = x.get_column('created at', to_datetime: true)

        sales_order.status = x.get_column('status') || 'Approved'
        sales_order.remote_status = x.get_column('SAP status') || 'Processing'
        sales_order.sent_at = sales_quote.created_at
        sales_order.save!
        row_object = {sku: product_sku, supplier: x.get_column('supplier'), total_with_tax: row.total_selling_price_with_tax.to_f}
        totals[sales_order.order_number] ||= []
        totals[sales_order.order_number].push(row_object)
        puts '************************** ORDER SAVED *******************************'
        so_row = sales_order.rows.where(sales_quote_row: row).first_or_create!

        puts '****************** ORDER TOTAL ****************************', sales_order.order_number, sales_order.calculated_total_with_tax
      else
        if !inquiry.present?
          inquiry_not_found.push(x.get_column('inquiry number'))
        end
      end
      puts totals
      puts '<----------------------------------------INQUIRIES--------------------------------------------------->'
      puts inquiry_not_found.inspect
    end
  end

  def create_missing_invoices_with_string_literals
    kit_products = []
    missing_product = []
    missing_bible_orders = []
    odd_invoice_names = []
    missing_bible_invoices = []
    missing_inquiries = []
    last_generated_invoice_number = SalesInvoice.where.not(old_invoice_number: nil).order(invoice_number: :asc).last.invoice_number
    created_or_updated_invoices = []
    duplicate_invoices = [20710032]
    # inquiry_numbers = [1, 2, 25, 2978, 3329, 48, 53, 66, 67, 27, 213, 203, 222, 246, 14, 145, 211, 228, 90, 139, 200, 235, 11, 171, 254, 270, 96, 99, 269, 281, 283, 297, 307, 271, 305, 314, 377, 147, 253, 309, 350, 217, 30, 34, 138, 402, 3, 12, 15, 82, 84, 86, 100, 103, 107, 129, 159, 321, 405, 395, 469, 470, 432, 452, 480, 373, 478, 10, 426, 425, 453, 404, 16, 809, 688, 511, 207, 672, 722, 287, 515, 919, 407, 784, 311, 886, 791, 585, 959, 960, 1007, 1018, 995, 1016, 255, 419, 532, 915, 1032, 901, 1071, 1021, 1081, 481, 554, 971, 975, 1033, 957, 1017, 690, 1011, 1020, 1066, 1273, 1116, 1117, 1133, 1138, 257, 858, 1053, 568, 675, 1008, 1044, 1048, 1097, 1173, 352, 660, 729, 831, 832, 1039, 1152, 1178, 1015, 1189, 1057, 1204, 1293, 1200, 1201, 648, 865, 1260, 968, 1218, 1268, 520, 652, 820, 918, 1122, 1323, 1342, 667, 1358, 1350, 967, 972, 1083, 1373, 1431, 1443, 288, 961, 1175, 1420, 1451, 735, 1487, 1037, 1078, 1228, 1483, 516, 196, 1159, 1432, 969, 1353, 1447, 796, 1417, 1507, 1636, 1674, 1376, 1389, 1513, 1555, 1147, 1532, 1742, 1242, 1476, 1481, 1214, 1778, 1727, 1746, 1517, 1788, 1406, 1805, 1397, 1779, 1591, 1827, 1844, 1864, 1315, 1318, 1401, 1687, 897, 1459, 1574, 1824, 1266, 2008, 1546, 1829, 1272, 966, 993, 1042, 1763, 1868, 1901, 540, 1221, 1494, 1667, 1710, 2118, 2065, 1770, 1461, 1740, 1986, 2216, 994, 2188, 2239, 892, 1775, 813, 819, 893, 1463, 2108, 2120, 2202, 2208, 2210, 2298, 1430, 1900, 1975, 2270, 2236, 1163, 2005, 2014, 1696, 1885, 2226, 2367, 2018, 2212, 2420, 1887, 1840, 2195, 1473, 1073, 1639, 2408, 1691, 1831, 2550, 2597, 817, 1671, 2616, 1893, 2636, 1197, 2211, 2643, 2644, 2645, 2306, 2658, 1851, 2439, 2137, 2237, 2429, 2460, 2522, 2674, 2058, 2052, 2241, 2336, 2691, 2503, 2338, 2170, 2462, 2479, 2514, 2668, 2049, 2722, 2424, 2734, 2048, 1426, 2744, 2755, 1765, 2647, 814, 2507, 1054, 2776, 2617, 2794, 2772, 2801, 2800, 2826, 2833, 1871, 2257, 2534, 2678, 2729, 2732, 2779, 2361, 2588, 2036, 2723, 2903, 932, 2867, 2914, 2864, 2942, 1558, 2843, 2950, 2927, 2957, 2958, 2962, 2861, 2967, 2981, 2992, 2134, 2730, 2952, 2995, 2050, 2997, 2998, 2999, 2349, 2725, 7278, 3025, 2865, 3021, 2505, 2777, 2119, 3053, 2838, 2859, 1587, 3068, 3085, 3086, 3088, 3092, 2947, 3098, 2918, 3028, 3089, 3136, 3115, 2953, 2963, 3043, 3081, 3120, 3124, 3142, 7689, 7695, 3060, 3105, 3111, 3157, 6448, 7119, 2848, 3225, 3564, 3083, 3117, 3190, 3033, 3073, 3178, 3242, 3244, 3248, 3185, 3006, 3041, 3270, 3097, 3186, 3263, 3159, 3237, 3252, 3285, 3308, 3291, 3305, 2912, 3289, 3304, 3307, 3152, 3158, 3287, 3354, 3355, 3361, 3367, 3370, 2915, 3351, 1398, 3224, 3397, 3074, 3141, 3202, 3234, 3328, 3333, 3411, 3099, 3261, 3401, 2685, 3079, 3163, 3228, 3412, 3428, 3058, 3439, 3070, 3444, 3458, 3461, 2917, 3403, 3437, 3539, 3035, 3238, 3391, 3485, 3491, 3496, 3463, 3126, 3295, 3402, 3423, 3467, 3457, 3500, 3515, 2448, 3425, 3494, 3534, 3550, 3560, 3571, 3250, 3473, 3573, 3478, 3532, 3483, 3489, 3526, 3540, 3586, 3601, 3452, 3594, 3625, 1760, 3456, 3630, 3638, 2908, 3525, 3616, 3455, 4009, 4044, 3169, 3618, 3624, 3627, 3662, 4003, 3245, 3216, 3544, 4008, 4010, 4017, 4018, 6362, 4280, 4032, 4042, 3535, 4050, 3347, 3605, 4040, 4029, 4054, 4087, 3659, 4006, 4103, 9746, 4120, 2925, 3667, 4132, 4136, 3474, 3609, 4031, 4104, 4106, 4166, 4167, 4170, 3635, 4080, 4093, 4096, 4124, 4184, 3531, 3577, 4130, 4187, 3592, 3613, 4062, 4147, 4153, 4239, 3612, 3626, 4081, 4192, 4216, 4238, 4242, 4140, 4156, 4266, 4245, 3528, 4247, 4267, 9744, 4024, 4112, 4161, 4168, 4272, 4099, 4150, 4033, 4077, 4231, 4232, 4233, 4234, 4243, 3617, 4076, 4172, 4223, 4296, 4316, 4072, 4177, 4330, 4336, 4342, 4351, 2804, 4064, 4107, 4194, 3221, 4290, 4307, 4327, 4663, 9913, 4193, 4230, 4365, 4367, 4368, 3426, 4375, 4162, 4333, 4376, 4380, 4382, 4384, 5868, 4256, 4390, 4405, 4407, 4455, 7106, 4195, 4430, 3005, 4423, 4439, 4446, 4448, 3541, 4289, 4297, 4299, 4572, 9740, 555, 4478, 8832, 479, 3663, 4090, 4422, 4479, 4489, 4491, 7105, 4277, 4203, 4226, 4228, 4349, 4483, 4485, 4493, 4507, 4523, 4211, 4308, 4498, 4521, 4531, 4532, 4311, 4381, 4389, 4403, 4435, 4582, 4583, 4854, 4340, 3523, 4292, 4320, 4440, 4459, 4509, 4510, 4540, 4588, 4589, 4590, 4608, 4613, 5096, 9748, 4458, 4543, 4609, 4648, 9747, 4352, 4477, 4606, 4668, 4434, 4505, 4682, 4269, 2784, 3542, 4447, 4693, 4702, 4710, 4241, 4656, 4661, 4684, 4734, 4777, 5481, 6708, 2721, 2739, 4373, 4468, 4541, 4652, 4714, 4721, 5047, 4525, 4747, 4755, 4758, 4662, 4763, 4659, 3632, 4810, 4687, 4824, 4914, 4374, 4610, 4735, 4814, 4842, 4733, 5355, 4469, 4499, 4893, 4899, 4904, 4909, 4598, 4649, 476, 4913, 5338, 4343, 4725, 4745, 4765, 4766, 4775, 4954, 5102, 4776, 4865, 4992, 5004, 4567, 4883, 4950, 4983, 4451, 4660, 4772, 5022, 5027, 5044, 5049, 5053, 4201, 4295, 4494, 4566, 4685, 4949, 5001, 5091, 4034, 4889, 5015, 6884, 6886, 6887, 6888, 5101, 5145, 4605, 5088, 5089, 5105, 5152, 5167, 4959, 5007, 5171, 4906, 5014, 5078, 5169, 5180, 5191, 4998, 5094, 5223, 5226, 4346, 4789, 5010, 5087, 5158, 4284, 4863, 5289, 9750, 4618, 4671, 4677, 4724, 4727, 4826, 4862, 4895, 5025, 5028, 5032, 5160, 5213, 5215, 5216, 5217, 5219, 5224, 5225, 5258, 5268, 5386, 5416, 5426, 5436, 5461, 5476, 5514, 5528, 5543, 5594, 5611, 5615, 5293, 3639, 4646, 4880, 5316, 3260, 4972, 5240, 5341, 5350, 5359, 5399, 5319, 5401, 9745, 5026, 5195, 5378, 4759, 5157, 5308, 3645, 5248, 5321, 5363, 6268, 4401, 5322, 5397, 5427, 5487, 5246, 5304, 5439, 5447, 4850, 5063, 5423, 5507, 4565, 5331, 5490, 542, 5008, 5005, 4436, 5155, 5496, 6167, 4275, 5214, 5393, 5405, 5465, 5505, 9752, 9753, 9754, 9755, 9756, 9757, 2847, 5108, 5260, 5470, 6273, 5469, 5415, 5610, 6172, 5534, 5634, 5653, 5572, 5574, 5064, 3383, 4073, 4670, 5066, 5349, 5616, 5671, 5680, 5800, 6283, 9758, 5269, 5518, 5535, 5612, 5637, 5645, 5677, 5732, 5674, 3404, 4961, 5351, 5409, 5477, 5688, 5701, 5702, 5704, 5777, 5249, 5691, 5725, 5593, 5733, 5545, 5683, 5717, 5744, 5747, 5749, 4966, 5369, 5403, 5494, 5557, 5585, 5676, 5751, 5766, 5779, 5199, 5257, 5726, 5786, 5303, 5785, 5805, 5817, 6063, 4963, 5686, 5763, 5816, 5340, 5720, 5853, 5699, 5782, 5875, 5780, 5897, 5824, 5913, 5924, 5776, 5847, 4465, 5442, 5938, 5940, 5673, 5958, 5959, 5960, 5950, 5822, 5978, 4370, 5463, 5670, 5791, 5865, 5966, 6010, 6001, 6007, 5997, 6029, 6087, 6044, 6030, 6037, 5267, 6076, 6118, 5956, 6069, 6075, 5951, 6048, 5718, 5806, 6068, 5510, 5635, 5819, 5922, 5957, 6051, 6119, 6129, 5775, 5781, 6130, 6215, 6755, 6046, 6143, 6156, 6168, 6169, 5970, 5971, 6176, 6177, 5618, 6085, 6116, 6131, 6138, 5920, 6222, 7343, 5252, 6039, 6158, 6109, 6247, 6249, 6148, 6150, 6212, 6214, 6274, 6282, 6544, 6547, 6548, 5553, 5928, 6106, 6296, 6314, 6315, 6133, 6170, 6206, 6245, 6250, 6306, 6327, 6210, 6269, 6330, 6489, 4986, 5006, 5279, 5480, 5834, 5921, 6045, 6052, 6070, 6297, 6331, 6338, 6344, 6354, 6681, 6712, 5728, 5730, 6700, 6233, 6320, 6346, 6349, 6477, 6523, 6270, 6279, 6364, 5475, 5944, 6055, 6395, 6678, 5692, 5988, 6195, 6251, 6418, 6425, 6484, 6217, 6456, 6471, 6293, 6437, 5807, 6018, 6278, 6253, 6280, 6496, 6292, 6366, 5916, 6160, 6322, 6332, 6472, 6533, 6541, 6737, 6027, 6517, 8839, 6382, 6487, 6500, 6525, 6585, 6591, 5998, 6077, 6213, 6025, 6071, 6307, 6328, 6378, 6386, 6394, 6572, 6748, 6242, 6658, 6260, 6570, 6615, 6632, 5184, 6256, 6539, 6573, 6661, 6670, 6677, 6729, 6735, 6650, 3138, 5450, 6705, 6758, 6787, 4903, 5643, 6183, 6611, 6674, 5040, 6577, 6767, 6575, 6581, 6772, 6184, 6299, 6733, 6824, 6103, 6859, 6667, 6727, 6908, 6646, 6815, 6868, 6934, 6962, 6072, 6954, 6821, 6432, 6854, 7036, 7053, 7382, 5198, 5678, 6102, 6141, 6171, 6255, 6302, 6313, 6340, 6361, 6392, 6410, 6450, 6495, 6590, 6603, 6626, 6653, 6671, 6673, 6691, 6696, 6723, 6738, 6741, 6762, 6771, 6773, 6784, 6785, 6789, 6792, 6800, 6801, 6802, 6803, 6808, 6809, 6810, 6813, 6814, 6816, 6825, 6836, 6842, 6851, 6852, 6853, 6855, 6856, 6858, 6869, 6870, 6879, 6881, 6882, 6885, 6889, 6894, 6895, 6898, 6902, 6903, 6904, 6914, 6918, 6921, 6945, 6947, 6948, 6949, 6950, 6961, 6969, 6975, 6976, 6978, 6980, 6981, 6985, 6988, 6991, 7000, 7013, 7017, 7019, 7022, 7031, 7038, 7044, 7047, 7048, 7054, 7055, 7481, 7008, 6933, 7033, 7083, 6923, 6953, 7081, 7103, 6805, 7128, 7129, 7135, 6560, 5736, 5961, 6628, 6807, 7139, 7144, 6843, 6901, 6958, 7158, 7163, 7165, 7167, 7168, 7169, 7170, 7171, 7174, 6512, 7096, 7113, 7160, 6946, 7104, 7178, 7189, 15076, 6796, 7037, 7161, 7176, 6494, 6710, 6957, 7251, 6337, 6797, 6910, 7003, 7166, 7221, 7242, 7250, 7230, 7243, 6768, 7256, 7164, 7248, 6878, 6907, 7127, 7203, 7240, 7238, 7281, 7293, 6779, 7325, 6876, 7492, 7493, 7494, 7496, 7498, 7500, 7501, 7502, 7503, 7148, 7347, 7357, 6774, 7182, 7237, 7442, 6717, 7086, 7390, 7408, 7537, 7548, 7591, 4870, 6311, 7249, 7483, 7485, 7486, 9495, 6909, 7149, 7193, 7317, 7322, 7272, 7460, 7467, 7126, 7266, 7463, 7488, 6982, 7437, 7441, 9063, 6405, 7216, 7363, 7423, 7425, 7529, 7530, 7547, 7553, 7563, 7569, 7571, 7576, 7590, 5604, 6140, 7134, 5483, 6602, 7592, 7603, 7605, 7606, 7723, 8144, 7452, 7526, 7620, 6526, 6652, 6719, 7056, 7074, 7210, 7361, 7424, 7554, 7565, 7582, 7583, 7595, 7602, 7633, 7635, 7642, 7645, 7647, 7648, 7650, 7651, 7664, 7669, 7782, 7297, 7400, 7528, 7142, 7688, 7701, 7705, 7562, 7622, 7697, 7698, 7740, 7743, 7329, 7506, 5672, 7247, 7326, 7406, 7409, 7418, 7513, 7653, 7658, 7683, 7755, 7792, 7866, 8027, 8109, 8116, 8157, 8159, 8161, 7555, 7943, 10173, 10264, 7752, 7794, 5989, 7444, 7745, 7549, 7639, 7741, 8206, 8211, 8213, 7287, 7346, 7834, 7871, 7737, 7084, 7889, 7825, 7540, 7445, 7702, 7798, 7828, 7939, 7623, 7453, 7564, 7732, 7809, 7860, 7941, 8201, 8200, 7535, 7691, 7909, 7976, 7982, 7729, 7735, 7978, 7979, 7990, 7993, 8029, 7818, 7995, 7996, 7997, 8004, 8005, 7822, 7937, 7988, 8003, 7699, 7829, 7878, 7896, 8028, 8051, 7801, 7864, 8083, 7627, 7874, 7992, 9096, 7942, 8033, 8006, 6604, 7271, 7433, 7624, 7795, 7814, 7821, 7832, 7908, 7935, 7944, 7968, 7969, 7985, 8008, 8016, 8018, 8067, 8104, 8110, 8123, 6616, 7852, 7873, 7980, 8082, 6931, 7913, 8112, 8137, 8147, 6530, 7471, 7607, 7608, 7807, 7975, 8015, 8156, 8162, 8163, 8164, 8165, 8166, 8167, 8168, 8172, 8173, 8175, 7262, 7826, 7827, 10096, 10119, 10184, 10237, 10260, 10266, 10268, 10269, 10270, 10275, 10276, 10277, 10281, 10316, 6701, 7212, 7754, 7926, 8044, 8105, 8139, 8154, 7918, 8107, 8129, 8205, 7760, 7931, 8313, 8214, 8235, 7376, 7970, 8176, 8194, 8232, 8250, 8252, 8108, 8249, 8251, 8267, 8191, 8270, 7831, 7994, 8098, 8177, 8285, 8287, 8294, 8295, 8296, 8073, 8089, 8299, 8300, 8301, 8302, 8303, 8305, 8306, 8178, 8284, 8322, 8288, 8315, 7550, 7915, 8337, 7815, 8141, 7455, 7574, 8025, 8212, 8223, 8225, 8293, 8325, 5923, 7930, 8304, 8341, 8282, 8283, 8385, 8386, 8387, 8388, 8390, 8391, 8392, 8393, 8395, 8047, 8350, 8394, 9853, 9856, 7999, 8317, 8334, 8353, 8039, 8382, 8427, 8368, 8400, 7929, 8198, 8414, 8415, 8196, 8399, 8406, 8430, 8439, 8444, 8043, 8195, 8209, 8364, 4791, 8229, 8236, 8434, 7392, 8142, 7446, 8445, 8446, 8482, 7981, 8336, 8423, 8525, 8475, 8521, 7107, 8314, 8805, 8373, 8515, 7817, 8361, 8455, 8500, 8506, 8548, 6713, 8558, 8700, 8727, 7644, 7781, 8278, 8498, 8630, 8633, 9158, 14834, 8024, 8053, 8389, 8404, 7015, 8349, 8460, 8510, 8531, 8536, 8572, 8253, 8491, 8557, 8604, 8615, 5869, 7244, 7899, 8226, 8310, 8338, 8362, 8443, 8489, 8517, 8579, 8626, 8631, 8638, 8640, 8643, 8658, 8665, 8666, 8667, 8668, 8670, 8671, 8680, 8682, 8689, 8694, 8738, 8331, 8818, 8599, 8701, 8743, 7367, 8088, 8355, 8359, 8486, 8563, 8605, 8706, 8709, 8713, 8718, 8721, 8728, 8731, 8881, 8509, 8705, 8740, 8744, 8553, 8595, 8757, 8808, 8524, 8755, 8777, 8662, 8779, 8202, 8342, 8762, 8795, 8874, 8636, 8761, 7265, 8546, 8838, 8845, 8215, 8565, 8632, 8733, 8788, 8854, 8900, 8907, 8407, 8865, 8915, 8985, 8986, 8124, 8193, 8577, 8677, 8751, 8823, 8852, 8890, 8912, 8931, 8138, 8481, 8710, 8724, 8827, 8952, 8965, 8971, 7407, 7638, 8372, 8408, 8613, 8820, 8928, 8934, 8953, 8754, 8975, 8990, 8810, 10279, 7998, 8570, 8809, 8883, 8923, 8471, 8518, 9002, 9003, 9012, 8989, 9016, 9026, 8741, 9039, 9048, 9056, 9069, 8409, 8562, 8817, 9011, 9073, 9078, 9082, 9084, 8940, 10055, 10056, 10057, 10058, 10059, 10060, 8679, 8765, 8867, 8948, 9075, 9102, 8541, 8842, 8844, 8927, 8996, 9119, 7448, 8782, 8853, 8930, 9038, 9107, 9141, 9157, 9162, 9168, 9175, 8153, 8970, 8549, 8739, 9079, 9148, 9163, 9195, 9196, 9213, 9050, 9216, 8477, 8868, 8878, 8904, 8946, 9153, 9174, 9181, 9197, 9212, 9227, 15693, 8345, 8429, 9022, 9133, 9139, 9198, 9221, 9224, 9254, 9259, 9263, 8367, 9122, 9207, 9266, 8939, 9186, 9295, 8145, 9028, 9305, 9312, 9319, 8760, 8869, 8902, 9006, 9334, 9340, 7558, 8894, 8995, 9185, 9256, 9337, 9343, 9323, 9359, 9099, 9129, 9137, 9292, 9375, 9389, 9390, 7617, 8602, 9335, 9360, 9387, 9406, 9425, 9448, 8753, 8949, 9047, 9205, 9366, 9374, 9429, 9455, 9459, 9502, 7630, 9023, 9190, 9275, 9316, 9371, 9376, 9433, 9434, 9435, 9478, 9479, 9480, 9481, 9482, 9885, 8742, 9074, 9493, 9503, 7785, 8785, 8836, 9302, 9357, 9444, 9490, 9517, 9518, 9543, 12302, 9321, 9549, 9160, 9559, 9818, 8857, 9324, 9403, 9487, 9540, 9593, 9120, 9431, 9797, 9849, 9892, 9897, 10285, 8806, 9064, 9365, 9569, 9571, 9579, 9586, 9598, 9608, 9619, 9627, 9628, 9809, 8369, 9247, 9331, 9465, 9630, 9643, 9661, 8898, 9381, 9574, 9621, 9652, 9666, 9668, 9671, 9672, 9597, 9609, 9614, 9654, 9662, 9688, 9329, 9412, 9451, 9568, 9575, 9696, 9714, 9729, 9663, 9667, 9690, 9770, 9787, 8273, 9034, 9499, 9796, 9541, 9223, 9469, 9485, 9580, 9615, 9673, 9713, 9788, 9829, 9721, 9739, 9838, 9845, 9183, 9664, 9706, 9836, 9851, 9870, 9877, 14847, 8886, 9884, 9647, 9709, 9875, 9904, 9911, 9917, 9918, 9920, 9925, 9927, 9928, 9678, 10823, 14776, 8698, 10491, 15408, 12443, 16209, 15529, 17875, 18666, 19279, 19280, 19281, 19282, 19283, 19284, 19285, 19286, 19287, 19288, 10541, 18840, 19903, 25373, 27392, 27461, 27705, 19875, 26888, 27244, 30094, 30568, 29424, 30718, 29459, 30850, 30973, 31231, 31550, 29944]

    # 20210421
    i = 0
    service = Services::Shared::Spreadsheets::CsvImporter.new('Sales Order - Bible - Missing inquiries.csv', 'seed_files')
    # skips = [11563] # company_id -> xlktyVs
    service.loop(nil) do |x|
      i = i + 1
      # puts "<-------------#{i}----------->"
      # next if !inquiry_numbers.include?(x.get_column('Inquiry Number').to_i)
      # next if i < 17653
      inquiry_number = x.get_column('Inquiry Number')
      invoice_number = x.get_column('AR Invoice #')
      order_number = x.get_column('SO #')

      if inquiry_number.include?('.') || inquiry_number.include?('/') || inquiry_number.include?('-') || inquiry_number.match?(/[a-zA-Z]/)
        inquiry = Inquiry.find_by_old_inquiry_number(inquiry_number)
      else
        inquiry = Inquiry.find_by_inquiry_number(inquiry_number)
      end

      if x.get_column('AR Invoice Date') != nil
        # next if x.get_column('AR Invoice Date').to_date > Date.new(2018, 04, 01)
        puts "#{x.get_column('AR Invoice Date').to_date}"
      end

      if invoice_number.include?('.') || invoice_number.include?('/') || invoice_number.include?('-') || invoice_number.match?(/[a-zA-Z]/)
        odd_invoice_names.push(invoice_number)
      end
      puts "<-------------------#{invoice_number}"
      if odd_invoice_names.include?(invoice_number)
        old_invoice_number = invoice_number
      end

      if order_number.include?('.') || order_number.include?('/') || order_number.include?('-') || order_number.match?(/[a-zA-Z]/)
        sales_order = inquiry.sales_orders.find_by_old_order_number(order_number)
      else
        sales_order = inquiry.sales_orders.find_by_order_number(order_number)
      end

      puts "<-------------------SALES ORDER #{sales_order.order_number if sales_order.present?}"
      next if invoice_number.to_i.in?([20200086, 3000875, 20200130, 20200209, 20200207, 20200206, 20200052, 20300132, 20210047, 20212052, 20212053, 20610819, 20610946, 20610941, 20610900])
      if sales_order.present?
        puts '********************** Row *****************************', invoice_number
        inquiry = sales_order.inquiry
        unit_price = x.get_column('Unit Price').to_f
        sku = x.get_column('BM #')
        product = Product.find_by_sku(sku)

        if product.blank?
          missing_product.push(sku)
        end
        if product.present? && product.is_kit
          kit_products.push(invoice_number)
        end
        next if product.present? && product.is_kit

        if !inquiry.billing_address.present?
          inquiry.update_attributes(billing_address: inquiry.company.default_billing_address)
        end

        if !inquiry.shipping_address.present?
          inquiry.update(shipping_address: inquiry.company.default_shipping_address)
        end

        if !inquiry.shipping_contact.present?
          inquiry.update(shipping_contact: inquiry.billing_contact)
        end

        if old_invoice_number.present?
          invoice = sales_order.invoices.where(old_invoice_number: invoice_number).first
          if !invoice.present?
            new_invoice_number = last_generated_invoice_number + 1
            invoice = sales_order.invoices.create(invoice_number: new_invoice_number, old_invoice_number: invoice_number)
            last_generated_invoice_number = new_invoice_number
          end
        else
          existing_invoice = SalesInvoice.where(invoice_number: invoice_number.to_i).first
          invoice = sales_order.invoices.where(invoice_number: invoice_number.to_i).first
          if existing_invoice.present? && existing_invoice != invoice
            existing_invoice.update(sales_order_id: sales_order.id)
            invoice = existing_invoice
          else
            invoice = sales_order.invoices.where(invoice_number: invoice_number.to_i).first_or_create!
          end
        end

        quantity = x.get_column('Qty').to_f
        tax_amount = x.get_column('Tax Amount').to_f
        invoice_row_obj = {
            qty: quantity,
            sku: sku,
            name: (product.present? ? product.name.to_s : ''),
            price: unit_price,
            base_cost: nil,
            row_total: unit_price * quantity,
            base_price: unit_price,
            product_id: (product.present? ? product.id.to_param : nil),
            tax_amount: tax_amount,
            description: (product.present? ? product.description.to_s : ''),
            order_item_id: nil,
            base_row_total: unit_price * quantity,
            price_incl_tax: nil,
            additional_data: nil,
            base_tax_amount: tax_amount,
            discount_amount: nil,
            weee_tax_applied: nil,
            hidden_tax_amount: nil,
            row_total_incl_tax: (unit_price * quantity) + (tax_amount),
            base_price_incl_tax: (unit_price + (tax_amount / quantity)),
            base_discount_amount: nil,
            weee_tax_disposition: nil,
            base_hidden_tax_amount: nil,
            base_row_total_incl_tax: (unit_price * quantity) + (tax_amount),
            weee_tax_applied_amount: nil,
            weee_tax_row_disposition: nil,
            base_weee_tax_disposition: nil,
            weee_tax_applied_row_amount: nil,
            base_weee_tax_applied_amount: nil,
            base_weee_tax_row_disposition: nil,
            base_weee_tax_applied_row_amnt: nil
        }

        row = invoice.rows.where('metadata @> ?', {sku: sku}.to_json)
        if row.present?
          row.first.update_attributes(sku: sku, quantity: quantity, sales_invoice_id: invoice.id, metadata: invoice_row_obj)
        else
          SalesInvoiceRow.create!(sku: sku, quantity: quantity, sales_invoice_id: invoice.id, metadata: invoice_row_obj)
        end

        item_lines = invoice.rows.pluck(:metadata)
        metadata = {
            'state' => 1,
            'is_kit' => '',
            'qty_kit' => 0, # check
            'ItemLine' => item_lines,
            'desc_kit' => '', # check
            'order_id' => order_number,
            'store_id' => nil,
            'doc_entry' => invoice_number.to_i,
            'price_kit' => 0,
            'controller' => 'callbacks/sales_invoices',
            'created_at' => x.get_column('AR Invoice Date'),
            'grand_total' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'increment_id' => invoice_number,
            'sales_invoice' => {
                'created_at' => x.get_column('AR Invoice Date'),
                'updated_at' => nil
            },
            'unitprice_kit' => 0,
            'base_tax_amount' => item_lines.pluck('tax_amount').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'discount_amount' => '',
            'shipping_amount' => nil,
            'base_grand_total' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'customer_company' => nil,
            'hidden_tax_amount' => nil,
            'shipping_incl_tax' => nil,
            'base_subtotal' => item_lines.pluck('row_total').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'base_currency_code' => sales_order.inquiry.currency.try(:name),
            'base_to_order_rate' => sales_order.inquiry.currency.conversion_rate.to_f,
            'billing_address_id' => sales_order.inquiry.billing_address.present? ? sales_order.inquiry.billing_address.id : nil,
            'order_currency_code' => sales_order.inquiry.currency.try(:name),
            'shipping_address_id' => sales_order.inquiry.shipping_address.present? ? sales_order.inquiry.shipping_address.id : nil,
            'shipping_tax_amount' => nil,
            'store_currency_code' => '',
            'store_to_order_rate' => '',
            'base_discount_amount' => nil,
            'base_shipping_amount' => nil,
            'discount_description' => nil,
            'base_hidden_tax_amount' => nil,
            'base_shipping_incl_tax' => nil,
            'base_subtotal_incl_tax' => item_lines.pluck('base_row_total_incl_tax').inject(0) {|sum, value| sum + value.to_f}.round(2),
            'base_shipping_tax_amount' => nil,
            'shipping_hidden_tax_amount' => nil,
            'base_shipping_hidden_tax_amnt' => nil
        }
        invoice.assign_attributes(status: 1, metadata: metadata, mis_date: x.get_column('AR Invoice Date'), created_at: (x.get_column('AR Invoice Date').present? ? x.get_column('AR Invoice Date').to_datetime : DateTime.now))
        invoice.save!
        created_or_updated_invoices.push(invoice.invoice_number)
        puts '********************** Saving Invoice *****************************', invoice_number
      else
        missing_bible_orders.push(order_number)
        missing_bible_invoices.push(invoice_number)
      end
    end

    puts 'M SKus', missing_product.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'kit products', kit_products.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'odd SI names', odd_invoice_names.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'Missing bible orders', missing_bible_orders.join(',')
    puts '-----------------------------------------------------------------------------------------'
    puts 'Created Or Updated Invoices', created_or_updated_invoices.join(',')
  end

  def update_applicable_tax_percentage_in_sales_quote_rows
    has_nil_tax_rate_rows = []
    skips = [10211921, 10211959]
    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-02-15 Bible Sales Order Rows.csv', 'seed_files')
    service.loop(nil) do |x|
      next if skips.include?(x.get_column('order number').to_i)
      sales_order = SalesOrder.find_by_old_order_number(x.get_column('order number')) || SalesOrder.find_by_order_number(x.get_column('order number'))
      puts "******************************************************** SALES ORDER #{x.get_column('order number')} Fetched ***************************"

      if sales_order.present?
        if sales_order.rows.map {|r| r.product.sku}.include?(x.get_column('product sku'))
          row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('product sku')).first

          if row.present? && row.tax_rate_id.present?
            row_tax_percentage = row.tax_rate.tax_percentage
            puts "*************** TAX RATE #{row_tax_percentage.to_f}, APPLICABLE TAX PERCENTAGE #{row.legacy_applicable_tax_percentage.to_f} ***************************"
            if (row.legacy_applicable_tax_percentage == nil || (row.legacy_applicable_tax_percentage != row_tax_percentage))
              row.legacy_applicable_tax_percentage = row_tax_percentage
              row.save!

              puts "******************************************************** SALES ORDER #{x.get_column('order number')} UPDATED ***************************"
            end
          else
            tax_rate = TaxRate.where(tax_percentage: x.get_column('tax rate').to_f).first_or_create!
            row.legacy_applicable_tax_percentage = tax_rate || nil
            row.tax_rate = tax_rate || nil
            row.save!
            has_nil_tax_rate_rows.push(x.get_column('order number'))
          end
        end
      end
    end
    puts "NIL TAX RATE ROWS", has_nil_tax_rate_rows
  end

  def test_migrations
    data_set = [
        [
            'year' => 2018,
            'month' => 1,
            'order_total' => 300000,
            'order_count' => 23,
            'po_total' => 23000,
            'po_count' => 32,
            'invoice_total' => 250000,
            'invoice_count' => 38
        ],
        [
            'year' => 2018,
            'month' => 2,
            'order_total' => 300000,
            'order_count' => 23,
            'po_total' => 23000,
            'po_count' => 32,
            'invoice_total' => 250000,
            'invoice_count' => 38
        ],
    ]

    so_total_mismatches = []
    so_count_mismatches = []
    po_total_mismatches = []
    po_count_mismatches = []
    invoices_total_mismatches = []
    invoices_count_mismatches = []
    data_set.each do |data|
      current_year = data[0]['year']
      current_month = data[0]['month']

      start_date = Date.new(current_year, current_month, 1)
      end_date = start_date.end_of_month
      current_month_name = start_date.strftime("%B")

      so_total_to_check = data[0]['order_total']
      so_count_to_check = data[0]['order_count']
      po_total_to_check = data[0]['po_total']
      po_count_to_check = data[0]['po_count']
      invoices_total_to_check = data[0]['invoice_total']
      invoices_count_to_check = data[0]['invoice_count']

      #ORDERs
      orders = SalesOrder.includes(:sales_order_rows, :sales_quote_rows).where('mis_date BETWEEN ? AND ?', start_date, end_date)
      so_total = orders.sum(&:calculated_total)
      so_counts = orders.size

      if so_total < so_total_to_check || so_total > so_total_to_check
        so_total_mismatches << "Order Total for #{current_month_name}-#{current_year} mismatch."
      else
        puts "Order Total for #{current_month_name}-#{current_year} matches."
      end

      if so_counts < so_count_to_check || so_counts > so_count_to_check
        so_count_mismatches << "Order Count for #{current_month_name}-#{current_year} mismatch."
      else
        puts "Order Count for #{current_month_name}-#{current_year} matches."
      end


      #POs
=begin
      orders = PurchaseOrder.where('mis_date BETWEEN ? AND ?', start_date, end_date)
      po_total = orders.sum(&:calculated_total)
      po_counts = orders.size

      if po_total < po_total_to_check || po_total > po_total_to_check
        po_total_mismatches << "Order Total for #{current_month_name}-#{current_year} mismatch."
      else
        puts "PO Total for #{current_month_name}-#{current_year} matches."
      end

      if po_counts < po_count_to_check || po_counts > po_count_to_check
        po_count_mismatches << "Order Count for #{current_month_name}-#{current_year} mismatch."
      else
        puts "PO Count for #{current_month_name}-#{current_year} matches."
      end
=end

      #INVOICEs
      invoices = SalesInvoice.where('mis_date BETWEEN ? AND ?', start_date, end_date)
      invoices_total = invoices.sum(&:calculated_total)
      invoices_counts = invoices.size

      if invoices_total < invoices_total_to_check || invoices_total > invoices_total_to_check
        invoices_total_mismatches << "Order Total for #{current_month_name}-#{current_year} mismatch."
      else
        puts "Invoices Total for #{current_month_name}-#{current_year} matches."
      end

      if invoices_counts < invoices_count_to_check || invoices_counts > invoices_count_to_check
        invoices_count_mismatches << "Order Count for #{current_month_name}-#{current_year} mismatch."
      else
        puts "Invoices Count for #{current_month_name}-#{current_year} matches."
      end
    end
  end

  def test_bible_sales_orders_totals_mismatch


    column_headers = ['order_number', 'sprint_total', 'sprint_total_with_tax', 'bible_total', 'bible_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('Sales Order Comparison - Bible.csv', 'seed_files')

    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_order = SalesOrder.find_by_order_number(x.get_column('SO #'))
        if sales_order.present? && ((sales_order.calculated_total.to_f != x.get_column('SUM of Selling Price (as per SO / AR Invoice)').to_f) || (sales_order.calculated_total_with_tax.to_f != x.get_column('SUM of Gross Total Selling').to_f))
          writer << [sales_order.order_number, sales_order.calculated_total, sales_order.calculated_total_with_tax, x.get_column('SUM of Selling Price (as per SO / AR Invoice)'), x.get_column('SUM of Gross Total Selling')]
        end
      end
    end
  end


  def create_purchase_order(metadata, new_po_number = nil)
    inquiry = Inquiry.find_by_inquiry_number(metadata['PoEnquiryId'])
    payment_option = PaymentOption.find_by_name(metadata['PoPaymentTerms'].to_s.strip)
    begin
      if inquiry.present? && inquiry.final_sales_quote.present?
        if metadata['PoNum'].present? && !PurchaseOrder.find_by_po_number(metadata['PoNum']).present?
          purchase_orders = nil
          if new_po_number.present?
            purchase_orders = inquiry.purchase_orders.where(po_number: new_po_number).first_or_create!
          else
            purchase_orders = inquiry.purchase_orders.where(po_number: params['PoNum']).first_or_create!
          end
          purchase_orders do |purchase_order|
            purchase_order.assign_attributes(metadata: metadata)
            purchase_order.assign_attributes(material_status: 'Material Readiness Follow-Up')
            purchase_order.assign_attributes(logistics_owner: Services::Overseers::MaterialPickupRequests::SelectLogisticsOwner.new(purchase_order).call)
            if metadata['PoStatus'].to_i > 0
              purchase_order.assign_attributes(status: metadata['PoStatus'].to_i)
            else
              purchase_order.assign_attributes(status: PurchaseOrder.statuses[metadata['PoStatus']])
            end
            if payment_option.present?
              purchase_order.assign_attributes(payment_option: payment_option)
            end
            metadata['ItemLine'].each do |remote_row|
              purchase_order.rows.build do |row|
                row.assign_attributes(
                    metadata: remote_row
                )
              end
            end
          end
          return_response('Purchase Order created successfully.')
        end
      end
    rescue => e
      return_response(e.message, 0)
    end
  end



  def test_invoices_migrations
    service = Services::Shared::Spreadsheets::CsvImporter.new('Sales Order Comparison - Bible.csv', 'seed_files')
    missing_invoices = []
    missing_inquiries = []
    mismatched_invoices = []

    service.loop(nil) do |x|
      invoice = SalesInvoice.find_by_invoice_number(x.get_column('AR Invoice #'))
      inquiry = Inquiry.find_by_inquiry_number(x.get_column('Inquiry Number'))
      qty_to_check = x.get_column('Qty').to_i
      selling_price_to_check = x.get_column('Selling Price (as per SO / AR Invoice)').to_i
      sku = x.get_column('sku')
      tax_amount_to_check = x.get_column('Tax Amount').to_i

      if inquiry.blank?
        missing_inquiries << x.get_column('Inquiry Number')
      end

      if invoice.present?
        mismatch = false
        item = invoice.rows.where(:sku => sku).first
        if item.present?
          item_qty = item.metadata['qty']
          item_price = item.metadata['price'].to_i
          item_tax_amount = item.metadata['tax_amount'].to_i

          if qty_to_check != item_qty
            mismatch = true
          end

          if selling_price_to_check != item_price
            mismatch = true
          end

          if item_tax_amount != tax_amount_to_check
            mismatch = true
          end

          if mismatch
            mismatched_invoices << [x.get_column('AR Invoice #'), sku, qty_to_check, item_qty, selling_price_to_check, item_price, tax_amount_to_check, item_tax_amount]
          end
        else
          mismatched_invoices << [x.get_column('AR Invoice #'), sku, qty_to_check, 0, selling_price_to_check, 0, tax_amount_to_check, 0]
        end
      else
        missing_invoices << x.get_column('AR Invoice #')
      end
    end

    column_headers = ['invoice_number', 'sprint_total', 'sprint_tax', 'sprint_total_with_tax', 'sap_total', 'sap_tax', 'sap_total_with_tax']

    service = Services::Shared::Spreadsheets::CsvImporter.new('sap_sales_invoices.csv', 'seed_files')
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      service.loop(nil) do |x|
        sales_invoice = SalesInvoice.find_by_invoice_number(x.get_column('#'))
        sap_total_without_tax = 0
        total_without_tax = 0

        if sales_invoice.present? && !sales_invoice.is_legacy?
          total_without_tax = sales_invoice.metadata['base_grand_total'].to_f - sales_invoice.metadata['base_tax_amount'].to_f
          sap_total_without_tax = x.get_column('Document Total').to_f - x.get_column('Tax Amount (SC)').to_f
          if (total_without_tax != sap_total_without_tax) || (sales_invoice.metadata['base_grand_total'].to_f != x.get_column('Document Total').to_f)

            writer << [
                sales_invoice.invoice_number,
                total_without_tax,
                sales_invoice.metadata['base_tax_amount'].to_f,
                sales_invoice.metadata['base_grand_total'].to_f,
                sap_total_without_tax,
                x.get_column('Tax Amount (SC)').to_f,
                x.get_column('Document Total')
            ]
          end
        end
      end
    end
  end

  def test_bible_sales_orders_rows_mismatch(count = 500)

    mismatches = []
    missing_orders = []

    service = Services::Shared::Spreadsheets::CsvImporter.new('2019-02-15 Bible Sales Order Rows.csv', 'seed_files')
    service.loop(count) do |x|
      # puts x.get_row
      mismatch = nil
      sales_order = SalesOrder.where(order_number: x.get_column('order number')).or(SalesOrder.where(old_order_number: x.get_column('order number'))).first

      if sales_order.present?
        product = Product.find_by(sku: x.get_column('product sku'))

        unit_selling_price = x.get_column('unit selling price (INR)')
        total_selling_price_with_tax = x.get_column('total')
        unit_cost_price = x.get_column('unit cost price')

        sales_order_row = sales_order.rows.select {|sor| sor.product == product}.first
        tax_rate = x.get_column('tax rate')
        quantity = x.get_column('quantity')


        mismatch = {}


        if sales_order_row.blank?
          mismatch['issue in row'] = 'yes'
        end

         if quantity&.to_f != sales_order_row&.quantity
           mismatch['issue in quantity'] = 'yes'
         end

         if unit_cost_price&.to_f&.floor != sales_order_row&.sales_quote_row&.unit_cost_price&.floor
           mismatch['issue in unit_cost_price'] = 'yes'
         end

        if (unit_selling_price&.to_f&.round != sales_order_row&.unit_selling_price&.round)
          mismatch['issue in unit_selling_price'] = 'yes'
        end

        if (tax_rate&.to_f&.round != sales_order_row&.sales_quote_row&.tax_rate&.tax_percentage&.round)
          mismatch['issue in tax_rate'] = 'yes'
        end

        if (total_selling_price_with_tax&.to_f&.round != sales_order_row&.total_selling_price_with_tax&.round)
          mismatch['issue in total_selling_price_with_tax'] = 'yes'
        end

        if mismatch.any?
          mismatches << [
              [x.get_column('product sku'), x.get_column('order number')].join,
              x.get_column('product sku'), x.get_column('order number'), mismatch.keys.join(', ').gsub('issue in ',''), sales_order_row&.quantity&.to_f, quantity, unit_cost_price, sales_order_row&.sales_quote_row&.unit_cost_price&.round, sales_order_row&.unit_selling_price&.round, unit_selling_price, sales_order_row&.sales_quote_row&.tax_rate&.tax_percentage, tax_rate, sales_order_row&.total_selling_price_with_tax&.round, total_selling_price_with_tax, mismatch['issue in row'],  mismatch['issue in quantity'], mismatch['issue in unit_cost_price'], mismatch['issue in unit_selling_price'],  mismatch['issue in tax_rate'],  mismatch['issue in total_selling_price_with_tax']]
        end

      else
        missing_orders << x.get_column('order number')
      end
    end
    overseer = Overseer.find(185)
    filename = "#{Rails.root}/tmp/sales_orders_row_orders.csv"
    columns = ["Key", 'BM #', 'SO #', "Issues Summary", "quantity", "Bible Quantity", "Total Cost Price", "Bible Total Cost Price", "Unit Selling Price", "Bible Unit Selling Price", "Tax Rate", "Bible Tax Rate", "Total Selling Price with tax", "Bible Total Selling Price with tax","Issue In Row", "Issue In Quantity", "Issue In Unit Cost Price", "Issue In Unit Selling Price", "Issue In Tax Rate", "Issue In Total Selling Price With Tax"]
    CSV.open(filename, 'w', write_headers: true, headers: columns) do |writer|
      mismatches.each do |mismatch|
        writer << mismatch
      end
    end

    # csv_data = CSV.generate(write_headers: true, headers: columns) do |csv|
    #
    #   mismatches.each do |object|
    #
    #     csv << object
    #
    #   end
    #
    # end
    #
    #
    # temp_file = File.open(Rails.root.join('tmp', filename), 'wb')
    #
    # begin
    #
    #   temp_file.write(csv_data)
    #
    #   temp_file.close
    #
    #   overseer.file.attach(io: File.open(temp_file.path), filename: filename)
    #
    #   overseer.save!
    #
    #   puts Rails.application.routes.url_helpers.rails_blob_path(overseer.file, only_path: true)
    #
    # rescue => ex
    #
    #   puts ex.message
    #
    # end

    # QUANTITY
    # TAX RATE %
    # SP
    # SP W TAX
    # COST
    [missing_orders, mismatches]
  end
  # test_bible_sales_orders_rows_mismatch
end
