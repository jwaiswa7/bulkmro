

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
      Services::Overseers::Inquiries::UpdateStatus.new(@inquiry, :cross_reference).call if @inquiry.inquiry_products.present?
    end

    import
  end

  def delete_duplicate_rows
    rows.uniq! { |row| row['sku'] }
  end

  def persist_inquiry_import_rows
    rows.each do |row|
      row.stringify_keys!
      import.rows.create(import: import, sku: row['sku'], metadata: row)
    end
  end

  def set_existing_products
    service = Services::Overseers::InquiryImports::NextSrNo.new(inquiry)

    import.rows.each do |row|
      product = Product.active.where('lower(sku) = ? ', row.sku.downcase).try(:first)

      if product.present?
        inquiry_product = inquiry.inquiry_products.where(product: product).first_or_create do |inquiry_product|
          inquiry_product.quantity = row.metadata['quantity']
          inquiry_product.import = import

          inquiry_product.sr_no = service.call(row.metadata['sr_no'] || row.metadata['id'])
        end

        row.update_attributes(inquiry_product: inquiry_product)
      end
    end
  end

  def any_failed?
    import.rows.failed.any?
  end

  attr_accessor :inquiry, :import, :rows
end
