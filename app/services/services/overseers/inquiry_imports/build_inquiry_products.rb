class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    excel_import.rows.each do |row|
      row.build_inquiry_product(
          inquiry: inquiry,
          import: excel_import,
          product: Product.new(
              import_row: row,
              name: row.metadata['name'],
              sku: row.sku,
              brand: Brand.find_by_name(row.metadata['brand']),
          ),
          quantity: row.metadata['quantity'].to_i
      ) if row.failed?

      alternate = Product.where("name LIKE ?", "%#{row.metadata['name'].split.first}%").limit(4) || nil

      row.inquiry_product.assign_attributes(:alternate=>alternate)

    end
  end

  attr_accessor :inquiry, :excel_import
end