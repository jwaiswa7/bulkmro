class Services::Shared::Migrations::AddTaxTypeInSalesOrderRow < Services::Shared::Migrations::Migrations
  def add_tax_type_in_sales_order_row
    service = Services::Shared::Spreadsheets::CsvImporter.new('sales_order_with_vat_cst_service.csv', 'seed_files')
    multiple_sku_quote_product = "#{Rails.root}/tmp/tax_rate_script_issues.csv"
    headers = ['Inquiry', 'Order Number', 'Sales Quote', 'Product Sku', 'Duplicate SKU', 'No Of Count', 'Tax Different SO', 'Sales Quote Row Tax Code', 'Sheet Tax Rate']
    csv_data = CSV.generate(write_headers: true, headers: headers) do |writer|
      service.loop(nil) do |so_row|
        @order_number = so_row.get_column('So #')
        if order_number.present?
          sales_order = SalesOrder.where(order_number: order_number.to_i).last
          if sales_order.present?
            product_sku = so_row.get_column('Bm #')
            if product_sku.present?
              sales_quote_row = sales_order.sales_quote.rows.joins(:product).where('products.sku = ?', product_sku)
              sales_quote_count = sales_quote_row.count
              so_row_tax_rate = so_row.get_column('Tax Rate')
              if sales_quote_count == 1
                tax_type = so_row.get_column('Tax Type')
                if sales_quote_row.present? && tax_type.present?
                  if sales_quote_row.last.tax_rate.tax_percentage.to_f == so_row_tax_rate.gsub('%', '').to_f
                    sales_quote_row.last.update_attributes(tax_type: tax_type)
                    #updated_sales_quote << {inquiry: sales_order.inquiry.inquiry_number, sales_quote_id: sales_quote_row.last.sales_quote.id}
                  else
                    writer << [ sales_order.inquiry.inquiry_number, order_number, sales_order.sales_quote.id, product_sku, 'No', sales_quote_count, 'Yes', sales_quote_row.last.tax_rate.tax_percentage.to_f, so_row_tax_rate.gsub('%', '').to_f]
                  end
                end
              elsif sales_quote_count > 1
                writer << [ sales_order.inquiry.inquiry_number, order_number, sales_order.sales_quote.id, product_sku, 'Yes', sales_quote_count, 'No', '', '']
              end
            end
          end
        end
      end
    end
    temp_file = File.open(multiple_sku_quote_product, 'wb')
    temp_file.write(csv_data)
    temp_file.close
  end

  attr_accessor :order_number
end