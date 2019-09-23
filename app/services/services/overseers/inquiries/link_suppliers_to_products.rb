class Services::Overseers::Inquiries::LinkSuppliersToProducts < Services::Shared::BaseService
  def initialize(inquiry, supplier_ids, inquiry_product_ids)
    @inquiry = inquiry
    @supplier_ids = supplier_ids.map { |x| x.to_i }
    @inquiry_product_ids = inquiry_product_ids[0].split(',')
  end

  def call
    inquiry_products = InquiryProduct.where(id: inquiry_product_ids)
    inquiry_products.each do |inquiry_product|
      if inquiry_product.product.approved?
        if inquiry_product.product.inquiry_product_suppliers.present?
          default_suppliers = inquiry_product.product.lowest_inquiry_product_suppliers(number: 5)
          default_supplier_ids = default_suppliers.pluck(:supplier_id)
          all_suppliers = supplier_ids | default_supplier_ids
          all_suppliers.each do |supplier_id|
            inquiry_product_supplier = InquiryProductSupplier.where(inquiry_product_id: inquiry_product.id, supplier_id: supplier_id).first_or_initialize
            inquiry_product_supplier.save
          end
        else
          supplier_ids.each do |supplier_id|
            inquiry_product_supplier = InquiryProductSupplier.where(inquiry_product_id: inquiry_product.id, supplier_id: supplier_id).first_or_initialize
            inquiry_product_supplier.save
          end
        end
      end
    end
  end

  private
    attr_accessor :inquiry, :supplier_ids, :inquiry_product_ids
end
