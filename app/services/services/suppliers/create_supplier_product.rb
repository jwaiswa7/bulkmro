class Services::Suppliers::CreateSupplierProduct < Services::Shared::BaseService
  def initialize(inquiry_product_supplier)
    @inquiry_product_supplier = inquiry_product_supplier
  end

  def call
    debugger
    supplier_id = inquiry_product_supplier.supplier_id
    product = inquiry_product_supplier.inquiry_product.product if inquiry_product_supplier.inquiry_product.present?
    debugger
    supplier_products = SupplierProduct.where(supplier_id: supplier_id, product_id: product.id)
    unit_price = inquiry_product_supplier.present? ? inquiry_product_supplier.latest_unit_cost_price : 0.0
    unless supplier_products.present?
      supplier_product_params = { supplier_id: supplier_id, product_id: product.id, brand_id: product.brand_id, category_id: product.category_id, name: product.name, sku: product.sku, supplier_price: unit_price, unit_selling_price: unit_price, tax_rate_id: product.tax_rate_id, tax_code_id: product.tax_code_id, measurement_unit_id: product.measurement_unit_id }
      @supplier_product = SupplierProduct.new(supplier_product_params)
      @supplier_product.save
    end
  end

  private

    attr_reader :inquiry_product_supplier
end