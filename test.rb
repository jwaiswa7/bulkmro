Overseer.create!(
    :first_name => 'Ashwin',
    :last_name => 'Goyal',
    :email => 'ashwin.goyal@bulkmro.com',
    :password => 'abc123',
    :password_confirmation => 'abc123'
)

overseerService = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv')
overseerService.loop(100) do |x|
  Overseer.create!(
    first_name: x.get_column('firstname'), 
    last_name: x.get_column('lastname'),
    email: x.get_column('email'),
    username: x.get_column('username'),
    mobile: x.get_column('mobile'),
    designation: x.get_column('designation'),
    identifier: x.get_column('identifier'),
    geography: x.get_column('geography'),
    remote_sales_uid: x.get_column('sap_internal_code'),
    remote_emp_uid: x.get_column('employee_id')
    )
end


#Country and States
state_service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv')
state_service.loop(100) do |x|
  if x.get_column('default_name').present? && x.get_column('code').present? && x.get_column('region_id').present?
    AddressState.create!(
        name: x.get_column('default_name'),
        country_id: x.get_column('country_id'),
        region_code: x.get_column('code'),
        region_gst_id: x.get_column('gst_state_code'),
        region_id: x.get_column('region_id'),
        remote_uid: x.get_column('sap_region_code')
    )
  end
end

industry_service = Services::Shared::Spreadsheets::CsvImporter.new('industry.csv')
industry_service .loop(100) do |x|
  Industry.create!(
      remote_uid: x.get_column('industry_sap_id'),
      industry_name: x.get_column('industry_name'),
      industry_description: x.get_column('industry_description')
  )
end

payment_term_service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
payment_term_service .loop(100) do |x|
  PaymentOption.create!(
      remote_uid: x.get_column('group_code'),
      name: x.get_column('name')
  )
end

account_service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')
account_service.loop(100) do |x|
  #create account alias
  account_name = x.get_column('aliasname')
  remote_uid = x.get_column('sap_id')
  Account.where(remote_uid: remote_uid).first_or_create do |accounts|
    accounts.remote_uid = remote_uid
    accounts.name = account_name
  end
end

#create contacts
company_contacts_service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')
company_contacts_service.loop(100) do |x|
  Contact.create!(
      account: Account.find_by_name(x.get_column('account')),
      remote_id: x.get_column('sap_id'),
      first_name: x.get_column('firstname'),
      last_name: x.get_column('lastname'),
      prefix: x.get_column('prefix'),
      designation: x.get_column('designation'),
      telephone: x.get_column('telephone'),
      #role: x.get_column('account'),
      status: x.get_column('is_active'),
      contact_group: x.get_column('group'),
      email: x.get_column('email')
  )
end

#create companies
company_service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv')
company_service.loop(100) do |x|
  Company.create!(
      account: Account.find_by_name(x.get_column('aliasname')),
      industry: Industry.find_by_industry_name(x.get_column('cmp_industry')),
      remote_uid: x.get_column('cmp_id'),
      default_payment_option_id: PaymentOption.find_by_name(x.get_column('default_payment_term')),
      #default_billing_address_id: x.get_column('default_billing'),
      #default_shipping_address_id: x.get_column('default_shipping'),
      inside_sales_owner_id: Overseer.find_by_email(x.get_column('sales_person')),
      outside_sales_owner_id: Overseer.find_by_email(x.get_column('outside_sales_person')),
      sales_manager_id: Overseer.find_by_email(x.get_column('sales_manager')),
      name: x.get_column('cmp_name'),
      site: x.get_column('cmp_website'),
      company_type: x.get_column('company_type'),
      priority: x.get_column('is_strategic'),
      nature_of_business: x.get_column('nature_of_business'),
      credit_limit: x.get_column('creditlimit'),
      is_msme: x.get_column('msme'),
      is_unregistered_dealer: x.get_column('urd'),
      tax_identifier: x.get_column('cmp_gst')
  )
end

address_service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv')
address_service.loop(100) do |x|
  Address.create!(
      company: Company.find_by_name(x.get_column('company_name')),
      gst:x.get_column('gst_num'),
      country_code:x.get_column('country'),
      state_name:x.get_column('state'),
      city_name:x.get_column('city'),
      pincode:x.get_column('pincode'),
      street1:x.get_column('address'),
      #street2:x.get_column('gst_num'),
      cst:x.get_column('cst_num'),
      vat:x.get_column('vat_num'),
      tan:x.get_column('tan_num'),
      #excise:x.get_column('gst_num'),
      telephone:x.get_column('telephone'),
      #mobile:x.get_column('gst_num'),
      gst_type:x.get_column('gst_type')
  )
end

#HSN Codes
#Model 
	#Tax : rails g model TaxRemoteLabel local_tax_code remote_tax_code rate:integer tax_code
	#HSN : rails generate model Hsn hsn_remote_uid:integer chapter:integer tariff:integer tariff_subheading:integer description:text hsn_code is_service:integer


hsn_service = Services::Shared::Spreadsheets::CsvImporter.new('hsncodes.csv')
hsn_service.loop(100) do |x|
    HsnCode.create!(
      hsn_remote_uid: x.get_column('internal_key'),
      chapter: x.get_column('chapter'),
      tariff: x.get_column('tariff_heading'),
      tariff_subheading: x.get_column('tariff_subheading'),
      description: x.get_column('description'),
      hsn_code: x.get_column('hsn'),
      is_service: x.get_column('is_service')
    )
end

#Local and Remote tax labels mapping

tax_service = Services::Shared::Spreadsheets::CsvImporter.new('BmroSapTaxMapping.csv')
tax_service.loop(100) do |x|
  HsnCode.create!(
      local_tax_code: x.get_column('bmro_tax_code'),
      remote_tax_code: x.get_column('sap_tax_code'),
      rate: x.get_column('rate'),
      tax_code: x.get_column('tax_code')
  )
end