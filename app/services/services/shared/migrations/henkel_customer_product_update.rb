class Services::Shared::Migrations::HenkelCustomerProductUpdate < Services::Shared::Migrations::Migrations
  #for henkel company specific
  def update_name_sku
    service = Services::Shared::Spreadsheets::CsvImporter.new('henkelsheet.csv', 'seed_files_3')
    @customer_array = Array.new
    @total_multiple = Array.new
    @multiple_sku_record = Array.new
    @multiple_with_company = Array.new
    service.loop(nil) do |x|
      @sku = x.get_column('sku')
      @name = x.get_column('name')
      @bp_catalog_sku = x.get_column('bp_catalog_sku')
      @company = x.get_column('company')

      customer_products = CustomerProduct.where(sku: @sku, company_id: 143)
      if !customer_products.empty?
        customer_products = customer_products.compact
        if customer_products.count > 1
          # customer_products.each do |product|
          #   product.name = @name
          #   product.sku = @bp_catalog_sku
          #   product.save!
          # end
          @total_multiple.push(customer_products)
        else
          customer_products = customer_products.first
          customer_products.name = @name
          customer_products.sku = @bp_catalog_sku
          customer_products.save!
        end
        @customer_array.push(customer_products)

      end
    end
  end
end
