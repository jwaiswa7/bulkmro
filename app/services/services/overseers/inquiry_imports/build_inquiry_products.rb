class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    serial_numbers = inquiry.inquiry_products.pluck(:sr_no)

    excel_import.rows.each do |row|
      if row.failed?

        id = row.metadata['id']
        if serial_numbers.include?(id) || id <= serial_numbers.map(&:to_i).max
          id = serial_numbers.map(&:to_i).max + 1
          serial_numbers << id
        else
          serial_numbers << id
        end
        row.build_inquiry_product(
            inquiry: inquiry,
            import: excel_import,
            :sr_no => id,
            product: Product.new(
                inquiry_import_row: row,
                name: row.metadata['name'],
                sku: row.sku,
                brand: Brand.find_by_name(row.metadata['brand']),
            ),
            quantity: row.metadata['quantity'].to_i
        )
      end
    end

  end

  attr_accessor :inquiry, :excel_import
end