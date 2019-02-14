

class Services::Overseers::Inquiries::CommonSupplierSelected < Services::Shared::BaseService
  def initialize(inquiry, common_supplier_id, inquiry_product_ids)
    @inquiry = inquiry
    @common_supplier_id = common_supplier_id
    @inquiry_product_ids = inquiry_product_ids
  end

  def call
    inquiry_product_ids.each do |inquiry_product_id|
      InquiryProductSupplier.where(inquiry_product_id: inquiry_product_id, supplier_id: common_supplier_id).first_or_create
    end if inquiry_product_ids.present?
  end

  private
    attr_accessor :inquiry, :common_supplier_id, :inquiry_product_ids
end
