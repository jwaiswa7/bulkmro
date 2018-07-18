Overseer.create!(
    :first_name => 'Ashwin',
    :last_name => 'Goyal',
    :email => 'ashwin.goyal@bulkmro.com',
    :password => 'abc123',
    :password_confirmation => 'abc123'
)

PaymentOption.create!(name: 'Net 30')
PaymentOption.create!(name: 'Net 60')
PaymentOption.create!(name: 'Net 90')

ril = Account.create!(name: 'Reliance Industries Limited (RIL)')
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
      default_payment_option: RandomRecord.for(PaymentOption)
  )
end

ge = Account.create!(name: 'General Electric (GE)')
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
      default_payment_option: RandomRecord.for(PaymentOption)
  )
end

Account.all.each do |account|
  5.times do
    account.contacts.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
  end
end

Company.all.each do |company|
  # Add company_contacts
  RandomRecords.for(company.account.contacts, [*1..5].sample).each do |contact|
    company.company_contacts.create!(:contact => contact)
  end

  # Add addresses
  [*1..3].sample.times do
    company.addresses.create!(name: Faker::Address.community, street1: Faker::Address.street_address, street2: Faker::Address.secondary_address)
  end
end

10.times do
  Brand.create!(name: Faker::Company.name)
end

100.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    sku: ['BM', rand(5..300000) + 100000].join,
    brand: RandomRecord.for(Brand)
  )
end