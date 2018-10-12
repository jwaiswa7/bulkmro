class Services::Overseers::InquiryImports::ExcelImporter < Services::Overseers::InquiryImports::BaseImporter
  class ExcelInvalidHeader < StandardError;

  end
  class ExcelInvalidRows < StandardError;

  end

  def call
    if import.save
      set_and_validate_excel_rows

      set_and_validate_excel_header_row
      set_rows
      set_generated_skus

      call_base
    end
  end

  def set_and_validate_excel_rows
    excel = SimpleXlsxReader.open(TempfilePath.for(import.file))
    excel_rows = excel.sheets.first.rows

    excel_rows.reject! {|er| er.compact.blank?}

    @excel_rows = excel_rows
  end

  def set_and_validate_excel_header_row
    @excel_header_row = excel_rows.shift

    excel_header_row.each do |column|
      if /^[a-zA-Z]{1}[a-zA-Z]*$/i.match?(column) && column.downcase.in?(%w(id name brand mpn sku quantity))
        column.downcase!
      else
        raise ExcelInvalidHeader
      end
    end
  end

  def set_rows
    excel_rows.each do |excel_row|
      row = excel_header_row.zip(excel_row).to_h
      if excel_row.compact.length > 1 && (row['sku'].present? || row['mpn'].present?)
        rows.push row
      else
        excel_rows.delete(excel_row)
      end
    end
  end

  def set_generated_skus
    rows.each do |row|
      if Product.find_by_sku(row['sku']).blank?
        if not row['mpn'].blank?


          row['sku'] = Services::Resources::Shared::UidGenerator.product_sku(rows.map {|r| r['sku']})
        else
          raise ExcelInvalidRows
        end
      end
    end
  end


  attr_accessor :inquiry, :import, :excel_rows, :excel_header_row, :excel_products
end