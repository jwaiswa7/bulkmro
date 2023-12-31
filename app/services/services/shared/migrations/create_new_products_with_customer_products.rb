class Services::Shared::Migrations::CreateNewProductsWithCustomerProducts < Services::Shared::BaseService
  def products_creation_customer_products
    file = "#{Rails.root}/tmp/testing.csv"
    column_headers = ['product_name', 'error_message']
    company = Company.find_by_name('FABTECH TECHNOLOGIES INTERNATIONAL LTD')
    product_ids = []
    if company.present?
      service = Services::Shared::Spreadsheets::CsvImporter.new('new_products_creation.csv', 'seed_files')

      CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
        service.loop do |product_row|
          product_name = product_row.get_column('Description')
          hsn = product_row.get_column('HSN_code').strip[0..3]
          brand = product_row.get_column('Make')
          mpn = product_row.get_column('Model')
          unit_of_measurement = product_row.get_column('UOM')
          customer_product_unit_price = product_row.get_column('Unit_Price')
          quantity = product_row.get_column('MOQ_of_UOM')

          if product_name.present?
            @product = Product.where(name: product_name).first_or_initialize do |pro|
              pro.tax_code = TaxCode.where('code LIKE ?', hsn).where(is_service: false).first || TaxCode.where(code: '62160010', is_service: false).first
              pro.brand = Brand.find_by_name(brand) || Brand.find_by_name('BULKMRO APPROVED')
              pro.mpn = mpn
              pro.category = Category.find(1)
              if Product.where(sku: pro.sku).present?
                pro.sku = Services::Resources::Shared::UidGenerator.product_sku([pro.sku])
              end
              pro.measurement_unit = MeasurementUnit.find_by_name(unit_of_measurement)
              is_nil_error_for_product(pro.tax_code, writer, ["#{pro.name}", "#{hsn} Tax Code is missing"])
              is_nil_error_for_product(pro.brand, writer, ["#{pro.name}", "#{brand} This brand is missing"])
              is_nil_error_for_product(pro.brand, writer, ["#{pro.name}", "#{pro.measurement_unit} This Unit Of Measurement is missing"])
            end
            if product.save!
              customer_product = company.customer_products.build(product_id: product.id,
                                                                 category: product.category, name: product.name, brand: product.brand, sku: product.sku, unit_selling_price: customer_product_unit_price, customer_price: customer_product_unit_price,
                                                                 moq: quantity, tax_code: product.tax_code, measurement_unit: product.measurement_unit
              )
              customer_product.save(validate: false)
            end
            product_ids << product.id
          end
        rescue => e
          writer << ["#{product.sku} - #{product_name}", "#{e.message}"]
          retry
        end
      end
    end
  end

  def update_company_customer_product
    service = Services::Shared::Spreadsheets::CsvImporter.new('updated_fabtech_list.csv', 'seed_files')
    company = Company.find('p7tpZ6')
    if company.present?
      error_message = []
      service.loop do |row|
        o = Overseer.find('JkYhxe')
        name = row.get_column('Product_Description')
        puts name
        new_name = row.get_column('New_Description')
        puts new_name
        tax_code_file = row.get_column('Tax_Code')
        sku = row.get_column('BM_Number')
        brand_name = row.get_column('Brand')
        moq = row.get_column('MOQ')
        unit = row.get_column('UOM')
        customer_price = row.get_column('Bundle_Price')
        unit_price = row.get_column('Per_Unit_Price')
        customer_product = CustomerProduct.where(company_id: company.id).where('lower(name) = ? ', name.downcase).last
        puts '******************************'
        puts CustomerProduct.where(company_id: company.id).where('lower(name) = ? ', name.downcase)
        puts '******************************'

=begin
          if customer_product.blank?
            customer_product = CustomerProduct.where(company_id: company.id).where('sku = ? ', sku).last
          end
