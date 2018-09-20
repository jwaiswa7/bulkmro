MeasurementUnit.create([
                           { name: 'EA' },
                           { name: 'SET' },
                           { name: 'PK' },
                           { name: 'KG' },
                           { name: 'M' },
                           { name: 'FT' },
                           { name: 'Pair' },
                           { name: 'PR' },
                           { name: 'BOX' },
                           { name: 'LTR' },
                           { name: 'LT' },
                           { name: 'MTR' },
                           { name: 'ROLL' },
                           { name: 'Nos' },
                           { name: 'PKT' },
                           { name: 'REEL' },
                           { name: 'FEET' },
                           { name: 'Meter' },
                           { name: '"1 ROLL"' },
                           { name: 'ml' },
                           { name: 'MAT' },
                           { name: 'LOT' },
                           { name: 'No' },
                           { name: 'RFT' },
                           { name: 'Bundle' },
                           { name: 'NPkt' },
                           { name: 'Metre' },
                           { name: 'CAN' },
                           { name: 'SQ.Ft' },
                           { name: 'BOTTLE' },
                           { name: 'BOTTEL' },
                           { name: '"CUBIC METER"' },
                           { name: 'PC' },
                       ])

service = Services::Shared::Spreadsheets::CsvImporter.new('hsncodes.csv')
service.loop(service.rows_count) do |x|
  TaxCode.create!(
      remote_uid: x.get_column('internal_key'),
      chapter: x.get_column('chapter'),
      code: x.get_column('hsn').gsub!('.', ''),
      description: x.get_column('description'),
      is_service: x.get_column('is_service') == 'NULL' ? false : true,
      tax_percentage: x.get_column('tax_code').match(/\d+/)[0].to_f
  )
end

LeadTimeOption.create!([
    { name: "2-3 DAYS", min_days: 2, max_days: 3 },
    { name: "1 WEEK", min_days: 7, max_days: 7 },
    { name: "8-10 DAYS", min_days: 8, max_days: 10 },
    { name: "1-2 WEEKS", min_days: 7, max_days: 14 },
    { name: "2 WEEKS", min_days: 14, max_days: 14 },
    { name: "2-3 WEEK", min_days: 14, max_days: 21 },
    { name: "3 WEEKS", min_days: 21, max_days: 21 },
    { name: "3-4 WEEKS", min_days: 21, max_days: 28 },
    { name: "4 WEEKS", min_days: 28, max_days: 28 },
    { name: "5 WEEKS", min_days: 35, max_days: 35 },
    { name: "4-6 WEEKS", min_days: 28, max_days: 42 },
    { name: "6-8 WEEKS", min_days: 42, max_days: 56 },
    { name: "8 WEEKS", min_days: 56, max_days: 56 },
    { name: "6-10 WEEKS", min_days: 42, max_days: 70 },
    { name: "10-12 WEEKS", min_days: 70, max_days: 84 },
    { name: "12-14 WEEKS", min_days: 84, max_days: 98 },
    { name: "14-16 WEEKS", min_days: 98, max_days: 112 },
    { name: "MORE THAN 14 WEEKS", min_days: 98, max_days: nil },
    { name: "60 days from the date of order for 175MT, and 60 days for remaining from the date of call", min_days: 60, max_days: 120}
])

Currency.create!([
                     { name: 'USD', conversion_rate: 71.59 },
                     { name: 'INR', conversion_rate: 1 },
                     { name: 'EUR', conversion_rate: 83.85 },
                 ])

Overseer.create!(
    :first_name => 'Ashwin',
    :last_name => 'Goyal',
    :email => 'ashwin.goyal@bulkmro.com',
    :username => 'ashwin.goyal',
    :password => 'abc123',
    :password_confirmation => 'abc123'
)

overseerService = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv')
overseerService.loop(overseerService.rows_count) do |x|

  Overseer.where(email: x.get_column('email').strip.downcase).first_or_create do |overseer|
    overseer.assign_attributes(
      first_name: x.get_column('firstname'),
      last_name: x.get_column('lastname'),
      username: x.get_column('username'),
      mobile: x.get_column('mobile'),
      designation: x.get_column('designation'),
      identifier: x.get_column('identifier'),
      geography: x.get_column('geography'),
      remote_sales_uid: x.get_column('sap_internal_code'),
      remote_emp_uid: x.get_column('employee_id'),
      password: 'abc123',
      password_confirmation: 'abc123'
    )
  end
end

#Country and States
state_service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv')
state_service.loop(state_service.rows_count) do |x|
  if x.get_column('default_name').present? && x.get_column('code').present? && x.get_column('region_id').present?
    AddressState.where(name: x.get_column('default_name').strip).first_or_create do |state|
      state.assign_attributes(
        country_code: x.get_column('country_id'),
        region_code: x.get_column('code'),
        region_gst_id: x.get_column('gst_state_code'),
        region_id: x.get_column('region_id'),
        remote_uid: x.get_column('sap_region_code')
      )
    end
  end
