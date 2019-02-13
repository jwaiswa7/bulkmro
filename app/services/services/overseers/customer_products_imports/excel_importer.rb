class Services::Overseers::CustomerProductsImports::ExcelImporter
  class ExcelInvalidHeader < StandardError;
  end
  class ExcelInvalidRows < StandardError;
  end

  def initialize(company, import)
    @company = company
    @import = import
    @rows = []
  end

  def call
    ActiveRecord::Base.transaction do
      if import.save
        set_and_validate_excel_rows
        set_and_validate_excel_header_row
        set_rows
      end
      import
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
      if /^[a-zA-Z_]{1}[_a-zA-Z]*$/i.match?(column) && column.downcase.in?(CustomerProductImport::HEADERS)
        column.downcase!
      else
        import.errors.add(:base, ["Invalid excel upload; the columns should be", CustomerProductImport::HEADERS.to_sentence + "."].join(" "))
      end
    end
  end

  def attach_file(record, file_url, filename)
    begin
      if file_url.present? && filename.present?
        url = URI(file_url)
        res = Net::HTTP.get_response(url)
        if res.code == "200" || res.code == "301" || res.code == "302"
          file = open(file_url)
          record.send("images").attach(io: file, filename: filename)
        else
          puts "Code = #{res.code}"
        end
      end
    rescue URI::InvalidURIError => e
      puts "Help! #{e} did not migrate."
    end
  end

  def set_rows
    excel_rows.each do |excel_row|
      row = excel_header_row.zip(excel_row).to_h
      if excel_row.compact.length > 1 && (row["sku"].present? && row["price"].present?)
        product = Product.find_by_sku(row["sku"])
        if product.present?
          customer_product = CustomerProduct.where(company_id: company.id, product_id: product.id).first_or_create
          customer_product.customer_price = row["price"].to_f
          customer_product.name = (row["name"] if row["name"].present?) || product.name
          customer_product.sku = row["material_code"] || product.sku
          customer_product.brand = (Brand.find_by_name(row["brand"]) if row["brand"].present?) || product.brand
          customer_product.measurement_unit = (MeasurementUnit.find_by_name(row["uom"]) if row["uom"].present?) || product.measurement_unit
          if row["url"].present?
            filename = row["url"].split("/").last
            attach_file(customer_product, row["url"], filename)
          end
          customer_product.tax_code = (TaxCode.where("code LIKE '%?%'", row["hsn"].to_i).first if row["hsn"].present?) || product.tax_code
          customer_product.tax_rate = (TaxRate.where(tax_percentage: row["tax_percentage"].to_d).first if row["tax_percentage"].present?) || product.tax_rate
          customer_product.save
        end
      else
        excel_rows.delete(excel_row)
      end
    end
  end

  attr_accessor :company, :import, :excel_rows, :excel_header_row, :excel_products, :rows
end
