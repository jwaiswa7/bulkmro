class Services::Overseers::InquiryImports::ListImporter < Services::Overseers::InquiryImports::BaseImporter

  def call
    if import.save
      set_rows
      delete_duplicate_rows
      set_existing_and_failed_products

      ActiveRecord::Base.transaction do
        add_existing_products_to_inquiry
        add_successful_rows_to_inquiry
        add_failed_rows_to_inquiry
      end

      import
    end
  end

  def set_rows
    import.import_text.split("\n").each do |list_item|
      tuples = list_item.delete(' ').gsub(/[\r\n]/, '').split(',')

      sku = tuples[0]
      quantity = tuples.length > 1 ? tuples[1] : 1

      rows.push({ sku: sku, quantity: quantity })
    end
  end
end