end

payment_term_service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
payment_term_service.loop(payment_term_service.rows_count) do |x|
  PaymentOption.where(name: x.get_column('value')).first_or_create do |payment_option|
    payment_option.assign_attributes(
      remote_uid: x.get_column('group_code')
      )
    end
end

#Create FAKE account

Account.create!(
           remote_uid: 99999999,
           name:"Fake Account",
           alias: "FA"
)
account_service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')

account_service.loop(account_service.rows_count) do |x|
  #create account alias
  account_name = x.get_column('aliasname')
  aliasname = x.get_column('aliasname')
  remote_uid = x.get_column('sap_id')
  Account.where(name: account_name).first_or_create do |accounts|
    accounts.remote_uid = remote_uid
    accounts.name = account_name
    accounts.alias = account_name.titlecase.split.map(&:first).join
  end
end

#create contacts
fakeAccount = Account.find_by_name("Fake Account")
company_contacts_service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')
is_active = [20,10]
contact_group = {"General" => 10,"Company Top Manager" => 20,"retailer" => 30,"ador" => 40,"vmi_group" => 50,"C-Form customer GROUP" => 60,"Manager" => 70}

company_contacts_service.loop(company_contacts_service.rows_count) do |x|

  if x.get_column('aliasname').present?
    account = Account.find_by_name(x.get_column('aliasname'))
  else
    account = fakeAccount
  end

  begin
    Contact.where(email: x.get_column('email').strip.downcase).first_or_create do |contact|
      contact.assign_attributes(
            account: account,
            remote_id: x.get_column('sap_id'),
            first_name: x.get_column('firstname') || 'fname',
            last_name: x.get_column('lastname'),
            prefix: x.get_column('prefix'),
            designation: x.get_column('designation'),
            telephone: x.get_column('telephone'),
            #role: x.get_column('account'),
            status: is_active[x.get_column('is_active').to_i],
            contact_group: contact_group[x.get_column('group')],
            password: 'abc123',
            password_confirmation: 'abc123'
        )
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "#{x.get_column('email')} skipped"
  end
end

#create companies
fakeAccount = Account.find_by_name("Fake Account")
company_service = Services::Shared::Spreadsheets::CsvImporter.new('companies.csv')
company_service.loop(company_service.rows_count) do |x|
  if x.get_column('aliasname').present?
    account = Account.find_by_name(x.get_column('aliasname'))
  else
    account = fakeAccount
  end

  company_type = { "Proprietorship" => 10, "Private Limited" => 20, "Contractor" => 30, "Trust" => 40, "Public Limited" => 50}
  priority = [10, 20]
  nature_of_business = { "Trading" => 10,"Manufacturer" => 20,"Dealer" => 30 }
  is_msme = {"N" => false, "Y" => true}
  urd = {"N" => false, "Y" => true}

  Company.where(name: x.get_column('cmp_name')).first_or_create do |company|

    inside_email = Overseer.find_by_email(x.get_column('inside_sales_email'))
    outside_email = Overseer.find_by_email(x.get_column('outside_sales_email'))
    manager_email = Overseer.find_by_email(x.get_column('manager_email'))
    payment_option = PaymentOption.find_by_name(x.get_column('default_payment_term'))
    industry = Industry.find_by_name(x.get_column('cmp_industry'))

    #default_contact = Contact.find_by_email(x.get_column('default_contact_email'))
    #default_company_contact = CompanyContact.find_in_batches(x.get_column('default_contact'))
    company.assign_attributes(
      account: account,
      industry: industry.present? ? industry : nil,
      remote_uid: x.get_column('cmp_id'),
      #default_company_contact:default_company_contact,
      default_payment_option_id: payment_option.present? ? payment_option.id : nil,
      #default_billing_address_id: x.get_column('default_billing'),
      #default_shipping_address_id: x.get_column('default_shipping'),
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
      tax_identifier: x.get_column('cmp_gst')
    )
  end
end

address_service = Services::Shared::Spreadsheets::CsvImporter.new('company_address.csv')

gst_type = {1 => 10, 2 => 20, 3 => 30, 4 => 40, 5 => 50, 6=> 60}
address_service.loop(address_service.rows_count) do |x|
  company = Company.find_by_name(x.get_column('cmp_name'))

  if x.get_column('country') == "IN" && company.present?
    Address.create!(
        company: company,
        name: company.name,
        gst:x.get_column('gst_num'),
        country_code:x.get_column('country'),
        state: AddressState.find_by_name(x.get_column('state_name')),
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
        gst_type:gst_type[x.get_column('gst_type')]
    )
  elsif company.present?
    Address.create!(
        company: company,
        name: company.name,
        gst:x.get_column('gst_num'),
        country_code:x.get_column('country'),
        state: AddressState.find_by_name(x.get_column('state_name')),
        state_name: x.get_column('state_name'),
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
        gst_type:gst_type[x.get_column('gst_type')]
    )
  end
