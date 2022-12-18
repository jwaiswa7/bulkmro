class Services::Overseers::InquiryImports::RfqImporter < Services::Overseers::InquiryImports::BaseImporter
  class ExcelInvalidHeader < StandardError; end
  class ExcelInvalidRows < StandardError; end

  def call
    ActiveRecord::Base.transaction do
      if import.save
        set_and_validate_excel_rows
        set_and_validate_excel_header_row
        set_rows
        set_generated_skus

        call_base_for_rfq
      end
    end
  end

  def set_and_validate_excel_rows
    excel = SimpleXlsxReader.open(TempfilePath.for(import.file))
    excel_rows = excel.sheets.first.rows
    excel_rows.reject! { |er| er.compact.blank? }

    @excel_rows = excel_rows
  end

  def set_and_validate_excel_header_row
    @excel_header_row = excel_rows.shift

    excel_header_row.each do |column|
      if /^[a-zA-Z_]{1}[_a-zA-Z]*$/i.match?(column) && column.downcase.in?(InquiryImport::RFQ_TEMPLATE_HEADERS)
        column.downcase!
      else
        import.errors.add(:base, ["Invalid excel upload; the columns should be \n", InquiryImport::RFQ_TEMPLATE_HEADERS.to_sentence + '.'].join(' '))
        raise ExcelInvalidHeader
      end
    end
  end

  def set_rows
    excel_rows.each do |excel_row|
      row = excel_header_row.zip(excel_row).to_h
      if excel_row.compact.length > 1 && row['sku'].present?
          rows.push row
      else
        excel_rows.delete(excel_row)
      end
    end

    @rows = rows.reverse
  end

  def set_generated_skus
    p "gvjbhkbf"*100
    rows.each do |row|
      product = Product.find_by_sku(row['sku'])
      if product.blank? || product.not_approved? || row['min_lead_time_days'].blank? || row['max_lead_time_days'].blank? || row['unit_buying_price'].blank? || row['unit_selling_price'].blank? || row['gst_percentage'].blank? || row['tax_code'].blank? || row['vendor_code'].blank?
        import.errors.add(:base, ['invalid excel rows, mandatory fields were not filled for every row'].join(' '))
        raise ExcelInvalidRows
      end
    end
  end


  attr_accessor :inquiry, :import, :excel_rows, :excel_header_row, :excel_products
end
