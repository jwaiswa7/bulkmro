class Services::Overseers::Inquiries::BaseImporter < Services::Shared::BaseService

  def initialize(inquiry, import)
    @inquiry = inquiry
    @import = import

    @rows = []
    @existing_products = []
    @failed_skus = []
    @failed_skus_metadata = []
  end

  def set_existing_and_failed_products
    rows.each do |row|
      product = Product.find_by_sku(row[:SKU])

      if product.present?
        existing_products << [product, row[:Quantity]]
      else
        failed_skus << row[:SKU]
        failed_skus_metadata << row
      end
    end
  end

  def add_existing_products_to_inquiry
    existing_products.each do |product, quantity|
      inquiry.inquiry_products.where(product: product).first_or_create.update_attributes(:quantity => quantity, :import => import)
    end
  end

  def add_failed_rows_to_inquiry
    import.update_attributes(
        failed_skus: failed_skus,
        failed_skus_metadata: failed_skus_metadata
    )
  end

  attr_accessor :inquiry, :import, :rows, :existing_products, :failed_skus, :failed_skus_metadata
end