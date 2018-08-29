class Services::Overseers::InquiryImports::BuildInquiryProducts < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import
  end

  def call
    excel_import.assign_attributes(inquiry_products: [])

    excel_import.failed_skus_metadata.each do |failed_sku_metadata|
      excel_import.inquiry_products.build(
        inquiry: inquiry,
        failed_sku: failed_sku_metadata['sku'],
        product: Product.new(
            import: excel_import,
            name: failed_sku_metadata['name'],
            sku: failed_sku_metadata['sku'],
            brand: Brand.find_by_name(failed_sku_metadata['brand']),
        ),
        quantity: failed_sku_metadata['quantity'].to_i
      )
    end
  end

  attr_accessor :inquiry, :excel_import
end