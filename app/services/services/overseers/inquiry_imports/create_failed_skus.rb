class Services::Overseers::InquiryImports::CreateFailedSkus < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call

    already_approved_alternate_ids = []

    serial_numbers = inquiry.inquiry_products.pluck(:sr_no)

    excel_import.rows.each do |row|
      if row.marked_for_destruction?
        if excel_import.valid?
          row.reload
        end
      elsif row.approved_alternative_id.present?

        if not already_approved_alternate_ids.include?(row.approved_alternative_id)

          id = row.metadata['id']
          if serial_numbers.include?(id)
            id = serial_numbers.map(&:to_i).max + 1
            serial_numbers << id
          end

          row.build_inquiry_product(
              :inquiry => inquiry,
              :import => excel_import,
              :product_id => row.approved_alternative_id,
              :quantity => row.metadata['quantity'],
              :sr_no => id,
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