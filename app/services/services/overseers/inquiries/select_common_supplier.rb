class Services::Overseers::Inquiries::SelectCommonSupplier < Services::Shared::BaseService
  def initialize(params)
          @params=params
  end
  def call
     @common_supplier_id = @params[:common_supplier]
     @inq_pro_ids = @params['inquiry_product_checkbox']
     if @inq_pro_ids.present?
           @inq_pro_ids.each do |inq_pro_id|
           @result = InquiryProductSupplier.where('inquiry_product_id = ? and supplier_id = ?',inq_pro_id,@common_supplier_id)
           if @result.empty?
                 @inq_pro_sup = InquiryProductSupplier.new
                 @inq_pro_sup.supplier_id = @common_supplier_id
                 @inq_pro_sup.inquiry_product_id=inq_pro_id
                 @inq_pro_sup.save!
           end
        end

     end
  end
end