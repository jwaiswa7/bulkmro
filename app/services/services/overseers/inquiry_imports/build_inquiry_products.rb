class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    excel_import.rows.each_with_index do |row, index|
      if row.failed?
        row.build_inquiry_product(
          inquiry: inquiry,
          import: excel_import,
          :sr_no => row.metadata['id'],
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