class Services::Overseers::Inquiries::ExcelImporter < Services::Shared::BaseService
  # RandomRecords.for(Product, 10).each do |p| puts "#{p.sku}, 5"; end
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import

    @existing_products = []
    @failed_skus = []
  end

  def call
    if excel_import.save
      # loop_and_set_products
      #
      # ActiveRecord::Base.transaction do
      #   add_existing_products_to_inquiry
      #   log_failed_skus
      # end
    end

    true
  end

  def loop_and_set_products
    excel_import.import_text.split("\n").each do |excel_item|
      tuples = excel_item.delete(' ').gsub(/[\r\n]/,'').split(',')

      sku = tuples[0]
      quantity = tuples.length > 1 ? tuples[1] : 1

      add_product(sku, quantity)
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

  attr_accessor :inquiry, :excel_import, :existing_products, :failed_skus
end