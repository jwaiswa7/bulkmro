class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call

    already_approved_alternate_ids = []

    excel_import.rows.each do |row|
      if row.marked_for_destruction?
        if excel_import.valid?
          row.reload
        end
      elsif row.approved_alternative_id.present?

        if not already_approved_alternate_ids.include?(row.approved_alternative_id)
        row.build_inquiry_product(
            :inquiry => inquiry,
            :import => excel_import,
            :product_id => row.approved_alternative_id,
            :quantity => row.metadata['quantity'],
            :sr_no => row.metadata['id'],
        )
        already_approved_alternate_ids << row.approved_alternative_id
        else
          row.reload
        end

      else
        row
      end

    end

    excel_import.save
  end


  attr_accessor :inquiry, :excel_import
end