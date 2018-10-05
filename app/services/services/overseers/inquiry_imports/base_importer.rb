class Services::Overseers::InquiryImports::BaseImporter < Services::Shared::BaseService

  def initialize(inquiry, import)
    @inquiry = inquiry
    @import = import

    @rows = []
  end

  def call_base
    delete_duplicate_rows
    persist_inquiry_import_rows

    ActiveRecord::Base.transaction do
      set_existing_products
    end

    import
  end

  def delete_duplicate_rows

    rows.uniq! {|row| row['sku']}
  end

  def persist_inquiry_import_rows
    rows.each do |row|
      row.stringify_keys!
      import.rows.create(import: import, sku: row['sku'], metadata: row)
    end

  end

  def set_existing_products
    import.rows.each do |row|
      product = Product.approved.find_by_sku(row.sku)

      if product.present?
        inquiry_product = inquiry.inquiry_products.where(product: product).first_or_create do |inquiry_product|
          inquiry_product.quantity = row.metadata['quantity']
          inquiry_product.import = import
          inquiry_product.sr_no = row.metadata['id']
        end

        row.update_attributes(:inquiry_product => inquiry_product)
      end
    end

  end

  def any_failed?
    import.rows.failed.any?
  end

  attr_accessor :inquiry, :import, :rows
end