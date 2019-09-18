class Services::Overseers::Inquiries::LinkSuppliersToProducts < Services::Shared::BaseService
  def initialize(inquiry, supplier_ids, inquiry_product_ids)
    @inquiry = inquiry
    @supplier_ids = supplier_ids
    @inquiry_product_ids = inquiry_product_ids[0].split(',')
  end

  def call
    inquiry_product_ids.each do |inquiry_product_id|
      inquiry_product = InquiryProduct.find(inquiry_product_id)
      supplier_ids.each do |supplier_id|
        supplier_rfq = SupplierRfq.where(inquiry_id: @inquiry.id, inquiry_product_id: inquiry_product.id, product_id: inquiry_product.product.id, supplier_id: supplier_id.to_i, status: 1).first_or_create
        inquiry_product_supplier = InquiryProductSupplier.where(supplier_rfq_id: supplier_rfq.id, inquiry_product_id: inquiry_product.id, supplier_id: supplier_id.to_i).first_or_initialize
        inquiry_product_supplier.save
      end if supplier_ids.present?
    end if inquiry_product_ids.present?
  end

  private
    attr_accessor :inquiry, :supplier_ids, :inquiry_product_ids
end
