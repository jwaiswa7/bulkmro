require 'csv'

class Services::Shared::Migrations::Migrations < Services::Shared::BaseService
  def initialize()
    overseers
    industries
    #states
    accounts
    brands
    tax_codes
    categories
    products
  end

  def overseers
    overseer_service = Services::Shared::Spreadsheets::CsvImporter.new('admin_users.csv')
    rows_count = overseer_service.rows_count
    overseer_service.loop(rows_count) do |x|
      o = Overseer.create!(
        first_name: x.get_column('firstname'),
        last_name: x.get_column('lastname'),
        email: x.get_column('email'),
        username: x.get_column('username'),
        password: "asdf12345",
        password_confirmation: "asdf12345",
        mobile: x.get_column('mobile'),
        designation: x.get_column('designation'),
        identifier: x.get_column('identifier'),
        geography: x.get_column('geography'),
        remote_sales_uid: x.get_column('sap_internal_code'),
        remote_emp_uid: x.get_column('employee_id')
        )
    end
    puts "Overseers"
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

  def states
    # states.csv file is missing
    # csv import code test for states not done yet.

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
  end

  def accounts
    accounts_service = Services::Shared::Spreadsheets::CsvImporter.new('accounts.csv')
    rows_count = accounts_service.rows_count
    accounts_service.loop(rows_count) do |x|
        i = Account.create!(
           remote_uid: x.get_column('sap_id'),
           name: x.get_column('aliasname')
        )
    end
    puts "Accounts"
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