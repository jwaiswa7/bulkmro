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

  def inquiry_product_creation_service
    service = Services::Shared::Spreadsheets::CsvImporter.new('52317_Bayer1.csv', 'seed_files_3')
    data_not_done = []
    inquiry = Inquiry.find_by_inquiry_number(2019)
    current_overseer = Overseer.find_by_id(238)
    services = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)
    excel_import = inquiry.imports.build(import_type: :excel, overseer: current_overseer)

    column_headers = ['sku', 'name', 'message']
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|

      service.loop(nil) do |row|
        # Chewy.strategy(:bypass) do
          product_name = row.get_column('name').to_s
          mpn = row.get_column('mpn')
          sr_no = row.get_column('sr_no')
          quantity = row.get_column('quantity')
          brand = row.get_column('brand').to_s
          tax_code = row.get_column('tax_code').present? ? row.get_column('tax_code').to_s : nil
          is_service = row.get_column('is_service').present? && row.get_column('is_service').downcase == 'yes' ? true : false
          category = row.get_column('category_id').present? ? row.get_column('category_id').to_s : nil
          tax_rate = row.get_column('tax_rate').present? ? row.get_column('tax_rate').to_f : nil
          brand_data = Brand.find_by_name(brand)
          if product_name.present?
            @product = Product.where(name: product_name).first_or_initialize
            if @product.present?
              @product.assign_attributes(
                tax_code: tax_code.present? ? TaxCode.where('code LIKE ?', tax_code).first : nil,
                brand: brand_data.present? && brand_data.is_active ? brand_data : nil,
                mpn: mpn,
                tax_rate: tax_rate.present? ? TaxRate.where(tax_percentage: tax_rate).last : nil,
                category: category.present? ? Category.where(name: category, is_active: true).last : Category.find(5100),
                is_service: is_service,
              )
              if Product.where(sku: @product.sku).present?
                @product.sku = Services::Resources::Shared::UidGenerator.product_sku([@product.sku])
              end
              begin
                if @product.save
                  inquiry_product = inquiry.inquiry_products.build(
                    inquiry: inquiry,
                    import: excel_import,
                    product_id: @product.id,
                    sr_no: services.call(sr_no),
                    quantity: quantity.to_i
                  )
                  inquiry_product.save
                  # sync_product_to_sap(@product, current_overseer)

                  # ############## SAP SYNCING AND PRODUCT APPROVAL CODE#############################################
                  comment = @product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
                  @product.create_approval(comment: comment, overseer: current_overseer)
                  @product.save_and_sync
                end
              rescue => e
                puts @product.errors.full_messages
                data_not_done << ["#{@product.sku} - #{product_name}", "#{e.message}"]
                writer << [@product.sku, @product.name, e.message]
                next
              end
            end
          end
        # end
      end
    end
    fetch_csv('sap_not_sync_product.csv', csv_data)
    puts data_not_done
  end

  def sync_product_to_sap(product, current_overseer)
    not_synced_data = []
    column_headers = ['sku', 'name', 'message']
    comment = @product.comments.build(message: 'Product approved from backened', created_by: current_overseer)
    csv_data = CSV.generate(write_headers: true, headers: column_headers) do |writer|
      begin
        ActiveRecord::Base.transaction do
          product.create_approval(comment: comment, overseer: current_overseer)
          product.save_and_sync
        end
      rescue StandardError => e
        not_synced_data << [product.sku, product.name, e.message]
        writer << [product.sku, product.name, e.message]
      end
    end
    fetch_csv('sap_not_sync_product.csv', csv_data)
    puts not_synced_data
  end
end