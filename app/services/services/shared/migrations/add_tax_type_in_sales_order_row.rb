class Services::Shared::Migrations::AddTaxTypeInSalesOrderRow < Services::Shared::Migrations::Migrations
  def add_tax_type_in_sales_order_row
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_with_vat_cst_service.csv', 'seed_files')
    multiple_sku_quote = []
    tax_rate_different = []
    updated_sales_quote = []
    multiple_sku_quote_product = "#{Rails.root}/tmp/multiple_sku_quote_product.csv"
    headers = ['Inquiry', 'Order Number', 'Sales Quote', 'Product Sku', 'No Of Count']
    service.loop(nil) do |so_row|
      @order_number = so_row.get_column('So #')
      if order_number.present?
        sales_order = SalesOrder.where(order_number: order_number.to_i).last
        if sales_order.present?
          product_sku = so_row.get_column('Bm #')
          if product_sku.present?
            sales_quote_row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku)
            sales_quote_count = sales_quote_row.count
            if sales_quote_count == 1
              tax_type = so_row.get_column('Tax Type')
              if sales_quote_row.present? && tax_type.present?
                so_row_tax_rate = so_row.get_column('Tax Rate')
                if sales_quote_row.last.tax_rate.tax_percentage.to_f == so_row_tax_rate.gsub('%','').to_f
                  sales_quote_row.last.update_attributes(tax_type: tax_type)
                  updated_sales_quote << { inquiry: sales_order.inquiry.inquiry_number, sales_quote_id: sales_quote_row.last.sales_quote.id }
                else
                  tax_rate_different << { inquiry: sales_order.inquiry.inquiry_number, order_number: order_number, sku: product_sku, tax_rate: sales_quote_row.last.tax_rate.tax_percentage.to_f}
                end
              end
            elsif sales_quote_count > 1
              multiple_sku_quote << { inquiry: sales_order.inquiry.inquiry_number, order_number: order_number, sales_quote_id: sales_order.sales_quote.id , sku: product_sku, no_of_count: sales_quote_count}
            end
          end
        end
      end
    end
    puts "---------------------------------------------------------------------"
    puts "Updated Sales Quote Same Quote #{updated_sales_quote}"
    puts "---------------------------------------------------------------------"

    puts "---------------------------------------------------------------------"
    puts "Multiple Product With Same Sku in Same Quote #{multiple_sku_quote}"
    puts "---------------------------------------------------------------------"

    puts "---------------------------------------------------------------------"
    puts "Tax Rate is Different with Sales Quote Row #{tax_rate_different}"
    puts "---------------------------------------------------------------------"
  end

  attr_accessor :order_number
end