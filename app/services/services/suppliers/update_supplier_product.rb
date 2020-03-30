class Services::Suppliers::UpdateSupplierProduct < Services::Shared::BaseService
  def initialize(inquiry_product_supplier)
    @inquiry_product_supplier = inquiry_product_supplier
    @inquiry = inquiry_product_supplier.inquiry
  end

  def call
    supplier_id = inquiry_product_supplier.supplier_id
    product = inquiry_product_supplier.inquiry_product.product if inquiry_product_supplier.inquiry_product.present?
    supplier_products = SupplierProduct.where(supplier_id: supplier_id, product_id: product.id)
    if supplier_products.present?
      supplier_products.each do |supplier_product|
        if supplier_product.inquiry_ids.length == 1 && supplier_product.inquiry_ids.include?(inquiry.id)
          supplier_product.destroy
        elsif supplier_product.inquiry_ids.include?(inquiry.id)
          supplier_product.inquiry_ids.delete(inquiry.id)
          supplier_product.save
        end
      end
    end
  end

  private
    attr_reader :inquiry_product_supplier, :inquiry
end
