class Services::Shared::Migrations::MultipleSalesQuotesWithSameProduct < Services::Shared::Migrations::Migrations
  def merge_sales_quote_duplicate_product_rows
    service = Services::Shared::Spreadsheets::CsvImporter.new('one_product_with_multiple_times_in_sales_quotes.csv', 'seed_files')
    common_sales_quote_rows = []
    service.loop(nil) do |x|
      sales_quote_number = x.get_column('Sales Quote')
      product_sku = x.get_column('Product Sku')
      if sales_quote_number.present? && product_sku.present?
        sales_quote = SalesQuote.find(sales_quote_number.to_i)
        if sales_quote.present?
          sales_quote_rows = sales_quote.rows.joins(:product).where('products.sku = ?', product_sku)
          if sales_quote_rows.count > 1
            sales_quote_first_row = {
                                      converted_unit_selling_price: sales_quote_rows[0].converted_unit_selling_price,
                                      converted_total_selling_price: sales_quote_rows[0].converted_total_selling_price,
                                      converted_total_selling_price_with_tax: sales_quote_rows[0].converted_total_selling_price_with_tax,
                                      converted_unit_cost_price_with_unit_freight_cost: sales_quote_rows[0].converted_unit_cost_price_with_unit_freight_cost,
                                      tax_rate_id: sales_quote_rows[0].tax_rate_id
            }
            sales_quote_rows.drop(1).each do |sales_quote_row|
              puts "First: #{sales_quote_rows[0].converted_unit_selling_price}"
              puts "Second: #{sales_quote_row.converted_unit_selling_price}"
              if sales_quote_first_row['converted_unit_selling_price'] === sales_quote_row.converted_unit_selling_price &&
                 sales_quote_first_row['converted_total_selling_price'] === sales_quote_row.converted_total_selling_price &&
                 sales_quote_first_row['converted_total_selling_price_with_tax'] === sales_quote_row.converted_total_selling_price_with_tax &&
                 sales_quote_first_row['converted_unit_cost_price_with_unit_freight_cost'] === sales_quote_row.converted_unit_cost_price_with_unit_freight_cost
                 sales_quote_first_row['tax_rate_id'] === sales_quote_row.tax_rate_id
                common_sales_quote_rows.push(sales_quote_row.sales_quote_id)
              end
            end
          end
        end
      end
    end
    puts "*****************************"
    puts common_sales_quote_rows
    puts "*****************************"
  end
end