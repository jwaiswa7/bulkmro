class Services::Shared::Migrations::CreditNoteEntries < Services::Shared::Migrations::Migrations
  def create_credit_note_entries
    @order_number = ''
    @product_sku = ''
    @quantity = ''
    @order_date = ''
    @margin_percentage = ''
    @unit_selling_price = ''
    @unit_cost_price = ''
    @tax_rate = ''
    @margin_value = ''
    @tax_amount_value = ''
    missing_sku = []
    i = 8888888881
    service = Services::Shared::Spreadsheets::CsvImporter.new('ae_entries.csv', 'seed_files_3')
    duplicate_array = []

    service.loop(nil) do |x|
      @order_number = x.get_column('So #')
      @product_sku = x.get_column('Bm #')
      @quantity = x.get_column('Order Qty')
      @order_date = x.get_column('Client Order Date')
      @margin_percentage = x.get_column('Margin (In %)')
      @unit_selling_price = x.get_column('Unit Selling Price')
      @unit_cost_price = x.get_column('Unit cost price')
      @tax_rate = x.get_column('Tax Rate')
      @margin_value = x.get_column('Margin')
      @tax_amount_value = x.get_column('Tax Amount')
      @tax_type = x.get_column('Tax Type')
      sales_order = SalesOrder.where(order_number: order_number.to_i).last
      inquiry_product = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku).first
      puts "**************************CURRENT ROW*******************", order_number
      puts "***************************IP********************", product_sku

      if sales_order.present? && inquiry_product.present?
        duplicate_order_number = duplicate_array.map {|k| k.values[0] if k.keys[0] == order_number.to_s}.compact.first if duplicate_array.present?
        if duplicate_array.present? && duplicate_order_number.present?
          duplicate_order = SalesOrder.where(order_number: duplicate_order_number).last
          create_duplicate_order_rows(duplicate_order, sales_order, product_sku, quantity)
        else
          if duplicate_order_number.blank?
            duplicate_sales_order = SalesOrder.new
            duplicate_sales_order.sales_quote_id = create_sales_quote(sales_order, order_date)
            duplicate_sales_order.old_order_number = order_number
            duplicate_sales_order.remote_status = sales_order.remote_status
            duplicate_sales_order.status = sales_order.status
            duplicate_sales_order.order_number = i
            duplicate_sales_order.billing_address_id = sales_order.billing_address_id
            duplicate_sales_order.shipping_address_id = sales_order.shipping_address_id
            duplicate_sales_order.created_at = Date.parse(order_date).strftime('%Y-%m-%d')
            duplicate_sales_order.is_credit_note_entry = true
            duplicate_sales_order.parent_id = sales_order.order_number
            if duplicate_sales_order.save(validate: false)
              create_duplicate_order_rows(duplicate_sales_order, sales_order, product_sku, quantity)
            end
            i = i + 1
            order_number_json = {}
            sales_order.sales_quote.id
            order_number_json[sales_order.order_number.to_s] = duplicate_sales_order.order_number
            duplicate_array << order_number_json
          end
        end
      else
        missing_sku.push("#{sales_order.order_number}-#{product_sku}")
      end
    end
    puts missing_sku, missing_sku.count
  end

  def create_duplicate_order_rows(duplicate_order, old_sales_order, product_sku, quantity)
    row = duplicate_order.rows.build
    row.tax_type = tax_type
    row.sales_quote_row_id = create_sales_quote_row(duplicate_order.sales_quote, old_sales_order)
    row.quantity = quantity.to_f
    row.save(validate: false)
  end

  def create_sales_quote(sales_order, order_date)
    sales_quote = sales_order.sales_quote
    if sales_quote.present?
      new_sales_quote = SalesQuote.new
      new_sales_quote.inquiry_id = sales_order.inquiry.id
      new_sales_quote.created_at = Date.parse(order_date).strftime('%Y-%m-%d')
      new_sales_quote.updated_at = Date.parse(order_date).strftime('%Y-%m-%d')
      new_sales_quote.is_credit_note_entry = true
      new_sales_quote.save(validate: false)
      new_sales_quote.id
    end
  end

  def create_sales_quote_row(sales_quote, old_sales_order)
    product = Product.find_by_sku(product_sku)
    quote_row = sales_quote.rows.build(measurement_unit_id: product.measurement_unit_id, tax_code_id: product.best_tax_code.id, tax_rate_id: product.best_tax_rate.id)

    inquiry_supplier_id = old_sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku).first.inquiry_product_supplier.id
    if inquiry_supplier_id.present?
      quote_row.sales_quote_id = sales_quote.id
      quote_row.quantity = quantity
      if x.get_column('Tax Type').present? && (x.get_column('Tax Type').include?('VAT') || x.get_column('Tax Type').include?('CST') ||  x.get_column('Tax Type').include?('Service'))
        quote_row.tax_code_id = nil
        quote_row.tax_type = tax_type
      else
        quote_row.tax_code_id = product.tax_code.id
      end
      quote_row.tax_rate_id = TaxRate.find_by_tax_percentage(x.get_column('Tax Type').split('%')[0]).id || product.tax_rate_id
      quote_row.legacy_applicable_tax_percentage = tax_rate.to_d
      quote_row.inquiry_product_supplier_id = inquiry_supplier_id
      quote_row.margin_percentage = margin_percentage
      quote_row.unit_selling_price = unit_selling_price.to_f
      quote_row.converted_unit_selling_price = unit_selling_price.to_f / sales_quote.currency.conversion_rate.to_f
      quote_row.created_at = sales_quote.created_at
      quote_row.updated_at = sales_quote.updated_at
      if sales_quote.is_credit_note_entry
        quote_row.credit_note_unit_cost_price = unit_cost_price.to_f
        sales_quote.save(validate: false)
      end
      quote_row.save(validate: false)
    end
    quote_row.id
  end

  attr_accessor :product_sku, :quantity, :order_number, :order_date, :margin_percentage, :unit_selling_price, :unit_cost_price, :tax_rate, :margin_value, :tax_amount_value, :tax_type
end
