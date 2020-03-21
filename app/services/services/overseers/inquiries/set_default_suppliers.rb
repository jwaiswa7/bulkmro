class Services::Overseers::Inquiries::SetDefaultSuppliers < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    inquiry.inquiry_products.each do |inquiry_product|
      if inquiry_product.product.approved? && inquiry_product.inquiry_product_suppliers.blank?
        if inquiry_product.product.inquiry_product_suppliers.present?
          inquiry_product.product.lowest_inquiry_product_suppliers(number: 5).each do |product_supplier|
            unit_cost_price = product_supplier.lowest_unit_cost_price != 'N/A' ? product_supplier.lowest_unit_cost_price : 0.0
            if product_supplier.supplier.to_s != 'Local'
              inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.build(
                supplier_id: product_supplier.supplier.id,
                unit_cost_price: unit_cost_price,
                last_unit_price: unit_cost_price
              )
              inquiry_product_supplier.save
            end
          end
        end
      end
    end
  end


  attr_accessor :inquiry
end
