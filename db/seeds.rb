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
service.loop(100) do |x|
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
=begin
    'Reliance Logistics',
    'Reliance Clinical Research Services (RCRS)',
    'Reliance Solar',
    'Relicord',
    'Reliance Jio Infocomm Limited (RJIL)',
    'Reliance Industrial Infrastructure Limited (RIIL)',
    'LYF',
    'Network 18'
=end
].each do |name|
  ril.companies.create!(
      name: name,
      default_payment_option: RandomRecord.for(PaymentOption),
      industry: RandomRecord.for(Industry),
      tax_identifier: Faker::Company.polish_taxpayer_identification_number,
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
=begin
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
=end
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
    account.contacts.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, :email => Faker::Internet.email, :password => 'abc123', :password_confirmation => 'abc123')
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
