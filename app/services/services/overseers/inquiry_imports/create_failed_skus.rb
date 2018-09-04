class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import, create_failed_skus_params)
    @inquiry = inquiry
    @excel_import = excel_import
    @params = create_failed_skus_params

  end

  def call

    raise

    excel_import.assign_attributes(params.except(:product))

    if excel_import.valid?
      excel_import.rows.each do |row|
        if row.marked_for_destruction?
          row.reload
        end
      end
    end



    params.require(:product).each do |row_id, param|

      row = excel_import.rows.find(row_id)
      row.inquiry_product.product = Product.find(param.require(:id))
      raise
    end


    excel_import.save
  end

  def notify

  end

  attr_accessor :inquiry, :excel_import, :params
end