=end
        puts '******************************'
        puts CustomerProduct.where(company_id: company.id).where('sku = ? ', sku).last
        puts '******************************'
        begin
          if customer_product.present? && row.get_column('SKU').blank?
            tax_code_data = TaxCode.where(code: tax_code_file, is_service: false).last
            tax_code = tax_code_data.present? ? tax_code_data : TaxCode.where('code like ? AND is_service = ?', "#{tax_code_file[0..3]}%", false).last
            brand = Brand.where('lower(name) = ? ', brand_name.downcase).last
            measurement_unit = MeasurementUnit.where('lower(name) = ?', unit.downcase).last
            customer_product.tax_code = tax_code
            customer_product.name = new_name
            customer_product.brand = brand
            customer_product.moq = moq
            customer_product.customer_price = customer_price
            customer_product.measurement_unit = measurement_unit
            customer_product.unit_selling_price = unit_price
            customer_product.product.tax_code = tax_code
            customer_product.product.brand = brand
            customer_product.product.name = new_name
            customer_product.product.save!
            customer_product.save!

            comment = ProductComment.new
            comment.product = customer_product.product
            comment.message = 'Approved on behalf of Subrata'
            comment.created_by = o
            comment.updated_by = o
            comment.save

            customer_product.product.create_approval(comment: comment, overseer: o)
            customer_product.product.save_and_sync
          end
        rescue => e
          error_message << [customer_product.product.sku, customer_product.product.name, e.message]
          next
        end
      end
      puts error_message
    end
  end

  def is_nil_error_for_product(condition, file_writer_obj, message)
    if condition.nil?
      file_writer_obj << message
    end
  end

  def update_brand_for_products
    company = Company.find('p7tpZ6')
    brand_for_sku = [
        {"BM9O0J2": 'PENTAGON FASTENERS'},
        {"BM9Y3C9": 'AAF'},
        {"BM9K1R2": 'FORTRAN'},
        {"BM9P4H0": 'FREEMAN'},
        {"BM9I7O5": 'FREEMAN'},
        {"BM9H7N7": 'FREEMAN'},
        {"BM9H6X3": 'JK FILES'},
        {"BM9W2D0": 'JK FILES'},
        {"BM9K7O4": 'JK FILES'},
        {"BM9I4L3": 'ROXELLO'},
        {"BM9S1J3": 'ROXELLO'},
        {"BM9O3T8": 'ROXELLO'},
        {"BM9V3T6": 'ROXELLO'},
        {"BM9K7A4": 'ROXELLO'},
        {"BM9U2V2": 'ROXELLO'},
        {"BM9U5A0": 'ROXELLO'},
        {"BM9X7Z9": 'ROXELLO'},
        {"BM9Y4O3": 'ROXELLO'},
        {"BM9B0P3": 'ROXELLO'},
        {"BM9S9I1": 'ROXELLO'},
        {"BM9W8Z9": 'ROXELLO'}
    ]
    if company.present?
      brand_for_sku.each do |value|
        customer_product = company.customer_products.where(sku: brand_for_sku.keys.first.to_s).first
        brand = Brand.where('lower(name) = ?', brand_for_sku.values.first.to_s.downcase).first
        product = Product.where(sku: brand_for_sku.keys.first.to_s).first
        if (customer_product.present? && brand.present?) || product.present?
          customer_product.brand = brand
          product.brand = brand
          customer_product.save
          product.save
        end
      end
    end
  end

  def update_customer_product_name
    service = Services::Shared::Spreadsheets::CsvImporter.new('customer_product_name_update.csv', 'seed_files')
    company = Company.find('p7tpZ6')
    customer_product_name = []
    cutomer_product_sku = []
    service.loop do |row|
      customer_product_sku = row.get_column('current_customer_product_sku')
      product_sku = row.get_column('old_product_sku')
      product_name = row.get_column('product_name_in_system')
      customer_product = company.customer_products.where(sku: customer_product_sku).last
      product = Product.where(sku: product_sku).last
      if customer_product.present? && product.present?
        customer_product_name << customer_product.name
        cutomer_product_sku << customer_product.sku
        customer_product.product = product
        customer_product.name = product_name || product.name
        customer_product.sku = product_sku || product.sku
        customer_product.save
      end
    end
    puts '************************************************'
    puts "Customer Product SKU : #{cutomer_product_sku}"
    puts '************************************************'
    puts "Customer Product Names : #{customer_product_name}"
    puts '************************************************'
  end

  def tax_code_export
    file = "#{Rails.root}/tmp/tax_codes_dump.csv"
    column_headers = ['code', 'chapter', 'tax_percentage', 'is_service', 'is_active']
    CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
      TaxCode.all.each do |tax_code|
        code = tax_code.code
        chapter = tax_code.chapter
        percentage = tax_code.tax_percentage.present? ? tax_code.tax_percentage.to_f : '0'
        is_service = tax_code.is_service
        is_active = tax_code.is_active
        writer << [code, chapter, percentage, is_service, is_active]
      end
    end
  end

  attr_accessor :product
end
