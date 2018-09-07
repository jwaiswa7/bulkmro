service = Services::Shared::Spreadsheets::CsvImporter.new('tax_codes.csv')
service.loop(100) do |x|
  TaxCode.create!(code: x.get_column('Code'), description: x.get_column('Description'))
end

states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and Kashmir',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
]

states.each do |state|
  AddressState.create(name: state)
end

groups = [
  'General',
  'Company',
  'Top Manager',
  'Retailer',
  'Ador',
  'VMI Group',
  'C-form Customer group',
  'Manager'
]

groups.each do |group|
  Group.create(name: group)
end

industries = [
    'Transport',
    'Telecom',
    'Technology',
    'Steel',
    'Shipbuilding',
    'Power',
    'Pharma',
    'Oil & Gas',
    'Mining',
    'Media',
    'Manufacturing',
    'Hospitality',
    'FMCG',
    'Electronics',
    'Education',
    'Defense',
    'Construction',
    'Chemical',
    'Banking',
    'Automotive',
    'Agriculture',
    'Aerospace'
]

industries.each do |industry|
  Industry.create(name: industry)
end

Overseer.create!(
    :first_name => 'Ashwin',
    :last_name => 'Goyal',
    :email => 'ashwin.goyal@bulkmro.com',
    :password => 'abc123',
    :password_confirmation => 'abc123'
)


devang = Overseer.create!(first_name: 'Devang', :last_name => 'Shah', role: :sales, :email => 'devang.shah@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123')
lavanya = Overseer.create!(first_name: 'Lavanya', :last_name => 'Jamma', role: :sales, :email => 'lavanya.j@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: devang)
Overseer.create!(first_name: 'Jeetendra', :last_name => 'Sharma', role: :sales, :email => 'jeetendra.sharma@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: lavanya)
Overseer.create!(first_name: 'Abid', :last_name => 'Shaikh', role: :sales, :email => 'abid.shaikh@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: lavanya)


PaymentOption.create!(name: 'Net 30')
PaymentOption.create!(name: 'Net 60')
PaymentOption.create!(name: 'Net 90')

ril = Account.create!(name: 'Reliance Industries Limited', alias: 'RIL')
[
    'Reliance Retail',
    'Reliance Life Sciences',
    'Reliance Institute of Life Sciences (RILS)',
    'Reliance Logistics',
    'Reliance Clinical Research Services (RCRS)',
    'Reliance Solar',
    'Relicord',
    'Reliance Jio Infocomm Limited (RJIL)',
    'Reliance Industrial Infrastructure Limited (RIIL)',
    'LYF',
    'Network 18'
].each do |name|
  ril.companies.create!(
      name: name,
      default_payment_option: RandomRecord.for(PaymentOption),
      industry: RandomRecord.for(Industry),
      tax_identifier: Faker::Company.polish_taxpayer_identification_number
  )
end

ge = Account.create!(name: 'General Electric', alias: 'GE')
[
    'CFM International',
    'Engine Alliance',
    'GE Aviation Systems',
    'GE Capital',
    'GE Capital Rail Services (Europe)',
    'GE Appliances',
    'GE Digital',
    'GE Power',
    'GE Global Research',
    'GE Hitachi Nuclear Energy',
    'GE Lighting',
    'GE Power Conversion',
    'GE Renewable Energy',
    'GE Security',
    'GE Ventures',
    'GE Automation & Controls',
    'Genesis Lease',
    'GE Jenbacher',
    'GE Technology Infrastructure',
    'Thomson-Houston Electric Company',
    'Tungsram'
].each do |name|
  ge.companies.create!(
      name: name,
      default_payment_option: RandomRecord.for(PaymentOption),
      industry: RandomRecord.for(Industry),
      tax_identifier: Faker::Company.polish_taxpayer_identification_number
  )
end

Account.all.each do |account|
  5.times do
    account.contacts.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, :email => Faker::Internet.email, :password => 'abc123', :password_confirmation => 'abc123', :group_id => 1)
  end
end

Company.all.each do |company|
  # Add company_contacts
  RandomRecords.for(company.account.contacts, [*1..5].sample).each do |contact|
    company.company_contacts.create!(:contact => contact)
  end

  # Add addresses
  [*1..3].sample.times do
    company.addresses.create!(
        name: Faker::Address.community,
        state: RandomRecord.for(AddressState),
        state_name: Faker::Address.state,
        city_name: Faker::Address.city,
        country_code: Faker::Address.country_code,
        street1: Faker::Address.street_address,
        street2: Faker::Address.secondary_address,
        pincode: Faker::Address.zip_code
    )
  end
end

10.times do
  Brand.create!(name: Faker::Company.name)
end

Brand.all.each do |brand|
  suppliers = RandomRecords.for(Company, [*1..5].sample)
  suppliers.each do |supplier|
    brand.brand_suppliers.create!(supplier: supplier)
  end
end

abrasives = ::Category.create!(name: 'Abrasives')
abrasives.children.create!([
                               { name: 'Abrasive Accessories', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Bands and Rolls', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Discs and Belts', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Hand Pads and Sponges', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Mounting Points', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Polishing', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Sandpaper', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Sharpening Stones', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Tumblers and Accessories', tax_code: RandomRecord.for(TaxCode) },
                               { name: 'Wheels', tax_code: RandomRecord.for(TaxCode) },
                           ])

abrasives.children.first.children.create!([
                                     { name: 'Abrasive Mandrels', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Abrasive Pads', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Abrasive Stars', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Abrasive Test Kits', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Assemblies', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Expanding Drums', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Face Plates, Hubs', tax_code: RandomRecord.for(TaxCode) },
                                     { name: 'Pad Holder', tax_code: RandomRecord.for(TaxCode) },
                                 ])

cleaning = ::Category.create(name: 'Cleaning Equipment')
cleaning.children.create([
                              { name: 'Furniture Maintenance', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Mops and Cleaning Accessories', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Personal Care', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Toilet Equipment', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Trash Bags', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Wiping', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Brooms and Accessories', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Chemicals', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Containers', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Equipment', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Flooring Accessories', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Flooring Equipment and Accessories', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Janitorial Equipment', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Mops and Accessories', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Odor Control', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Paper Products', tax_code: RandomRecord.for(TaxCode) },
                              { name: 'Recycling Equipment', tax_code: RandomRecord.for(TaxCode) },
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

Account.all.each do |account|
  5.times do
    contact = RandomRecord.for(account.contacts)
    company = RandomRecord.for(contact.companies)
    # products = RandomRecords.for(Product.all, 5)
    i = Inquiry.new(
      contact: contact,
      company: company,
      billing_address: RandomRecord.for(company.addresses),
      shipping_address: RandomRecord.for(company.addresses),
      comments: Faker::Lorem.paragraph_by_chars(256, false)
    )

    # products.each do |product|
    #   i.inquiry_products.build(product_id: product.id, quantity: 1)
    # end

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
