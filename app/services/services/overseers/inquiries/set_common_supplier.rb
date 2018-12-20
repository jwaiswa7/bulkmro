class Services::Overseers::Inquiries::SetCommonSupplier < Services::Shared::BaseService
  def initialize(inquiry, params)
    @inquiry = inquiry
    @params = params
  end

  def call
    common_supplier_id = params[:inquiry][:common_supplier]
    inquiry_product_ids = params['inquiry_product_checkbox'] || []
    inquiry_product_ids.each do |inquiry_product_id|
      InquiryProductSupplier.where(inquiry_product_id: inquiry_product_id, supplier_id: common_supplier_id).first_or_create
    end
  end

  attr_accessor :params, :inquiry
end