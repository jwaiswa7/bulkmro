require 'csv'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  def initialize
    #overseers
    #measurement_unit
    #leadtime_option
    #currencies
    #states
    #payment_options
    #industries
    #accounts
    #contacts
    #companies
    #addresses
    #brands
    #tax_codes
    #categories
    #products
  end

  def addresses
    puts "Creating company addresses"
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
    puts "Done."
  end

  def companies
    puts "Creating companies"
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
    puts "Done."
  end

  def contacts
    puts "Creating account contacts"
    #create contacts
    fakeAccount = Account.find_by_name("Fake Account")
    company_contacts_service = Services::Shared::Spreadsheets::CsvImporter.new('company_contacts.csv')
    is_active = [20,10]
    contact_group = {"General" => 10,"Company Top Manager" => 20,"retailer" => 30,"ador" => 40,"vmi_group" => 50,"C-Form customer GROUP" => 60,"Manager" => 70}

    company_contacts_service.loop(company_contacts_service.rows_count) do |x|
      puts "#{x.get_column('sap_id')}"
      if x.get_column('aliasname').present?
        account = Account.find_by_name(x.get_column('aliasname'))
      else
        account = fakeAccount
      end

      begin
        Contact.where(email: x.get_column('email').strip.downcase).first_or_create do |contact|
          contact.assign_attributes(
              account: account,
              remote_uid: (x.get_column('sap_id') == "NULL" ? nil : x.get_column('sap_id')),
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
    puts "Done."
  end

  def accounts
    puts "Creating accounts..."
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
    puts "Done."
  end

  def payment_options
    puts "Creating payment options..."
    payment_term_service = Services::Shared::Spreadsheets::CsvImporter.new('payment_terms.csv')
    payment_term_service.loop(payment_term_service.rows_count) do |x|
      if x.get_column('value').present? && x.get_column('group_code').present?
        puts x.get_column('value')
        PaymentOption.where(name: x.get_column('value')).first_or_create do |payment_option|
          payment_option.assign_attributes(
              remote_uid: x.get_column('group_code')
          )
        end
      end
    end
    puts "Done."
  end

  def states
    puts "Creating country and states.."

    #Country and States
    state_service = Services::Shared::Spreadsheets::CsvImporter.new('states.csv')
    state_service.loop(state_service.rows_count) do |x|
      if x.get_column('default_name').present? && x.get_column('code').present? && x.get_column('region_id').present?
        puts x.get_column('default_name')
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
    puts "Done."
  end
  def currencies
    puts "Creating currencies.."
    Currency.create!([
                         { name: 'USD', conversion_rate: 71.59 },
                         { name: 'INR', conversion_rate: 1 },
                         { name: 'EUR', conversion_rate: 83.85 },
                     ])
    puts "Done."
  end

  def leadtime_option
    puts "Creating LeadTimeOption.."
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
    puts "Done."
  end


  Currency.create!([
                       { name: 'USD', conversion_rate: 71.59 },
                       { name: 'INR', conversion_rate: 1 },
                       { name: 'EUR', conversion_rate: 83.85 },
                   ])
  def measurement_unit
    puts "Creating Measurement Units.."
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
    puts "...Done"
  end

  def overseers

    puts "Creating overseers.."
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

    puts "Done"
  end

  def industries
    industries_service = Services::Shared::Spreadsheets::CsvImporter.new('industries.csv')
    rows_count = industries_service.rows_count
    industries_service.loop(rows_count) do |x|
        i = Industry.create!(
           remote_uid: x.get_column('industry_sap_id'),
           name: x.get_column('industry_name'),
           description: x.get_column('industry_description')
        )
    end
    puts "Industries"
  end

  def brands
    brands_service = Services::Shared::Spreadsheets::CsvImporter.new('brands.csv')
    rows_count = brands_service.rows_count
    brands_service.loop(rows_count) do |x|
      puts x.get_column('value')
      i = Brand.find_or_create_by!(
          name: x.get_column('value')
      )
    end
    puts "Brands"
  end

  def tax_codes
    tax_codes_service = Services::Shared::Spreadsheets::CsvImporter.new('hsn_codes.csv')
    rows_count = tax_codes_service.rows_count
    tax_codes_service.loop(rows_count) do |x|
      puts "#{x.get_column('idbmro_sap_hsn_mapping')}"
      puts "#{x.get_column('hsn')}"
      if (x.get_column('hsn') != "NULL" && x.get_column('hsn') != nil)
        TaxCode.create!(
            remote_uid: x.get_column('internal_key'),
            chapter: x.get_column('chapter'),
            code: x.get_column('hsn').gsub('.', ''),
            description: x.get_column('description'),
            is_service: x.get_column('is_service') == 'NULL' ? false : true,
            tax_percentage: x.get_column('tax_code').match(/\d+/)[0].to_f
        )
      end
    end
    puts "Tax Codes"
  end

  def categories
    categories_service = Services::Shared::Spreadsheets::CsvImporter.new('categories.csv')
    rows_count = categories_service.rows_count
    categories_service.loop(rows_count) do |x|
      if (x.get_column('id') != "1" && x.get_column('id') != "2")
        puts "#{x.get_column('id')}"
        tax_code = TaxCode.find_by_chapter(x.get_column('hsn_code')) if (x.get_column('hsn_code').present?)
        parent = Category.find_by_remote_uid(x.get_column('parent_id')) if (x.get_column('parent_id') != "2" && x.get_column('parent_id') != nil)
        i = Category.create!(
            remote_uid: x.get_column('id'),
            tax_code_id: (tax_code.present? ? tax_code.id : nil),
            parent_id: (parent.present? ? parent.id : nil ),
            name: x.get_column('name'),
            description: x.get_column('description')
        )
      end
    end
    puts "Categories"
  end

  def products
    products_service = Services::Shared::Spreadsheets::CsvImporter.new('products.csv')
    rows_count = products_service.rows_count
    products_service.loop(rows_count) do |x|
      puts "#{x.get_column('entity_id')}"
      brand = Brand.find_by_name(x.get_column('product_brand'))
      i = Product.create!(
          name: x.get_column('name'),
          brand: ( brand if (brand.present?) ),
          category_id: 1,
          sku: x.get_column('sku'),
          description: x.get_column('description'),
          meta_description: x.get_column('meta_description'),
          meta_keyword: x.get_column('meta_keyword'),
          meta_title: x.get_column('meta_title')
      )
    end
    puts "Products"
  end

end