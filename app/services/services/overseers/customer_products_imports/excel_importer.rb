class Services::Overseers::CustomerProductsImports::ExcelImporter
  class ExcelInvalidHeader < StandardError; end
  class ExcelInvalidRows < StandardError; end

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
      if /^[a-zA-Z_]{1}[_a-zA-Z]*$/i.match?(column) && column.downcase.in?(CustomerProductImport::HEADERS)
        column.downcase!
      else
        import.errors.add(:base, ['Invalid excel upload; the columns should be', CustomerProductImport::HEADERS.to_sentence + '.'].join(' '))
        raise ExcelInvalidHeader
      end
    end
  end

  def set_rows
    excel_rows.each do |excel_row|
      row = excel_header_row.zip(excel_row).to_h
      if excel_row.compact.length > 1 && (row['sku'].present? && row['price'].present?)
        product = Product.find_by_sku(row['sku'])
        if product.present?
          customer_product_object = CustomerProduct.new
          customer_product_object.company_id = company.id
          customer_product_object.product_id = product.id
          customer_product_object.customer_price = row['price'].to_f
          customer_product_object.name = (row['name'] if row['name'].present? ) || product.name
          customer_product_object.sku = (row['material_code'] if row['material_code'].present?) || row['sku']
          brand = ( Brand.find_by_name(row['brand']) if row['brand'].present? ) || product.brand
          customer_product_object.brand_id = brand.id if brand.present?
          file_url = row['url']
          if file_url.present?
            if file_url.split(':').first != 'http'
              begin
                filename = file_url.split('/').last
                if file_url.present? && filename.present?
                  url = URI.parse(file_url)
                  req = Net::HTTP::Get.new(url)
                  req["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"
                  res =  Net::HTTP.start(url.hostname, url.port) do |http|
                    http.request(req)
                  end
                  if res.code == '200'
                    file = open(file_url)
                    customer_product_object.send('images').attach(io: file, filename: filename)
                    puts "#{filename} code is #{res.code}"
                  else
                    puts "Code = #{res.code}"
                  end
                end
              rescue URI::InvalidURIError => e
                puts "Help! #{e} did not migrate."
              end
            end
          end
          customer_product_object.save
        end
      else
        excel_rows.delete(excel_row)
      end
    end
  end

  attr_accessor :company, :import, :excel_rows, :excel_header_row, :excel_products, :rows
end