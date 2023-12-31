# this service is added for future use to create supplier products from existing or new purchase order rows

class Services::Suppliers::CreateSupplierProductFromPO < Services::Shared::BaseService
  def initialize(purchase_order_row)
    @purchase_order_row = purchase_order_row
  end

  def call
    supplier = purchase_order_row.purchase_order.supplier if purchase_order_row.purchase_order.present?
    product = purchase_order_row.product
    if product.present? && supplier.present?
      supplier_products = SupplierProduct.where(supplier_id: supplier.id, product_id: product.id)
      unit_price = purchase_order_row.unit_selling_price.present? ? purchase_order_row.unit_selling_price : 0.0
      unless supplier_products.present?
        supplier_product_params = { supplier_id: supplier.id, product_id: product.id, brand_id: product.brand_id, category_id: product.category_id, name: product.name, sku: product.sku,
                                    supplier_price: unit_price, unit_selling_price: unit_price, tax_rate_id: product.tax_rate_id, tax_code_id: product.tax_code_id,
                                    measurement_unit_id: product.measurement_unit_id, inquiry_ids: [purchase_order_row.purchase_order.inquiry_id] }
        @supplier_product = SupplierProduct.new(supplier_product_params)
        @supplier_product.save
      else
        supplier_products.each do |supplier_product|
          supplier_product.inquiry_ids.push(purchase_order_row.purchase_order.inquiry_id) unless supplier_product.inquiry_ids.include?(purchase_order_row.purchase_order.inquiry_id)
          supplier_product.save
        end
      end
    end
  end

  private

    attr_reader :purchase_order_row
end
