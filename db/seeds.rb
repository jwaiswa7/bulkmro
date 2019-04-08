# MeasurementUnit.create([
#                            {name: 'EA'},
#                            {name: 'SET'},
#                            {name: 'PK'},
#                            {name: 'KG'},
#                            {name: 'M'},
#                            {name: 'FT'},
#                            {name: 'Pair'},
#                            {name: 'PR'},
#                            {name: 'BOX'},
#                            {name: 'LTR'},
#                            {name: 'LT'},
#                            {name: 'MTR'},
#                            {name: 'ROLL'},
#                            {name: 'Nos'},
#                            {name: 'PKT'},
#                            {name: 'REEL'},
#                            {name: 'FEET'},
#                            {name: 'Meter'},
#                            {name: '"1 ROLL"'},
#                            {name: 'ml'},
#                            {name: 'MAT'},
#                            {name: 'LOT'},
#                            {name: 'No'},
#                            {name: 'RFT'},
#                            {name: 'Bundle'},
#                            {name: 'NPkt'},
#                            {name: 'Metre'},
#                            {name: 'CAN'},
#                            {name: 'SQ.Ft'},
#                            {name: 'BOTTLE'},
#                            {name: 'BOTTEL'},
#                            {name: '"CUBIC METER"'},
#                            {name: 'PC'},
#                        ])
#
# service = Services::Shared::Spreadsheets::CsvImporter.new('hsncodes.csv')
# service.loop(100) do |x|
#   TaxCode.create!(
#       remote_uid: x.get_column('internal_key'),
#       chapter: x.get_column('chapter'),
#       code: x.get_column('hsn').gsub!('.', ''),
#       description: x.get_column('description'),
#       is_service: x.get_column('is_service') == 'NULL' ? false : true,
#       tax_percentage: x.get_column('tax_code').match(/\d+/)[0].to_f
#   )
# end
#
# service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
# service.loop(500) do |x|
#   # puts x.get_column('value')
#   Brand.where(name: x.get_column('value')).first_or_create do |brand|
#     brand.legacy_id = x.get_column('option_id')
#   end
# end
#
#
# service = Services::Shared::Spreadsheets::CsvImporter.new('categories.csv')
# service.loop(500) do |x|
#   if (x.get_column('id') != "1" && x.get_column('id') != "2")
#     # puts "#{x.get_column('id')}"
#     tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code')) if (x.get_column('hsn_code').present?)
#     parent = Category.find_by_remote_uid(x.get_column('parent_id')) if (x.get_column('parent_id') != "2" && x.get_column('parent_id') != nil)
#     Category.create!(
#         remote_uid: x.get_column('id'),
#         tax_code_id: (tax_code.present? ? tax_code.id : TaxCode.default.id),
#         parent_id: (parent.present? ? parent.id : nil),
#         name: x.get_column('name'),
#         description: x.get_column('description'),
#         legacy_id: x.get_column('id')
#     )
#   end
# end
#
#
# LeadTimeOption.create!([
#                            {name: "2-3 DAYS", min_days: 2, max_days: 3},
#                            {name: "1 WEEK", min_days: 7, max_days: 7},
#                            {name: "8-10 DAYS", min_days: 8, max_days: 10},
#                            {name: "1-2 WEEKS", min_days: 7, max_days: 14},
#                            {name: "2 WEEKS", min_days: 14, max_days: 14},
#                            {name: "2-3 WEEK", min_days: 14, max_days: 21},
#                            {name: "3 WEEKS", min_days: 21, max_days: 21},
#                            {name: "3-4 WEEKS", min_days: 21, max_days: 28},
#                            {name: "4 WEEKS", min_days: 28, max_days: 28},
#                            {name: "5 WEEKS", min_days: 35, max_days: 35},
#                            {name: "4-6 WEEKS", min_days: 28, max_days: 42},
#                            {name: "6-8 WEEKS", min_days: 42, max_days: 56},
#                            {name: "8 WEEKS", min_days: 56, max_days: 56},
#                            {name: "6-10 WEEKS", min_days: 42, max_days: 70},
#                            {name: "10-12 WEEKS", min_days: 70, max_days: 84},
#                            {name: "12-14 WEEKS", min_days: 84, max_days: 98},
#                            {name: "14-16 WEEKS", min_days: 98, max_days: 112},
#                            {name: "MORE THAN 14 WEEKS", min_days: 98, max_days: nil},
#                            {name: "60 days from the date of order for 175MT, and 60 days for remaining from the date of call", min_days: 60, max_days: 120}
#                        ])
#
# Currency.create!([
#                      {name: 'USD', conversion_rate: 71.59},
#                      {name: 'INR', conversion_rate: 1},
#                      {name: 'EUR', conversion_rate: 83.85},
#                  ])
#
# states = [
#     'Andhra Pradesh',
#     'Arunachal Pradesh',
#     'Assam',
#     'Bihar',
#     'Chhattisgarh',
#     'Goa',
#     'Gujarat',
#     'Haryana',
#     'Himachal Pradesh',
#     'Jammu and Kashmir',
#     'Jharkhand',
#     'Karnataka',
#     'Kerala',
#     'Madhya Pradesh',
#     'Maharashtra',
#     'Manipur',
#     'Meghalaya',
#     'Mizoram',
#     'Nagaland',
#     'Odisha',
#     'Punjab',
#     'Rajasthan',
#     'Sikkim',
#     'Tamil Nadu',
#     'Telangana',
#     'Tripura',
#     'Uttar Pradesh',
#     'Uttarakhand',
#     'West Bengal',
#     'Delhi'
# ]
#
# states.each do |state|
#   AddressState.create(name: state)
# end
#
# industries = [
#     'Transport',
#     'Telecom',
#     'Technology',
#     'Steel',
#     'Shipbuilding',
#     'Power',
#     'Pharma',
#     'Oil & Gas',
#     'Mining',
#     'Media',
#     'Manufacturing',
#     'Hospitality',
#     'FMCG',
#     'Electronics',
#     'Education',
#     'Defense',
#     'Construction',
#     'Chemical',
#     'Banking',
#     'Automotive',
#     'Agriculture',
#     'Aerospace'
# ]
#
# industries.each do |industry|
#   Industry.create(name: industry)
# end
#
# Overseer.create!(
#     :first_name => 'Ashwin',
#     :last_name => 'Goyal',
#     :email => 'ashwin.goyal@bulkmro.com',
#     :password => 'abc123',
#     :password_confirmation => 'abc123'
# )
#
#
# devang = Overseer.create!(first_name: 'Devang', :last_name => 'Shah', role: :sales, :email => 'devang.shah@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123')
# lavanya = Overseer.create!(first_name: 'Lavanya', :last_name => 'Jamma', role: :sales, :email => 'lavanya.j@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: devang)
# Overseer.create!(first_name: 'Jeetendra', :last_name => 'Sharma', role: :sales, :email => 'jeetendra.sharma@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: lavanya)
# Overseer.create!(first_name: 'Abid', :last_name => 'Shaikh', role: :sales, :email => 'abid.shaikh@bulkmro.com', :password => 'abc123', :password_confirmation => 'abc123', parent: lavanya)
#
#
# PaymentOption.create!(name: 'Net 30')
# PaymentOption.create!(name: 'Net 60')
# PaymentOption.create!(name: 'Net 90')
#
# ril = Account.create!(name: 'Reliance Industries Limited', alias: 'RIL')
# =begin
# [
#     'Reliance Retail',
#     'Reliance Life Sciences',
#     'Reliance Institute of Life Sciences (RILS)',
#
#     'Reliance Logistics',
#     'Reliance Clinical Research Services (RCRS)',
#     'Reliance Solar',
#     'Relicord',
#     'Reliance Jio Infocomm Limited (RJIL)',
#     'Reliance Industrial Infrastructure Limited (RIIL)',
#     'LYF',
#     'Network 18'
#
# ].each do |name|
#   ril.companies.create!(
#       name: name,
#       default_payment_option: RandomRecord.for(PaymentOption),
#       industry: RandomRecord.for(Industry),
#       tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#       )
# end
# =end
#
# ge = Account.create!(name: 'General Electric', alias: 'GE')
# =begin
# [
#     'CFM International',
#     'Engine Alliance',
#     'GE Aviation Systems',
#     'GE Capital',
#     'GE Capital Rail Services (Europe)',
#     'GE Appliances',
#
#     'GE Digital',
#     'GE Power',
#     'GE Global Research',
#     'GE Hitachi Nuclear Energy',
#     'GE Lighting',
#     'GE Power Conversion',
#     'GE Renewable Energy',
#     'GE Security',
#     'GE Ventures',
#     'GE Automation & Controls',
#     'Genesis Lease',
#     'GE Jenbacher',
#     'GE Technology Infrastructure',
#     'Thomson-Houston Electric Company',
#     'Tungsram'
#
# ].each do |name|
#   ge.companies.create!(
#       name: name,
#       default_payment_option: RandomRecord.for(PaymentOption),
#       industry: RandomRecord.for(Industry),
#       tax_identifier: Faker::Company.polish_taxpayer_identification_number
#   )
# end
# =end
#
# Company.create!([
#                     {
#                         name: "Lift Arts",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Lift Arts", alias: "LIFT ARTS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Bhavesh Fastners",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Bhavesh Fastners", alias: "BHAVESH FASTNERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "J.D. Sales Corporation",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "J.D. Sales Corporation", alias: "J.D. SALES CORPORATION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "P. M. Bhimani Orgochem Pvt. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "P. M. Bhimani Orgochem Pvt. Ltd.", alias: "P. M. BHIMANI ORGOCHEM PVT. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Embassy Office Automation",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Embassy Office Automation", alias: "EMBASSY OFFICE AUTOMATION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Aim Safety",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Aim Safety", alias: "AIM SAFETY"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Bagadia Industrial Fasteners",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Bagadia Industrial Fasteners", alias: "BAGADIA INDUSTRIAL FASTENERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Empire Enterprises",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Empire Enterprises", alias: "EMPIRE ENTERPRISES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Ethos Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Ethos Ltd.", alias: "ETHOS LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Evergreen Sales",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Evergreen Sales", alias: "EVERGREEN SALES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Ferreterro India Pvt. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Ferreterro India Pvt. Ltd.", alias: "FERRETERRO INDIA PVT. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Jupiter Traders",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Jupiter Traders", alias: "JUPITER TRADERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Kohinoor Paints Mart",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Kohinoor Paints Mart", alias: "KOHINOOR PAINTS MART"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Kudrati Power Tools and Hardware",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Kudrati Power Tools and Hardware", alias: "KUDRATI POWER TOOLS AND HARDWARE"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "MrDhruv Shah",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "MrDhruv Shah", alias: "MRDHRUV SHAH"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Pragati Hi-Tech Engineers",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Pragati Hi-Tech Engineers", alias: "PRAGATI HI-TECH ENGINEERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Shreenathji Welding And Safety Pvt. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Shreenathji Welding And Safety Pvt. Ltd.", alias: "SHREENATHJI WELDING AND SAFETY PVT. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#
#                     {
#                         name: "Bombay Safety Care",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Bombay Safety Care", alias: "BOMBAY SAFETY CARE"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "3M India Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "3M India Ltd.", alias: "3M INDIA LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "S.P. Engineers",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "S.P. Engineers", alias: "S.P. ENGINEERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Techsys Automation",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Techsys Automation", alias: "TECHSYS AUTOMATION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Ringfeder Power Transmission",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Ringfeder Power Transmission", alias: "RINGFEDER POWER TRANSMISSION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Choudhary Enterprise",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Choudhary Enterprise", alias: "CHOUDHARY ENTERPRISE"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Godrej and Boyce Mfg Co. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Godrej and Boyce Mfg Co. Ltd.", alias: "GODREJ AND BOYCE MFG CO. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Archtech Automation",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Archtech Automation", alias: "ARCHTECH AUTOMATION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Mihir Enterprises",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Mihir Enterprises", alias: "MIHIR ENTERPRISES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Watson-Marlow India Pvt. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Watson-Marlow India Pvt. Ltd.", alias: "WATSON-MARLOW INDIA PVT. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Belimo Actuators India Pvt. Ltd.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Belimo Actuators India Pvt. Ltd.", alias: "BELIMO ACTUATORS INDIA PVT. LTD."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Arihant Enterprise",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Arihant Enterprise", alias: "ARIHANT ENTERPRISE"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Popatlal and Co",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Popatlal and Co", alias: "POPATLAL AND CO"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Hridya Enterprises",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Hridya Enterprises", alias: "HRIDYA ENTERPRISES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Krishna Enterprises",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Krishna Enterprises", alias: "KRISHNA ENTERPRISES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Komal Scientific Co.",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Komal Scientific Co.", alias: "KOMAL SCIENTIFIC CO."}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Al Technologies",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Al Technologies", alias: "AL TECHNOLOGIES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Samruddhi Industries",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Samruddhi Industries", alias: "SAMRUDDHI INDUSTRIES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Manlon Polymers",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Manlon Polymers", alias: "MANLON POLYMERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Sundheshwari Steel Corporation",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Sundheshwari Steel Corporation", alias: "SUNDHESHWARI STEEL CORPORATION"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Safex Systems",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Safex Systems", alias: "SAFEX SYSTEMS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Varay Image Runners",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Varay Image Runners", alias: "VARAY IMAGE RUNNERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Nandini Steel",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Nandini Steel", alias: "NANDINI STEEL"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Innovative Technologies",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Innovative Technologies", alias: "INNOVATIVE TECHNOLOGIES"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "Modern Traders",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "Modern Traders", alias: "MODERN TRADERS"}),
#                         is_supplier: true,
#                         is_customer: false
#                     },
#                     {
#                         name: "J.K.Knitwear",
#                         default_payment_option: RandomRecord.for(PaymentOption),
#                         industry: RandomRecord.for(Industry),
#                         tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                         account: Account.find_or_create_by({name: "J.K.Knitwear", alias: "J.K.KNITWEAR"}),
#                         is_supplier: true,
#                         is_customer: false
#
#                     },
#
#                 ])
#
# Company.create!(
#     [
#         {
#             name: "Cummins India Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Applied Materials India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "AMAT", alias: "AMAT"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cipla Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cipla", alias: "CIPLA"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Alstom Bharat Forge Power Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Alstom", alias: "ALSTOM"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Emission Solutions INC",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Fuel Systems India",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Generator Technologies India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Technical Center India",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Technologies India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Cummins Turbo Technologies",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Cummins", alias: "CUMMINS"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "DHL Supply Chain India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "DHL", alias: "DHL"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Emerson Innovation Center",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Emerson", alias: "EMERSON"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Emerson Process Management Chennai Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Emerson", alias: "EMERSON"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE Diesel Locomotive Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE India Industrial Pvt. Ltd. (GE Energy Connections-SRGI)",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Wipro GE Healthcare Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE India Industrial Pvt. Ltd. (Division: JFWTC)",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE Infrastructure Transportation",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE Oil and Gas (Measurement and Control Advanced Systek)",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE Power India Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "GE Transportation Systems",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "General Electric", alias: "GE"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Henkel Adhesive Technologies India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Henkel", alias: "HENKEL"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Henkel Anand India Pvt. Ltd.",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Henkel", alias: "HENKEL"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Indian Institute of Technology Bombay",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "IIT", alias: "IIT"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Indian Institute of Technology Delhi",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "IIT", alias: "IIT"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "INS Hansa",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Indian Navy", alias: "INDIAN NAVY"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Material Organization Karwar",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Indian Navy", alias: "INDIAN NAVY"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "INS Dega",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Indian Navy", alias: "INDIAN NAVY"}),
#             is_supplier: false,
#             is_customer: true
#         },
#         {
#             name: "Integrated Headquarters of Ministry of Defense (Navy)",
#             default_payment_option: RandomRecord.for(PaymentOption),
#             industry: RandomRecord.for(Industry),
#             tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#             account: Account.find_or_create_by({name: "Indian Navy", alias: "INDIAN NAVY"}),
#             is_supplier: false,
#             is_customer: true
#         },
#
#
#     ]
# )
#
#
# legitCompany = Company.create!([
#                                    {
#                                        name: "Bosch Ltd.",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#                                    },
#                                    {
#                                        name: "Deluxe Electrical Corporation",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                    {
#                                        name: "PV Lumens LLP",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                    {
#                                        name: "Skyking Instruments",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                    {
#                                        name: "Stanley Black and Decker India Pvt. Ltd.",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                    {
#                                        name: "Valisons and Co.",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                    {
#                                        name: "Vitronics (India)",
#                                        default_payment_option: RandomRecord.for(PaymentOption),
#                                        industry: RandomRecord.for(Industry),
#                                        tax_identifier: Faker::Company.polish_taxpayer_identification_number,
#                                        account: RandomRecord.for(Account),
#                                        is_supplier: true,
#                                        is_customer: false
#
#                                    },
#                                ])
#
#
# Account.all.each do |account|
#   5.times do
#     account.contacts.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, :email => Faker::Internet.email, :password => 'abc123', :password_confirmation => 'abc123')
#   end
# end
#
# Company.all.each do |company|
#   # Add company_contacts
#   RandomRecords.for(company.account.contacts, [*1..5].sample).each do |contact|
#     company.company_contacts.create!(:contact => contact)
#   end
#
#   # Add addresses
#   [*1..3].sample.times do
#     company.addresses.create!(
#         name: Faker::Address.community,
#         state: RandomRecord.for(AddressState),
#         state_name: Faker::Address.state,
#         city_name: Faker::Address.city,
#         country_code: Faker::Address.country_code,
#         street1: Faker::Address.street_address,
#         street2: Faker::Address.secondary_address,
#         pincode: Faker::Address.zip_code
#     )
#   end
# end
#
#
# state_codes = {
#     'AN' => 'Andaman and Nicobar Islands',
#     'AP' => 'Andhra Pradesh',
#     'AR' => 'Arunachal Pradesh',
#     'AS' => 'Assam',
#     'BR' => 'Bihar',
#     'CH' => 'Chandigarh',
#     'CT' => 'Chhattisgarh',
#     'DN' => 'Dadra and Nagar Haveli',
#     'DD' => 'Daman and Diu',
#     'DL' => 'Delhi',
#     'GA' => 'Goa',
#     'GJ' => 'Gujarat',
#     'HR' => 'Haryana',
#     'HP' => 'Himachal Pradesh',
#     'JK' => 'Jammu and Kashmir',
#     'JH' => 'Jharkhand',
#     'KA' => 'Karnataka',
#     'KL' => 'Kerala',
#     'LD' => 'Lakshadweep',
#     'MP' => 'Madhya Pradesh',
#     'MH' => 'Maharashtra',
#     'MN' => 'Manipur',
#     'ML' => 'Meghalaya',
#     'MZ' => 'Mizoram',
#     'NL' => 'Nagaland',
#     'OR' => 'Odisha, Orissa',
#     'PY' => 'Puducherry',
#     'PB' => 'Punjab',
#     'RJ' => 'Rajasthan',
#     'SK' => 'Sikkim',
#     'TN' => 'Tamil Nadu',
#     'TG' => 'Telangana',
#     'TR' => 'Tripura',
#     'UP' => 'Uttar Pradesh',
#     'UT' => 'Uttarakhand,Uttaranchal',
#     'WB' => 'West Bengal',
# }
#
# service = Services::Shared::Spreadsheets::CsvImporter.new('warehouses.csv')
# service.loop(200) do |x|
#   Warehouse.where(:name => x.get_column('Warehouse Name')).first_or_create do |warehouse|
#     warehouse.assign_attributes(
#         :remote_uid => x.get_column('Warehouse Code'),
#         :legacy_id => x.get_column('Warehouse Code'),
#         :location_uid => x.get_column('Location'),
#         :remote_branch_name => x.get_column('Warehouse Name'),
#         :remote_branch_code => x.get_column('Business Place ID'),
#         )
#
#     warehouse.build_address(
#         :street1 => x.get_column('Street'),
#         :street2 => x.get_column('Block'),
#         :pincode => x.get_column('Zip Code'),
#         :city_name => x.get_column('City'),
#         :country_code => x.get_column('Country'),
#         :state => AddressState.find_by_name(state_codes[x.get_column('State')])
#     )
#   end
# end
#
# Brand.all.each do |brand|
#   suppliers = RandomRecords.for(Company, [*1..5].sample)
#   suppliers.each do |supplier|
#     brand.brand_suppliers.create!(supplier: supplier)
#   end
# end
# =begin
#
# abrasives = ::Category.create!(name: 'Abrasives', tax_code: RandomRecord.for(TaxCode))
# abrasives.children.create!([
#                                {name: 'Abrasive Accessories', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Bands and Rolls', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Discs and Belts', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Hand Pads and Sponges', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Mounting Points', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Polishing', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Sandpaper', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Sharpening Stones', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Tumblers and Accessories', tax_code: RandomRecord.for(TaxCode)},
#                                {name: 'Wheels', tax_code: RandomRecord.for(TaxCode)},
#                            ])
#
# abrasives.children.first.children.create!([
#                                               {name: 'Abrasive Mandrels', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Abrasive Pads', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Abrasive Stars', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Abrasive Test Kits', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Assemblies', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Expanding Drums', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Face Plates, Hubs', tax_code: RandomRecord.for(TaxCode)},
#                                               {name: 'Pad Holder', tax_code: RandomRecord.for(TaxCode)},
#                                           ])
#
# cleaning = ::Category.create(name: 'Cleaning Equipment', tax_code: RandomRecord.for(TaxCode))
# cleaning.children.create([
#                              {name: 'Furniture Maintenance', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Mops and Cleaning Accessories', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Personal Care', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Toilet Equipment', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Trash Bags', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Wiping', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Brooms and Accessories', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Chemicals', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Containers', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Equipment', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Flooring Accessories', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Flooring Equipment and Accessories', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Janitorial Equipment', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Mops and Accessories', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Odor Control', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Paper Products', tax_code: RandomRecord.for(TaxCode)},
#                              {name: 'Recycling Equipment', tax_code: RandomRecord.for(TaxCode)},
#                          ])
# =end
#
# RandomRecords.for(Category.all, 10).each do |category|
#   suppliers = RandomRecords.for(Company.all.acts_as_supplier, [*2..5].sample)
#   suppliers.each do |supplier|
#     category.category_suppliers.create!(supplier: supplier)
#   end
# end
#
# legit = Product.create!(
#     [
#         {
#             name: 'FLUKE Digital Multimeter Size Palm – 106',
#             sku: 'BM9B5M4',
#             brand: Brand.find_or_create_by({name: 'Fluke'}),
#             category: RandomRecord.for(Category),
#             tax_code: RandomRecord.for(TaxCode)
#         },
#         {
#             name: '7PC 1/2 SQ. DR. HEX BIT SOCKET SET  MET',
#             sku: 'BM9J5C8',
#             brand: Brand.find_or_create_by({name: 'STANLEY'}),
#             category: RandomRecord.for(Category),
#             tax_code: RandomRecord.for(TaxCode)
#         },
#         {
#             name: 'Bosch GLM 500 Professional Laser Measure',
#             sku: 'BM9K8Y4',
#             brand: Brand.find_or_create_by({name: 'BOSCH'}),
#             category: RandomRecord.for(Category),
#             tax_code: RandomRecord.for(TaxCode)
#         },
#         {
#             name: 'STANLEY Heavy Duty Pipe Wrench Length 24" – 87-626-23',
#             sku: 'BM9N1E8',
#             brand: Brand.find_or_create_by({name: 'STANLEY'}),
#             category: RandomRecord.for(Category),
#             tax_code: RandomRecord.for(TaxCode)
#         }
#     ]
# )
#
#
# Product.create!(
#     [
#         {name: 'SS 316 ELBOW S10 SMLS 11/2', sku: 'BM9P7Q9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'IR Self Retracting Safety Knife', sku: 'BM9Y6Z4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'IR C Trap blade 5PK', sku: 'BM9W6E7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'SOFT LOOK CF 600 DD (CHEST FREEZER)(5210262) - FREEZER - VOLTAS', sku: 'BM9P9W9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '45 -75 -10 oil seal', sku: 'BM9Y6P5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '35 – 55 -10 oil seal', sku: 'BM9U2W8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '30- 52 -5 oil seal', sku: 'BM9S8L1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '25 – 35 – 7 oil seal', sku: 'BM9X7T3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Dosing Pump , Capacity: 0-6 lph at 4 kg /cm2', sku: 'BM9P9W4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: HSBC Workstation', sku: 'BM9U9B5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: State Bank Of India Workstation', sku: 'BM9W8U3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: Union Bank Of India Workstation', sku: 'BM9P8H5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: Canara Bank Workstation', sku: 'BM9Z6T2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: HDFC Workstation', sku: 'BM9R7E3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: Standard Chartered Workstation', sku: 'BM9R7U2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: Bank Of India Workstation', sku: 'BM9R4Y5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Break Fix: Bank Of Baroda Workstation', sku: 'BM9R2H4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Charges: Warehouse', sku: 'BM9Q2C6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Charges: Install / Move / Add / Change', sku: 'BM9V6H6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'TESTO make Digital Thermo Hygrometer along with Calibration Certificate-608-H1', sku: 'BM9P9W2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'AMFAH – Olimpia Splendid DehumidifierModel No.: Aquaria16 (16ltr)', sku: 'BM9P9W1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Floor Marking Tape, Colour Yellow ', sku: 'BM9F3F6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Green Floor Marking Tape', sku: 'BM9S6V9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Red Floor Marking Tape', sku: 'BM9R6L1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'BlackandYellow Floor Marking Tape', sku: 'BM9U7Y9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Pin up Board Acrylic Transparent Covered Blue velvet ', sku: 'BM9T8G1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Acrylic Letter Box', sku: 'BM9Z1L1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: ' Hologram Sticker', sku: 'BM9Y5B4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '5 Ton SPANSET (3 METRS) Endless', sku: 'BM9X8Y7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '5 Ton SPANSET (5 METRS) Endless', sku: 'BM9Z7V5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '32MM PPRC ELBOW', sku: 'BM9X1R8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '90MM X 1282MM UPVC PIPE SLEEV FILLING M', sku: 'BM9U2U9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Insttalation of HDPE and PPRC Pipe Work', sku: 'BM9P9V7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Blind flange SS304 40NB', sku: 'BM9Z2X8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'STUD SS304 M12X100MM , Stud with Nut washer', sku: 'BM9Z6T1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Duracell Batteries- Model  - Duracell Ultra – Lithium- CR17345', sku: 'BM9P9X9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'ELBOW CS SMLS SCH40 1', sku: 'BM9T3E9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Ms Flange CL 150 Sorf, Size 1', sku: 'BM9Y9Q1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'BTS Video Cinematography service', sku: 'BM9Q8E3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Photography for EL (service)', sku: 'BM9W2A4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Milky White Acrylic (Light Glow) 3MM Thickness', sku: 'BM9P9U1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Rubber hardness tester Shore - A hardness tester for rubber and soft plastics', sku: 'BM9P9X1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Push-in fitting QS-1/4-12 ', sku: 'BM9R2Y7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Push-in fitting QS-1/2-16', sku: 'BM9Z6T4', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Push-in fitting QSF-1/2-16-B', sku: 'BM9Z6M8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Push-in fitting QSF-1/2-12-B', sku: 'BM9V1Z5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Rexroth make  External gear pump , AZPW-21/004 RQR XX MB S0593 ,MNR No.: R983032269', sku: 'BM9P9U3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'COLIN Liquid', sku: 'BM9Z3S2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'DETTOL Antiseptic', sku: 'BM9Z1S3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Mop', sku: 'BM9S5N1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: ' Broom, Material Coconut', sku: 'BM9W3M7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: ' Floor Cleaning Wiper', sku: 'BM9P9L8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'SAVLON Antiseptic Liquid', sku: 'BM9X7G5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: ' Mop Stick', sku: 'BM9W7W1', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'LYSOL Liquid', sku: 'BM9U2N2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Nylon Braided Hose 1BLUE', sku: 'BM9V4F6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Roll to Roll Lamination Machine Size 27', sku: 'BM9W6T8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Rotary cutter 24inch', sku: 'BM9W1R3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'BULK MRO APPROVED Speed Mixer, Mixing Capacity 200 - 500 Gms - DAC 600.2 VAC-P', sku: 'BM9D7D9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Stand for DAC 400 – 1100 (Sr No 000005298)', sku: 'BM9P9U6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Main Fire Pump Elect Suc x Del. Size MM 80 x 65,Total Head Mtrs 55,Flow (LPM)/m3/hr,1600/96M3/hr,Motor KW/HP/RPM 30.0/40.0/2900,Pump Type End Suction,MOC Of Pump Std CI BRZ Imp,ST. Box Packing Std Gland Pack,Motor Spec. TEFC/Sq.Cage', sku: 'BM9X1W3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Jockey Pump Suc x Del. Size MM 50 x 25,Total Head Mtrs 70,Flow (LPM)/m3/hr,180/10.8m3/hr,Motor KW/HP/RPM 7.5/10.0/2900,Pump Type End Suction,MOC Of Pump Std CI BRZ Imp,ST. Box Packing Std Gland Pack,Motor Spec. TEFC/Sq.Cage', sku: 'BM9Q6R6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'iBall Pulse BT4', sku: 'BM9K5N6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'ADVU-25-25-A-P-A Compact cyl.(60001840)', sku: 'BM9Y5Q5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'CLR-32-20-R-P-A-B Lin/swiv. Clamp (60004313)', sku: 'BM9S7T6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'ADVU-25-50-A-P-A Compact cyl.(60001956)', sku: 'BM9W7B3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'ELECTRO MAGNETIC SUSPENSIONFOR BELT CONVEYORMake : JAYKRISHNAHeight of materiallayer : 300mm MaxSize Of Magnet : 1000mm(W) x 1200mm (L)x 725mm (Thick)Operating Height : 300mm APPPROX.Cooling : AIR Cooled.Power consumption of Magnet : 4.4', sku: 'BM9T3L5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Freight.', sku: 'BM00008', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Single Pole Lightguide – PN 5720', sku: 'BM9P9T8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'MS Security cabin 06x06x8.9ft with 03 windows 02 leds,01 fans, plug pointsFolding table for security person 15x48inside and fixed slab 12[outside] forinquiry window', sku: 'BM9P9V3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Manual Soap Dispenser 1000ml (Stainless Steel 304 Grade )', sku: 'BM9P9Y3', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Grip - on 928-07, 7 Inch Axial Grip W shaped Locking pliers', sku: 'BM9Z3H9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'SMOKE DETECTOR-SMOKE DETCTRDIAMETER-250 DIAMETER UOM-MMPART NO -MODELNO-EL-S11', sku: 'BM9V7T5', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '24 ex-fan 900rpm/1ph (almonard)', sku: 'BM9Y8U8', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: '15 ex-fan 1400rpm/1ph (almonard)', sku: 'BM9Q3W6', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'Scotch Brand Tape - Bundling Tape', sku: 'BM9P9T9', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'MB CAP ULTRA BUFFER MODULE 85468', sku: 'BM9P9T7', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)},
#         {name: 'INDOVAC Diaphragm Vacuum Pump, Flow Rate 15 Lpm, Vacuum 22” Hg, Pressure 25 Psig, Power 1/20 HP, Speed 1440 rpm, Weight 2.7 kg, Length 175 cm, Width 110 cm, Height 140 cm - VID-15 S', sku: 'BM9P9V2', brand: RandomRecord.for(Brand), category: RandomRecord.for(Category),
#          tax_code: RandomRecord.for(TaxCode)}
#     ])
#
#
# Product.all.each do |product|
#   suppliers = RandomRecords.for(Company.all.acts_as_supplier, [*1..3].sample)
#   suppliers.each do |supplier|
#     product.product_suppliers.create!(supplier: supplier)
#   end
# end
#
# Product.all.each do |product|
#   suppliers = RandomRecords.for(Company.all.acts_as_supplier, [*1..3].sample)
#   # suppliers.each do |supplier|
#   #   product.product_suppliers.create!(supplier: supplier)
#   # end
#
#   product.tax_code = RandomRecord.for(TaxCode)
#
#   Faker::Number.between(1, 4).times do
#     ProductComment.create!(
#         product: product,
#         message: Faker::HarryPotter.quote,
#         overseer: RandomRecord.for(Overseer)
#     )
#   end
#
#
#   ProductApproval.create!(
#       product: product,
#       comment: product.comments.last,
#       overseer: RandomRecord.for(Overseer)
#   )
# end
#
#
# Company.all.each do |company|
#   company.update_attributes(
#       :default_billing_address => RandomRecord.for(company.addresses),
#       :default_shipping_address => RandomRecord.for(company.addresses),
#       :default_company_contact => RandomRecord.for(company.company_contacts)
#   )
# end
#
#
# Account.all.each do |account|
#
#   2.times do
#     company = RandomRecord.for(Company.all.acts_as_customer)
#
#     products = RandomRecords.for(Product.all, 5)
#     i = Inquiry.create!(
#         contact: company.contacts.sample,
#         company: company,
#         billing_address: company.default_billing_address,
#         shipping_address: company.default_shipping_address,
#         inside_sales_owner: Overseer.all.sales.sample,
#         outside_sales_owner: Overseer.all.sales.sample,
#         sales_manager: Overseer.all.sales.sample,
#         bill_from: RandomRecord.for(Warehouse),
#         ship_from: RandomRecord.for(Warehouse)
#     #comments: Faker::Lorem.paragraph_by_chars(256, false)
#     )
#
#     legit.each_with_index do |product, index|
#       i.inquiry_products.create!(product_id: product.id, quantity: [*1..20].sample, sr_no: index + 1)
#     end
#
#     i.inquiry_products.each do |inquiry_product|
#       suppliers = legitCompany.sample([*1..3].sample)
#       suppliers.each do |supplier|
#         inquiry_product.inquiry_product_suppliers.create(inquiry_product_id: inquiry_product.id, supplier_id: supplier.id, unit_cost_price: Faker::Number.normal(((inquiry_product.product.id % 10) + 2) * 397, 10).round(2))
#
#       end
#
#     end
#     i.save
#   end
# end
#
# #
# # Product approvals
# # Inquiry.last.products.each do |p| p.create_approval(:comments => Faker::Lorem.sentence) if p.not_approved?; end
# # RandomRecords.for(Product.not_approved, 20).each do |p|
# #   p.create_approval(:comments => Faker::Lorem.sentence)
# # end
#
# # Product.all.each do |p| p.destroy; end
# # InquiryImport.all.each do |i| i.destroy; end
# #
# #
#
#
# # Overseer.find_by_email('ashwin.goyal@bulkmro.com').update_attributes(:role => Overseer.find_by_email('ashwin.goyal@bulkmro.com').sales? ? :admin : :sales)
# #
#
# account = Account.create(name: 'Ingersoll Rand (India) Ltd.', alias: 'IR')
# company = account.companies.create(
#     name: 'Ingersoll Rand (India) Ltd.'
# )
#
# contact = company.contacts.create(:account => account, :first_name => 'Ketan', :last_name => 'Joshi', email: 'Ketan.Joshi@irco.com', :password => 'abc123', :password_confirmation => 'abc123')
# address = company.addresses.create(:street1 => '21-30', street2: 'GIDC Estate Naroda', :country_code => 'IN', gst: '24AAACI3099Q1Z2', pincode: '382330', state_name: 'Ahmedabad')
# company.update_attributes(:default_company_contact => RandomRecord.for(company.company_contacts), :default_billing_address => address, :default_shipping_address => address, :default_payment_option => RandomRecord.for(PaymentOption), :inside_sales_owner => RandomRecord.for(Overseer.sales), :outside_sales_owner => Overseer.find_by_first_name('Abid'), :sales_manager => Overseer.find_by_first_name('Devang'))
#
#
# service = Services::Shared::Spreadsheets::CsvImporter.new('smtp_conf.csv')
# service.loop(200) do |x|
#   overseer = Overseer.find_by_email(x.get_column('email'))
#   overseer.update_attributes(:smtp_password => x.get_column('password')) if overseer.present?
# end
#
#
# Report.create!(name: 'ActivityReport', uid: 'activity_report')
#
#

# CustomerOrder.where(:online_order_number => nil).each do |co|
#   co.update_attributes!(:online_order_number => Services::Resources::Shared::UidGenerator.online_order_number(co.id))
# end
