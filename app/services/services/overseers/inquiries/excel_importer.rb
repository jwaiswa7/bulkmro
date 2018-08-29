class Services::Overseers::Inquiries::ExcelImporter < Services::Shared::BaseService
  def initialize(inquiry, excel_import)
    @inquiry = inquiry
    @excel_import = excel_import

    @existing_products = []
    @failed_skus = []
    @failed_skus_metadata = []
  end

  def call
    if excel_import.save

      loop_and_set_products(excel_import)
      ActiveRecord::Base.transaction do
        add_existing_products_to_inquiry
        log_failed_skus
      end
    end
    excel_import
  end

  def loop_and_set_products(excel_import)
    excel_items = get_excel_items(excel_import)
    columns = ["id", "name", "brand", "mpn", "sku", "quantity"]

    if (excel_items.first.first.downcase == 'id')
      columns = excel_items.shift
    end
    columns = columns.map(&:downcase)

    @colums_sym = columns.map(&:to_sym)
    excel_items.each do |excel_item|
      unless excel_item[1].nil?
        add_product(excel_item, columns)
      end
    end
  end

  def add_product(excel_item, columns)
    sku = excel_item[columns.index('sku')]
    quantity = excel_item[columns.index('quantity')]
    product = Product.find_by_sku(sku)

    if product.present?
      existing_products << [product, quantity]
    else
      failed_skus << sku
      failed_skus_metadata << @colums_sym.zip(excel_item).to_h
    end
  end

  def add_existing_products_to_inquiry
    existing_products.each do |product, quantity|
      inquiry.inquiry_products.where(product: product).first_or_create.update_attributes(:quantity => quantity, :import => excel_import)
    end
  end

  def log_failed_skus
    excel_import.update_attributes(
        failed_skus: failed_skus,
        failed_skus_metadata: failed_skus_metadata.as_json
    )

  end

  def get_excel_items(excel_import)
    doc = SimpleXlsxReader.open(ActiveStorage::Blob.service.send(:path_for, excel_import.file.key))
    excel_items = doc.sheets.first.rows

    # Strip White Space from rows
    excel_items = excel_items.map {|e| e.instance_of?(Array) ? e.collect {|ei| ei.to_s.strip} : e}
    # Remove rows with blank elements
    excel_items = excel_items.map {|e| e[1].empty? ? e.reject(&:blank?) : e}.reject(&:empty?)

    return excel_items
  end

  attr_accessor :inquiry, :excel_import, :existing_products, :failed_skus, :failed_skus_metadata
end