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
    company = Company.find_by_name('FABTECH TECHNOLOGIES INTERNATIONAL LTD')
    if company.present?
      service.loop(20) do |row|
        o = Overseer.find('JkYhxe')
        name = row.get_column('Product_Description')
        puts name
        new_name = row.get_column('New_Description')
        puts new_name
        tax_code_file = row.get_column('Tax_Code')
        sku = row.get_column('BM_Number')
        brand_name = row.get_column('Brand')
        moq =row.get_column('MOQ')
        unit = row.get_column('UOM')
        customer_price = row.get_column('Bundle_Price')
        unit_price = row.get_column('Per_Unit_Price')
        customer_product = CustomerProduct.where(company_id: company.id).where('lower(name) = ? ', name.downcase).last
        puts '******************************'
        puts CustomerProduct.where(company_id: company.id).where('lower(name) = ? ', name.downcase)
        puts '******************************'

        if customer_product.blank?
          customer_product = CustomerProduct.where(company_id: company.id).where('sku = ? ', sku).last
        end
        puts '******************************'
        puts CustomerProduct.where(company_id: company.id).where('sku = ? ', sku).last
        puts '******************************'
        if customer_product.present?
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
          comment.message = "Approved on behalf of Subrata"
          comment.created_by = o
          comment.updated_by = o
          comment.save

          customer_product.product.create_approval(comment: comment, overseer: o)
          customer_product.product.save_and_sync
        end
      end
    end
  end

  def is_nil_error_for_product(condition, file_writer_obj, message)
    if condition.nil?
      file_writer_obj << message
    end
  end

  attr_accessor :product
end
