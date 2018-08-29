class Services::Overseers::InquiryImports::BaseImporter < Services::Shared::BaseService

  def initialize(inquiry, import)
    @inquiry = inquiry
    @import = import

    @rows = []
    @existing_products = []
    @successful_skus_metadata = []
    @failed_skus_metadata = []
  end

  def delete_duplicate_rows
    rows.uniq! { |row| row['sku'] }
  end

  def set_existing_and_failed_products
    rows.each do |row|
      row.stringify_keys!

      product = Product.find_by_sku(row['sku'])

      if product.present?
        existing_products << [product, row['quantity']]
        successful_skus_metadata << row
      else
        failed_skus_metadata << row
      end
    end
  end

  def add_existing_products_to_inquiry
    existing_products.each do |product, quantity|
      inquiry.inquiry_products.where(product: product).first_or_create do |inquiry_product|
        inquiry_product.quantity = quantity
        inquiry_product.import = import
      end
    end
  end

  def add_successful_rows_to_inquiry
    import.update_attributes(
        successful_skus_metadata: successful_skus_metadata
    )
  end

  def add_failed_rows_to_inquiry
    import.update_attributes(
        failed_skus_metadata: failed_skus_metadata
    )
  end

  def any_failed?
    failed_skus_metadata.any?
  end

  attr_accessor :inquiry, :import, :rows, :existing_products, :failed_skus_metadata, :successful_skus_metadata
end