class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call

    excel_import.rows.each_with_index do |row,index|
      if row.marked_for_destruction?
        row.reload
      elsif row.approved_alternative_id.present?
        row.build_inquiry_product(
            :inquiry => inquiry,
            :import => excel_import,
            :product_id => row.approved_alternative_id,
            :quantity => row.metadata['quantity'],
            :position => inquiry.last_position + index + 1,
        )
      else
        row
      end
    end

    excel_import.save
  end


  attr_accessor :inquiry, :excel_import
end