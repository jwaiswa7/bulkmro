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
    MeasurementUnit.first_or_create! measurement_units.map { |mu| { name: mu } }
  end

  def lead_time_option
    LeadTimeOption.first_or_create!([
                                        { name: '2-3 DAYS', min_days: 2, max_days: 3 },
                                        { name: '1 WEEK', min_days: 7, max_days: 7 },
                                        { name: '8-10 DAYS', min_days: 8, max_days: 10 },
                                        { name: '1-2 WEEKS', min_days: 7, max_days: 14 },
                                        { name: '2 WEEKS', min_days: 14, max_days: 14 },
                                        { name: '2-3 WEEK', min_days: 14, max_days: 21 },
                                        { name: '3 WEEKS', min_days: 21, max_days: 21 },
                                        { name: '3-4 WEEKS', min_days: 21, max_days: 28 },
                                        { name: '4 WEEKS', min_days: 28, max_days: 28 },
                                        { name: '5 WEEKS', min_days: 35, max_days: 35 },
                                        { name: '4-6 WEEKS', min_days: 28, max_days: 42 },
                                        { name: '6-8 WEEKS', min_days: 42, max_days: 56 },
                                        { name: '8 WEEKS', min_days: 56, max_days: 56 },
                                        { name: '20 WEEKS', min_days: 140, max_days: 140 },
                                        { name: '24 WEEKS', min_days: 168, max_days: 168 },
                                        { name: '6-10 WEEKS', min_days: 42, max_days: 70 },
                                        { name: '10-12 WEEKS', min_days: 70, max_days: 84 },
                                        { name: '12-14 WEEKS', min_days: 84, max_days: 98 },
                                        { name: '14-16 WEEKS', min_days: 98, max_days: 112 },
                                        { name: 'MORE THAN 14 WEEKS', min_days: 98, max_days: nil },
                                        { name: 'MORE THAN 12 WEEKS', min_days: 84, max_days: nil },
                                        { name: 'MORE THAN 6 WEEKS', min_days: 42, max_days: nil },
                                        { name: '60 days from the date of order for 175MT, and 60 days for remaining from the date of call', min_days: 60, max_days: 120 },
                                        { name: 'In Stock', min_days: 0, max_days: 0 },
                                        { name: 'Refer T&C', min_days: 0, max_days: 0 }
                                    ])
  end

  def currencies
    Currency.first_or_create!([
                                  { name: 'USD', conversion_rate: 71.59, legacy_id: 2 },
                                  { name: 'INR', conversion_rate: 1, legacy_id: 0 },
                                  { name: 'EUR', conversion_rate: 83.85, legacy_id: 1 },
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

    status_mapping = { '0' => 20, '1' => 10 }
    contact_group_mapping = { 'General' => 10, 'Company Top Manager' => 20, 'Retailer' => 30, 'Ador' => 40, 'Vmi_group' => 50, 'C-Form customer GROUP' => 60, 'Manager' => 70 }

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
      next if id.in? %w(3275)

      alias_name = x.get_column('aliasname')
      alias_legacy_id = x.get_column('Magento Id')
      account = if alias_legacy_id.present?
        Account.find_by_legacy_id(alias_legacy_id)
      else
        legacy_account
      end

      company_type_mapping = { 'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110 }
      priority_mapping = { '0' => 10, '1' => 20 }
      nature_of_business_mapping = { 'Trading' => 10, 'Manufacturer' => 20, 'Dealer' => 30 }
      is_msme_mapping = { 'N' => false, 'Y' => true }
      urd_mapping = { 'N' => false, 'Y' => true }

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
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_contact_mapping.csv', folder)

    service.loop(limit) do |x|
      company_name = x.get_column('cmp_name')
      company_id = x.get_column('cmp_id')
      next if company_name.in? ['Amazon Online Sales']
      next if company_id.in? %w(1764)

      contact_email = x.get_column('email', downcase: true)
      if contact_email && company_name
        company = Company.acts_as_customer.find_by_name(company_name)

        if company.present?
          company_contact = CompanyContact.where(company: company, contact: Contact.find_by_email(contact_email)).first_or_initialize
          company_contact.remote_uid = x.get_column('sap_id')
          company_contact.legacy_metadata = x.get_row
          company_contact.save!
          company.update_attributes(default_company_contact: company_contact) if company.legacy_metadata['default_contact'] == x.get_column('entity_id')
        end
      end
    end
  end

  def addresses
    legacy_state = AddressState.where(name: 'Legacy Indian State', country_code: 'IN').first_or_create
    service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv', folder)
    gst_type = { 1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60 }

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

      company = Company.find_by_legacy_id!(legacy_id)
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
    supplier_service = Services::Shared::Spreadsheets::CsvImporter.new('suppliers.csv', folder)
    supplier_service.loop(limit) do |x|
      account = x.get_column('alias_id') ? Account.non_trade : Account.trade
      supplier_name = x.get_column('sup_name')

      next if x.get_column('sup_id').in? %w(5406)

      company_type_mapping = { 'proprietorship' => 10, 'Private Limited' => 20, 'contractor' => 30, 'trust' => 40, 'Public Limited' => 50, 'dealer' => 50, 'distributor' => 60, 'trader' => 70, 'manufacturer' => 80, 'wholesaler/stockist' => 90, 'serviceprovider' => 100, 'employee' => 110 }
      is_msme_mapping = { 'N' => false, 'Y' => true }
      urd_mapping = { 'N' => false, 'Y' => true }

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
    gst_type_mapping = { 1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6 => 60 }

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
    opportunity_type = { 'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80 }
    quote_category = { 'bmro' => 10, 'ong' => 20 }
    opportunity_source = { 1 => 10, 2 => 20, 3 => 30, 4 => 40 }

    service = Services::Shared::Spreadsheets::CsvImporter.new('inquiries_without_amazon.csv', folder)
    service.loop(limit) do |x|
      company = Company.find_by_remote_uid(x.get_column('customer_company')) || legacy_company
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
    opportunity_type = { 'amazon' => 10, 'rate_contract' => 20, 'financing' => 30, 'regular' => 40, 'service' => 50, 'repeat' => 60, 'route_through' => 70, 'tender' => 80 }
    quote_category = { 'bmro' => 10, 'ong' => 20 }
    opportunity_source = { 1 => 10, 2 => 20, 3 => 30, 4 => 40 }

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
    price_type_mapping = { 'CIF' => 30, 'CIP Mumbai Airport' => 80, 'DAP' => 50, 'DD' => 60, 'Door Delivery' => 60, 'EXW' => 10, 'FCA Mumbai' => 70, 'FOB' => 20, 'CFR' => 40 }
    freight_option_mapping = { 'Extra as per Actual' => 20, 'Included' => 10 }
    packing_and_forwarding_option_mapping = { 'Included' => 10, 'Not Included' => 20 }

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
    legacy_request_status_mapping = { 'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70 }
    remote_status = { 'Supplier PO: Request Pending' => 17, 'Supplier PO: Partially Created' => 18, 'Partially Shipped' => 19, 'Partially Invoiced' => 20, 'Partially Delivered: GRN Pending' => 21, 'Partially Delivered: GRN Received' => 22, 'Supplier PO: Created' => 23, 'Shipped' => 24, 'Invoiced' => 25, 'Delivered: GRN Pending' => 26, 'Delivered: GRN Received' => 27, 'Partial Payment Received' => 28, 'Payment Received (Closed)' => 29, 'Cancelled by SAP' => 30, 'Short Close' => 31, 'Processing' => 32, 'Material Ready For Dispatch' => 33, 'Order Deleted' => 70 }
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
          sales_order_rows = sales_order.rows.joins(:inquiry_product).where(inquiry_products: { product_id: product.id })
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
    company_type_mapping = { 'is_supplier' => 10, 'is_customer' => 20 }
    purpose = { 'First Meeting/Intro Meeting' => 10, 'Follow up' => 20, 'Negotiation' => 30, 'Closure' => 40, 'Others' => 50 }
    activity_type = { 'Meeting' => 10, 'Phone call' => 20, 'Email' => 30, 'Quote/Tender Prep' => 40, 'Tender preparation' => 50 }
    activity_status = { 'Approved' => 10, 'Pending Approval' => 20, 'Rejected' => 30 }

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
    payment_method = { 'banktransfer' => 10, 'Cheque' => 20, 'checkmo' => 30, 'razorpay' => 40, 'free' => 50, 'roundoff' => 60, 'bankcharges' => 70, 'cash' => 80, 'creditnote' => 85, 'writeoff' => 90, 'Transfer Acct' => 95 }
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
        rows = po_request.sales_order.rows.inject({}) { |hash, row| ; hash[row.sales_quote_row.product.sku] = row.id; hash }
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
      rows = sales_order.rows.inject({}) { |hash, row| ; hash[row.sales_quote_row.product.sku] = row.id; hash }
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
        if purchase_order.po_request != "PO Created"
          purchase_order.po_request.assign_attributes(status: 'PO Created')
          purchase_order.po_request.save(validate: false)
        end

        if (purchase_order.material_status == nil)
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
            email_message.assign_attributes({from: current_overseer.email, to: current_overseer.email, subject: "Internal Ref Inq ##{purchase_order.inquiry.inquiry_number} Purchase Order ##{purchase_order.po_number}"})
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
      target_type = { '1' => 10, '4' => 20, '7' => 30, '2' => 40, '3' => 50, '6' => 60 }

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
        legacy_request_status_mapping = { 'requested' => 10, 'SAP Approval Pending' => 20, 'rejected' => 30, 'SAP Rejected' => 40, 'Cancelled' => 50, 'approved' => 60, 'Order Deleted' => 70 }
        remote_status = { 'Supplier PO: Request Pending' => 17, 'Supplier PO: Partially Created' => 18, 'Partially Shipped' => 19, 'Partially Invoiced' => 20, 'Partially Delivered: GRN Pending' => 21, 'Partially Delivered: GRN Received' => 22, 'Supplier PO: Created' => 23, 'Shipped' => 24, 'Invoiced' => 25, 'Delivered: GRN Pending' => 26, 'Delivered: GRN Received' => 27, 'Partial Payment Received' => 28, 'Payment Received (Closed)' => 29, 'Cancelled by SAP' => 30, 'Short Close' => 31, 'Processing' => 32, 'Material Ready For Dispatch' => 33, 'Order Deleted' => 70 }
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
      tax_rates = { '14' => 0, '15' => 12, '16' => 18, '17' => 28, '18' => 5 }
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
      sales_order_rows = company_inquiries.map { |i| i.sales_order_rows.includes(:product).joins(:product).where('products.id = ?', product_id) }.flatten.compact
      sales_order_row_price = sales_order_rows.map { |r| r.unit_selling_price }.flatten if sales_order_rows.present?
      return sales_order_row_price.min if sales_order_row_price.present?
      sales_quote_rows = company_inquiries.map { |i| i.sales_quote_rows.includes(:product).joins(:product).where('products.id = ?', product_id) }.flatten.compact
      sales_quote_row_price = sales_quote_rows.pluck(:unit_selling_price)
      return sales_quote_row_price.min
    end

    def generate_customer_products_from_existing_products
      overseer = Overseer.default
      customers = Contact.all
      customers.each do |customer|
        customer_companies = customer.companies
        inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company: customer_companies).map { |i| i.inquiry_products }.flatten
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
        if company.addresses.present? && !company.addresses.map { |address| address.country_code }.include?('IN')
          company.update_attribute('is_international', true)
        end
      end
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
      enddef sap_sales_orders_totals_mismatch
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
        so.invoice_total = so.invoices.map { |i| i.metadata.present? ? (i.metadata['base_grand_total'].to_f - i.metadata['base_tax_amount'].to_f) : 0.0 }.inject(0) { |sum, x| sum + x }
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
      service = Services::Shared::Spreadsheets::CsvImporter.new('missing_orders.csv', 'seed_files')
      i = 0
      skips = [10709, 17619, 10541, 19229, 20001, 20037, 19232, 20029, 21413, 19412, 25097, 25239, 30037, 30040, 30041, 30042, 30034, 30035, 30045, 30083, 30098, 25003, 25361, 19523, 19636, 19717, 20004, 20583, 20612, 20916, 20973, 20975, 21455, 21473, 25329, 25373, 26285, 20627, 25698, 26430, 26901, 10491, 21447, 27044, 27013, 25042, 26062, 19875, 18840, 20132, 28767, 27782, 21030, 26771]
      totals = {}
      inquiry_not_found = []
      sales_order_exists = []
      service.loop(nil) do |x|
        i = i + 1
        next if i < 11729
        next if x.get_column('product sku').in?(['BM9Y7F5', 'BM9U9M5', 'BM9Y6Q3', 'BM9P8F1', 'BM9P8F4', 'BM9P8G5', 'BM5P9Y7', 'BM9R0R1', 'BM9H7O3', 'BM9P0T9', 'BM9J7D7'])
        next if skips.include?(x.get_column('inquiry number').to_i)
        next if Product.where(sku: x.get_column('product sku')).present? == false
        puts '*********************** INQUIRY ', x.get_column('inquiry number')
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

          product_sku = x.get_column('product sku')
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
            if so.rows.map { |r| r.product.sku }.include?(x.get_column('product sku'))
              row = sales_quote.rows.joins(:product).where('products.sku = ?', x.get_column('product sku')).first
            end
          end
          if row.blank?
            row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
          end

          row.unit_selling_price = x.get_column('unit selling price (INR)').to_f
          row.quantity = x.get_column('quantity')
          row.margin_percentage = x.get_column('margin percentage')
          row.converted_unit_selling_price = x.get_column('unit selling price (INR)').to_f
          row.inquiry_product_supplier.unit_cost_price = x.get_column('unit cost price').to_f
          row.measurement_unit = MeasurementUnit.find_by_name(x.get_column('measurement unit')) || MeasurementUnit.default
          row.tax_code = TaxCode.find_by_chapter(x.get_column('HSN code')) if row.tax_code.blank?
          row.tax_rate = TaxRate.find_by_tax_percentage(x.get_column('tax rate')) || nil
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
          row_object = { sku: product_sku, supplier: x.get_column('supplier'), total_with_tax: row.total_selling_price_with_tax.to_f }
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
      end
      puts totals
      puts '<----------------------------------------INQUIRIES--------------------------------------------------->'
      puts inquiry_not_found.inspect
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
        so.invoice_total = so.invoices.map { |i| i.metadata.present? ? (i.metadata['base_grand_total'].to_f - i.metadata['base_tax_amount'].to_f) : 0.0 }.inject(0) { |sum, x| sum + x }
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
end
