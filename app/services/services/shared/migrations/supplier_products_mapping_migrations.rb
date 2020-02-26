class Services::Shared::Migrations::SupplierProductsMappingMigrations < Services::Shared::BaseService

  def create_supplier_products
    InquiryProductSupplier.all.find_each(batch_size: 500) do |record|
      supplier = record.supplier if record.supplier.present?
      product = record.inquiry_product.product if record.inquiry_product.present?
      supplier_products = SupplierProduct.where(supplier_id: supplier.id, product_id: product.id)
      unless supplier_products.present?
        category = product.present? ? product.category : ''
        brand = product.present? ? product.brand : ''
        unit_price = record.present? ? record.latest_unit_cost_price : 0.0
        SupplierProduct.create(supplier_id: supplier.id, brand_id: brand.id, category_id: category.id, name: product.name, sku: product.sku, supplier_price: unit_price, unit_selling_price: unit_price, tax_rate_id: product.tax_rate.id, tax_code_id: product.tax_code.id, measurement_unit_id: product.measurement_unit.id)
      end
    end
  end

end