end

Brand.all.each do |brand|
  suppliers = RandomRecords.for(Company, [*1..5].sample)
  suppliers.each do |supplier|
    brand.brand_suppliers.create!(supplier: supplier)
  end
end

abrasives = ::Category.create!(name: 'Abrasives', tax_code: RandomRecord.for(TaxCode) )
abrasives.children.create!([
                               {name: 'Abrasive Accessories', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Bands and Rolls', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Discs and Belts', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Hand Pads and Sponges', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Mounting Points', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Polishing', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Sandpaper', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Sharpening Stones', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Tumblers and Accessories', tax_code: RandomRecord.for(TaxCode)},
                               {name: 'Wheels', tax_code: RandomRecord.for(TaxCode)},
                           ])

abrasives.children.first.children.create!([
                                              {name: 'Abrasive Mandrels', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Abrasive Pads', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Abrasive Stars', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Abrasive Test Kits', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Assemblies', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Expanding Drums', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Face Plates, Hubs', tax_code: RandomRecord.for(TaxCode)},
                                              {name: 'Pad Holder', tax_code: RandomRecord.for(TaxCode)},
                                          ])

cleaning = ::Category.create(name: 'Cleaning Equipment', tax_code: RandomRecord.for(TaxCode))
cleaning.children.create([
                             {name: 'Furniture Maintenance', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Mops and Cleaning Accessories', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Personal Care', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Toilet Equipment', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Trash Bags', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Wiping', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Brooms and Accessories', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Chemicals', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Containers', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Equipment', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Flooring Accessories', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Flooring Equipment and Accessories', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Janitorial Equipment', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Mops and Accessories', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Odor Control', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Paper Products', tax_code: RandomRecord.for(TaxCode)},
                             {name: 'Recycling Equipment', tax_code: RandomRecord.for(TaxCode)},
                         ])

RandomRecords.for(Category.all, 10).each do |category|
  suppliers = RandomRecords.for(Company, [*2..5].sample)
  suppliers.each do |supplier|
    category.category_suppliers.create!(supplier: supplier)
  end
end


100.times do
  Product.create!(
      name: Faker::Commerce.product_name,
      sku: ['BM', rand(5..300000) + 100000].join,
      brand: RandomRecord.for(Brand),
      category: RandomRecord.for(Category)
  )
end


Product.all.each do |product|
  suppliers = RandomRecords.for(Company, [*1..3].sample)
  suppliers.each do |supplier|
    product.product_suppliers.create!(supplier: supplier)
  end
end

Product.all.each do |product|
  suppliers = RandomRecords.for(Company, [*1..3].sample)
  # suppliers.each do |supplier|
  #   product.product_suppliers.create!(supplier: supplier)
  # end

  product.tax_code = RandomRecord.for(TaxCode)

  Faker::Number.between(1, 4).times do
    ProductComment.create!(
        product: product,
        message: Faker::HarryPotter.quote,
        overseer: RandomRecord.for(Overseer)
    )
  end


  ProductApproval.create!(
      product: product,
      comment: product.comments.last,
      overseer: RandomRecord.for(Overseer)
  )
end

Account.all.each do |account|
  5.times do
    contact = RandomRecord.for(Contact)
    company = RandomRecord.for(Company)
    products = RandomRecords.for(Product.all, 5)
    i = Inquiry.create!(
        contact: contact,
        company: company,
        billing_address: RandomRecord.for(company.addresses),
        shipping_address: RandomRecord.for(company.addresses),
    #comments: Faker::Lorem.paragraph_by_chars(256, false)
    )

    products.each do |product|
      i.inquiry_products.create!(product_id: product.id, quantity: 1, sr_no: 1)
    end

    i.inquiry_products.each do |inquiry_product|
      suppliers = RandomRecords.for(Company, [*1..3].sample)
      suppliers.each do |supplier|
        inquiry_product.inquiry_product_suppliers.create!(inquiry_product_id: inquiry_product.id, supplier_id: supplier.id, unit_cost_price: Faker::Commerce.price(100, 10000))
      end

    end

    i.save
  end
end

#
# Product approvals
# Inquiry.last.products.each do |p| p.create_approval(:comments => Faker::Lorem.sentence) if p.not_approved?; end
# RandomRecords.for(Product.not_approved, 20).each do |p|
#   p.create_approval(:comments => Faker::Lorem.sentence)
# end

# Product.all.each do |p| p.destroy; end
# InquiryImport.all.each do |i| i.destroy; end
