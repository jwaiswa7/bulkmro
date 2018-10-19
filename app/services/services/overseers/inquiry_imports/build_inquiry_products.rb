class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    service = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)

    excel_import.rows.reverse.each do |row|
      if row.failed?
        row.build_inquiry_product(
            inquiry: inquiry,
            import: excel_import,
            :sr_no => service.call(row.metadata['sr_no'] || row.metadata['id']),
            product: Product.new(
                inquiry_import_row: row,
                name: row.metadata['name'],
                sku: row.sku,
                mpn: row.mpn,
                brand: Brand.find_by_name(row.metadata['brand']),
            ),
            quantity: row.metadata['quantity'].to_i
        )
      end
    end
  end

  attr_accessor :inquiry, :excel_import
end