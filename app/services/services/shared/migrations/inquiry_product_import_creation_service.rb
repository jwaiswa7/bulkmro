class Services::Shared::Migrations::InquiryProductImportCreationService < Services::Shared::BaseService
  def fetch_csv(filename, csv_data)
    overseer = Overseer.find(197)
    temp_file = File.open(Rails.root.join('tmp', filename), 'wb')

    begin
      temp_file.write(csv_data)
      temp_file.close
      overseer.file.attach(io: File.open(temp_file.path), filename: filename)
      overseer.save!
      puts Rails.application.routes.url_helpers.rails_blob_path(overseer.file, only_path: true)
    rescue => ex
      puts ex.message
    end
  end

  def build_inquiry_product(product, inquiry, sr_no, quantity)
    excel_import = inquiry.imports.build(import_type: :excel, overseer: Overseer.find(238))
    services = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)
    inquiry_product = inquiry.inquiry_products.where(product_id: product.id).last
    unless inquiry_product.present?
      inquiry_product = inquiry.inquiry_products.build(
          inquiry: inquiry,
          import: excel_import,
          product_id: product.id,
          sr_no: services.call(sr_no),
          quantity: quantity.to_i
      )
      inquiry_product.save
    end
  end

  def inquiry_product_52317_creation_service
    service = Services::Shared::Spreadsheets::CsvImporter.new('52317BayerProducts.csv', 'seed_files_3')
    products_with_issues = []
    inquiry = Inquiry.find_by_inquiry_number(52317)
    inquiry.update_attributes(status: 'Cross Reference')
    current_overseer = Overseer.find_by_id(238)

    column_headers = ['sku', 'name', 'message']
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|

      service.loop(nil) do |row|
        product_name = row.get_column('name').to_s
        mpn = row.get_column('mpn')
        sr_no = row.get_column('sr_no')
        quantity = row.get_column('quantity')
        brand = row.get_column('brand').to_s
        tax_code = row.get_column('tax_code').present? ? row.get_column('tax_code').to_s : nil
        is_service = row.get_column('is_service').present? && row.get_column('is_service').downcase == 'yes' ? true : false
        category = row.get_column('category_id').present? ? row.get_column('category_id') : nil
        tax_rate = row.get_column('tax_rate').present? ? row.get_column('tax_rate').to_f : nil
        brand_data = Brand.find_by_name(brand)
        if product_name.present?
          product = Product.where(name: product_name).last
          if product.present?
            build_inquiry_product(product, inquiry, sr_no, quantity)
          else
            product = Product.new(
                name: product_name,
                tax_code: tax_code.present? ? TaxCode.where('code LIKE ?', tax_code).first : nil,
                brand: brand_data.present? && brand_data.is_active ? brand_data : nil,
                mpn: mpn,
                tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
                category: category.present? ? Category.where(id: category, is_active: true).last : Category.find(5100),
                is_service: is_service,
            )
            if Product.where(sku: product.sku).present?
              product.sku = Services::Resources::Shared::UidGenerator.product_sku([product.sku])
            end
            if product.save
              build_inquiry_product(product, inquiry, sr_no, quantity)
              comment = product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
              product.create_approval(comment: comment, overseer: current_overseer)
              if product.approved?
                begin
                  product.save_and_sync
                rescue => e
                  writer << ["#{product.sku} - #{product_name}", "#{e.message}-Sync issue"]
                  next
                end
              end
            else
              products_with_issues << ["#{product.sku} - #{product_name}", "#{product.errors}}-active record issue"]
              writer << [product.sku, product.name, product.errors]
            end
          end
        end
      end
      writer
    end

    fetch_csv('sap_not_sync_product_52317.csv', csv_data)
    puts products_with_issues
  end

  def inquiry_product_52898_creation_service
    service = Services::Shared::Spreadsheets::CsvImporter.new('52898BayerProducts.csv', 'seed_files_3')
    products_with_issues = []
    inquiry = Inquiry.find_by_inquiry_number(52898)
    inquiry.update_attributes(status: 'Cross Reference')
    current_overseer = Overseer.find_by_id(238)

    column_headers = ['sku', 'name', 'message']
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|

      service.loop(nil) do |row|
        product_name = row.get_column('name').to_s
        mpn = row.get_column('mpn')
        sr_no = row.get_column('sr_no')
        quantity = row.get_column('quantity')
        brand = row.get_column('brand').to_s
        tax_code = row.get_column('tax_code').present? ? row.get_column('tax_code').to_s : nil
        is_service = row.get_column('is_service').present? && row.get_column('is_service').downcase == 'yes' ? true : false
        category = row.get_column('category_id').present? ? row.get_column('category_id') : nil
        tax_rate = row.get_column('tax_rate').present? ? row.get_column('tax_rate').to_f : nil
        brand_data = Brand.find_by_name(brand)
        if product_name.present?
          product = Product.where(name: product_name).last
          if product.present?
            build_inquiry_product(product, inquiry, sr_no, quantity)
          else
            product = Product.new(
                name: product_name,
                tax_code: tax_code.present? ? TaxCode.where('code LIKE ?', tax_code).first : nil,
                brand: brand_data.present? && brand_data.is_active ? brand_data : nil,
                mpn: mpn,
                tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
                category: category.present? ? Category.where(id: category, is_active: true).last : Category.find(5100),
                is_service: is_service,
                )
            if Product.where(sku: product.sku).present?
              product.sku = Services::Resources::Shared::UidGenerator.product_sku([product.sku])
            end
            if product.save
              build_inquiry_product(product, inquiry, sr_no, quantity)
              comment = product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
              product.create_approval(comment: comment, overseer: current_overseer)
              if product.approved?
                begin
                  product.save_and_sync
                rescue => e
                  writer << ["#{product.sku} - #{product_name}", "#{e.message}-Sync issue"]
                  next
                end
              end
            else
              products_with_issues << ["#{product.sku} - #{product_name}", "#{product.errors}}-active record issue"]
              writer << [product.sku, product.name, product.errors]
            end
          end
        end
      end
      writer
    end

    fetch_csv('sap_not_sync_product_52898.csv', csv_data)
    puts products_with_issues
  end

  def inquiry_product_52899_creation_service
    service = Services::Shared::Spreadsheets::CsvImporter.new('52899BayerProducts.csv', 'seed_files_3')
    products_with_issues = []
    inquiry = Inquiry.find_by_inquiry_number(52899)
    inquiry.update_attributes(status: 'Cross Reference')
    current_overseer = Overseer.find_by_id(238)

    column_headers = ['sku', 'name', 'message']
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|

      service.loop(nil) do |row|
        product_name = row.get_column('name').to_s
        mpn = row.get_column('mpn')
        sr_no = row.get_column('sr_no')
        quantity = row.get_column('quantity')
        brand = row.get_column('brand').to_s
        tax_code = row.get_column('tax_code').present? ? row.get_column('tax_code').to_s : nil
        is_service = row.get_column('is_service').present? && row.get_column('is_service').downcase == 'yes' ? true : false
        category = row.get_column('category_id').present? ? row.get_column('category_id') : nil
        tax_rate = row.get_column('tax_rate').present? ? row.get_column('tax_rate').to_f : nil
        brand_data = Brand.find_by_name(brand)
        if product_name.present?
          product = Product.where(name: product_name).last
          if product.present?
            build_inquiry_product(product, inquiry, sr_no, quantity)
          else
            product = Product.new(
                name: product_name,
                tax_code: tax_code.present? ? TaxCode.where('code LIKE ?', tax_code).first : nil,
                brand: brand_data.present? && brand_data.is_active ? brand_data : nil,
                mpn: mpn,
                tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
                category: category.present? ? Category.where(id: category, is_active: true).last : Category.find(5100),
                is_service: is_service,
                )
            if Product.where(sku: product.sku).present?
              product.sku = Services::Resources::Shared::UidGenerator.product_sku([product.sku])
            end
            if product.save
              build_inquiry_product(product, inquiry, sr_no, quantity)
              comment = product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
              product.create_approval(comment: comment, overseer: current_overseer)
              if product.approved?
                begin
                  product.save_and_sync
                rescue => e
                  writer << ["#{product.sku} - #{product_name}", "#{e.message}-Sync issue"]
                  next
                end
              end
            else
              products_with_issues << ["#{product.sku} - #{product_name}", "#{product.errors}}-active record issue"]
              writer << [product.sku, product.name, product.errors]
            end
          end
        end
      end
      writer
    end

    fetch_csv('sap_not_sync_product_52899.csv', csv_data)
    puts products_with_issues
  end

  def inquiry_product_52900_creation_service
    service = Services::Shared::Spreadsheets::CsvImporter.new('52900BayerProducts.csv', 'seed_files_3')
    products_with_issues = []
    inquiry = Inquiry.find_by_inquiry_number(52900)
    inquiry.update_attributes(status: 'Cross Reference')
    current_overseer = Overseer.find_by_id(238)

    column_headers = ['sku', 'name', 'message']
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|

      service.loop(nil) do |row|
        product_name = row.get_column('name').to_s
        mpn = row.get_column('mpn')
        sr_no = row.get_column('sr_no')
        quantity = row.get_column('quantity')
        brand = row.get_column('brand').to_s
        tax_code = row.get_column('tax_code').present? ? row.get_column('tax_code').to_s : nil
        is_service = row.get_column('is_service').present? && row.get_column('is_service').downcase == 'yes' ? true : false
        category = row.get_column('category_id').present? ? row.get_column('category_id') : nil
        tax_rate = row.get_column('tax_rate').present? ? row.get_column('tax_rate').to_f : nil
        brand_data = Brand.find_by_name(brand)
        if product_name.present?
          product = Product.where(name: product_name).last
          if product.present?
            build_inquiry_product(product, inquiry, sr_no, quantity)
          else
            product = Product.new(
                name: product_name,
                tax_code: tax_code.present? ? TaxCode.where('code LIKE ?', tax_code).first : nil,
                brand: brand_data.present? && brand_data.is_active ? brand_data : nil,
                mpn: mpn,
                tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
                category: category.present? ? Category.where(id: category, is_active: true).last : Category.find(5100),
                is_service: is_service,
                )
            if Product.where(sku: product.sku).present?
              product.sku = Services::Resources::Shared::UidGenerator.product_sku([product.sku])
            end
            if product.save
              build_inquiry_product(product, inquiry, sr_no, quantity)
              comment = product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
              product.create_approval(comment: comment, overseer: current_overseer)
              if product.approved?
                begin
                  product.save_and_sync
                rescue => e
                  writer << ["#{product.sku} - #{product_name}", "#{e.message}-Sync issue"]
                  next
                end
              end
            else
              products_with_issues << ["#{product.sku} - #{product_name}", "#{product.errors}}-active record issue"]
              writer << [product.sku, product.name, product.errors]
            end
          end
        end
      end
      writer
    end

    fetch_csv('sap_not_sync_product_52900.csv', csv_data)
    puts products_with_issues
  end
end