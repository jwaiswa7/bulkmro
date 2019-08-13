class Services::Shared::Migrations::CreateNewProductsWithCustomerProducts < Services::Shared::BaseService
  def products_creation_customer_products
    file = "#{Rails.root}/tmp/testing.csv"
    column_headers = ['product_name', 'error_message']
    company = Company.find_by_name("FABTECH TECHNOLOGIES INTERNATIONAL LTD")
    product_ids = []
    if company.present?
      service = Services::Shared::Spreadsheets::CsvImporter.new('new_products_creation.csv', 'seed_files')

      CSV.open(file, 'w', write_headers: true, headers: column_headers) do |writer|
        service.loop do |product_row|
          begin
            product_name = product_row.get_column('Description')
            hsn = product_row.get_column('HSN_code').strip[0..3]
            brand = product_row.get_column('Make')
            mpn = product_row.get_column('Model')
            unit_of_measurement = product_row.get_column('UOM')
            customer_product_unit_price = product_row.get_column('Unit_Price')
            quantity = product_row.get_column('MOQ_of_UOM')

            if product_name.present?
              @product = Product.where(name: product_name).first_or_initialize do |pro|
                pro.tax_code = TaxCode.where('code LIKE ?', hsn).where(is_service: false).first || TaxCode.where(code: "62160010", is_service: false).first
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
                customer_product = company.customer_products.build({product_id: product.id,
                                                                    category: product.category, name: product.name, brand: product.brand, sku: product.sku, unit_selling_price: customer_product_unit_price, customer_price: customer_product_unit_price,
                                                                    moq: quantity, tax_code: product.tax_code
                                                                   })
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
  end

  def is_nil_error_for_product(condition, file_writer_obj, message)
    if condition.nil?
      file_writer_obj << message
    end
  end

  attr_accessor :product
end