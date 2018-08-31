class Services::Overseers::Inquiries::SetDefaultSuppliers < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    inquiry.inquiry_products.each do |inquiry_product|
      if inquiry_product.product.present? && inquiry_product.product.approved? && inquiry_product.inquiry_suppliers.blank?
          if inquiry_product.product.inquiry_suppliers.present?
            inquiry_product.inquiry_suppliers.build(:supplier => inquiry_product.product.lowest_inquiry_supplier.supplier, :unit_cost_price => inquiry_product.product.lowest_unit_cost_price)
        end
      end
    end
  end

  attr_accessor :inquiry
end