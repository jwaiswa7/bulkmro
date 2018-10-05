class Services::Overseers::InquiryImports::ExcelImporter < Services::Overseers::InquiryImports::BaseImporter
  class ExcelInvalidHeader < StandardError;
  end

  def call
    if import.save
      set_excel_rows
      set_and_validate_excel_header_row
      set_rows
      set_generated_skus

      call_base
    end
  end

  def set_excel_rows
    excel = SimpleXlsxReader.open(TempfilePath.for(import.file))
    excel_rows = excel.sheets.first.rows
    excel_rows.reject! {|er| er.compact.blank?}

    @excel_rows = excel_rows
  end

  def set_and_validate_excel_header_row
    @excel_header_row = excel_rows.shift

    excel_header_row.each do |column|
      if /^[A-Z]{1}[a-zA-Z]*$/.match?(column) && column.in?(%w(Id Name Brand MPN SKU Quantity))
        column.downcase!
      else
        raise ExcelInvalidHeader
      end
    end
  end

  def set_rows
    excel_rows.each do |excel_row|
      rows.push excel_header_row.zip(excel_row).to_h
    end
  end

  def set_generated_skus
    rows.each do |row|
      if !Product.approved.find_by_sku(row['sku']).present?
        number = [*'0'..'9']
        character = [*'A'..'Z', *'a'..'z']

        10.times do
          code = [
              "BM9",
              [number.sample, character.sample, number.sample, character.sample].join.upcase
          ].join
          row['sku'] = code
          puts code
          break if Product.find_by_sku(code).blank?
        end

      end

    end
  end

  attr_accessor :inquiry, :import, :excel_rows, :excel_header_row, :excel_products
end