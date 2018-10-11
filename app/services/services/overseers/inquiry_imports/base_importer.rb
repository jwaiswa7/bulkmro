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
    serial_numbers = inquiry.inquiry_products.pluck(:sr_no)
    import.rows.each do |row|
      product = Product.where('lower(sku) = ?', row.sku.downcase).try(:first)

      if product.present?
        inquiry_product = inquiry.inquiry_products.where(product: product).first_or_create do |inquiry_product|

          id = get_serial_number(row.metadata['id'], serial_numbers)
          if not serial_numbers.include?(id)
            serial_numbers << id
          end

          inquiry_product.quantity = row.metadata['quantity']
          inquiry_product.import = import
          inquiry_product.sr_no = id
        end

        row.update_attributes(:inquiry_product => inquiry_product)
      end
    end

  end

  def any_failed?
    import.rows.failed.any?
  end

  def get_serial_number(id, serial_numbers)
    if serial_numbers.include?(id)
      id = serial_numbers.map(&:to_i).max + 1
    end
    id
  end

  attr_accessor :inquiry, :import, :rows
end