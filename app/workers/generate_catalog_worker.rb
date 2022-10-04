class GenerateCatalogWorker
  include Sidekiq::Worker

  def perform(company_id, overseer_id)
    company = Company.find(company_id)
    overseer = Overseer.find(overseer_id)
    
    inquiry_products = Inquiry.includes(:inquiry_products, :products).where(company_id: company.id).map { |i| i.inquiry_products }.flatten
    inquiry_products.each do |inquiry_product|
      if inquiry_product.product.synced?
        CustomerProduct.where(company_id: company.id, product_id: inquiry_product.product_id).first_or_create do |customer_product|
          customer_product.category_id = inquiry_product.product.category_id
          customer_product.brand_id = inquiry_product.product.brand_id
          customer_product.name = (inquiry_product.bp_catalog_name == '' ? nil : inquiry_product.bp_catalog_name) || inquiry_product.product.name
          customer_product.inquiry_product_sku = (inquiry_product.bp_catalog_sku == '' ? nil : inquiry_product.bp_catalog_sku) || inquiry_product.product.sku
          customer_product.tax_code = inquiry_product.product.best_tax_code
          customer_product.tax_rate = inquiry_product.best_tax_rate
          customer_product.measurement_unit = inquiry_product.product.measurement_unit
          customer_product.moq = 1
          customer_product.created_by = overseer
          customer_product.customer_price = (inquiry_product.product.latest_unit_cost_price || 0)
        end
      end
    end
  
  end
end
