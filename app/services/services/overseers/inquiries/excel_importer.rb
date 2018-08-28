class Services::Overseers::Inquiries::ExcelImporter < Services::Shared::BaseService
  include Rails.application.routes.url_helpers
  # RandomRecords.for(Product, 10).each do |p| puts "#{p.sku}, 5"; end
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import

    @existing_products = []
    @failed_skus = []
  end

  def call
    if excel_import.save

      excel_items = get_excel_items(excel_import)
      columns = ["id", "name", "brand", "mpn", "sku", "quantity"]
      if (excel_items.first.first.downcase == 'id')
        columns = excel_items.shift
      end
      columns = columns.map(&:downcase)
      #raise()
      loop_and_set_products(excel_items, columns)
      ActiveRecord::Base.transaction do
        add_existing_products_to_inquiry
        log_failed_skus
      end
    end

    true
  end

  def loop_and_set_products(excel_items, columns)

    excel_items.each do |excel_item|
      unless excel_item[1].nil?
        sku = excel_item[columns.index('sku')]
        quantity = excel_item[columns.index('quantity')]
        add_product(sku, quantity)
      end
    end
  end

  def add_product(sku, quantity)
    product = Product.find_by_sku(sku)

    if product.present?
      existing_products << [product, quantity]
    else
      failed_skus << sku
    end
  end

  def add_existing_products_to_inquiry
    existing_products.each do |product, quantity|
      inquiry.inquiry_products.where(product: product).first_or_create.update_attributes(:quantity => quantity, :import => excel_import)
    end
  end

  def log_failed_skus
    excel_import.update_attributes(
        failed_skus: failed_skus
    )
  end

  def get_excel_items(excel_import)
    doc = SimpleXlsxReader.open(ActiveStorage::Blob.service.send(:path_for, excel_import.file.key))

    excel_items = doc.sheets.first.rows
    # Remove Empty or Blank rows from the
    excel_items = excel_items.map {|e| e.instance_of?(Array) ? e.reject(&:blank?).collect {|ei| ei.to_s.strip} : e}.reject(&:empty?)
  end

  attr_accessor :inquiry, :excel_import, :existing_products, :failed_skus
end