limit=nil
folder = 'seed_files_2'
update_if_exists = true
PaperTrail.request(enabled: false) do

  service = Services::Shared::Spreadsheets::CsvImporter.new('inquiry_items.csv', folder)
  service.loop(limit) do |x|
    puts "#{x.get_column('quotation_item_id')}"
    #next if (x.get_column('quotation_item_id').to_i < 3189 )
    quotation_id = x.get_column('quotation_id')
    product_id = x.get_column('product_id')
    supplier_uid = x.get_column('sup_code')

    next if quotation_id.in? %w(3529 123 8023)
    inquiry = Inquiry.find_by_legacy_id(quotation_id)
    product = Product.find_by_legacy_id(product_id)
    next if inquiry.blank? || product.blank?

    inquiry_product = InquiryProduct.where(inquiry: inquiry, product: product).first_or_initialize
    if inquiry_product.new_record? || update_if_exists
      inquiry_product.sr_no = x.get_column('order')
      inquiry_product.quantity = x.get_column('qty', nil_if_zero: true) || 1
      inquiry_product.bp_catalog_name = x.get_column('caption')
      inquiry_product.bp_catalog_sku = x.get_column('bpcat')
      inquiry_product.legacy_metadata = x.get_row
      inquiry_product.legacy_id = x.get_column('quotation_item_id')
      inquiry_product.save!
    end

    supplier = Company.acts_as_supplier.find_by_remote_uid(supplier_uid) || Company.legacy
    inquiry_product_supplier = inquiry_product.inquiry_product_suppliers.where(:supplier => supplier).first_or_initialize
    if inquiry_product_supplier.new_record? || update_if_exists
      inquiry_product_supplier.unit_cost_price = x.get_column('cost').try(:to_i) || 0
      inquiry_product_supplier.save!
    end

    quotation_uid = x.get_column('doc_entry')
    sales_quote = inquiry.sales_quote

    if sales_quote.blank?
      inquiry.update_attributes(:quotation_uid => quotation_uid)
      sales_quote = inquiry.sales_quotes.create!({overseer: inquiry.inside_sales_owner})
    end

    if inquiry.status_before_type_cast >= 5
      sales_quote.update_attributes!(:sent_at => sales_quote.created_at)
    end

    row = sales_quote.rows.where(inquiry_product_supplier: inquiry_product_supplier).first_or_initialize
    if row.new_record? || update_if_exists
      row.measurement_unit = MeasurementUnit.default
      row.quantity = x.get_column('qty', nil_if_zero: true) || 1
      row.margin_percentage = ((x.get_column('price_ht', to_f: true) == 0 || x.get_column('cost', to_f: true) == 0) ? 0 : ((1 - (x.get_column('cost').to_f / x.get_column('price_ht').to_f)) * 100))
      row.tax_code = TaxCode.find_by_chapter(x.get_column('hsncode')) || nil
      row.legacy_applicable_tax = x.get_column('tax_code')
      row.legacy_applicable_tax_class = x.get_column('tax_class_id')
      row.legacy_applicable_tax_percentage = (x.get_column('tax_code').match(/\d+/)[0].to_f if x.get_column('tax_code').present?)
      row.unit_selling_price = x.get_column('price_ht', to_f: true)
      row.converted_unit_selling_price = x.get_column('price_ht', to_f: true)
      row.lead_time_option = LeadTimeOption.find_by_name(x.get_column('leadtime'))
      row.save!
    end
  end
end