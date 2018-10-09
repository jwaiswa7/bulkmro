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
      row['sku'] = Services::Resources::Shared::UidGenerator.product_sku(rows.map { |r| r['sku'] }) if Product.find_by_sku(row['sku']).blank?
    end
  end

  attr_accessor :inquiry, :import, :excel_rows, :excel_header_row, :excel_products
end