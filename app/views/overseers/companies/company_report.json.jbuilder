json.data (@indexed_company_reports) do |inquiry|
  json.array! [
                  [],
                  link_to(Company.find(inquiry.attributes['company_key']).name, overseers_company_path(inquiry.attributes['company_key']), target: '_blank'),
                  link_to(inquiry.attributes['account'], overseers_account_path(inquiry.attributes['account_id']), target: '_blank'),
                  number_with_delimiter(inquiry.attributes['live_inquiries'].to_i, delimiter: ','),
                  number_with_delimiter(inquiry.attributes['sales_quote_count'].to_i, delimiter: ','),
                  format_currency(inquiry.attributes['final_sales_quotes'].present? ? inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total'].to_f}.sum : 0 ) ,
                  number_with_delimiter(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].count : 0, delimiter: ',') ,
                  format_currency(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  number_with_delimiter(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].count : 0, delimiter: ','),
                  format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin'].to_f}.sum : 0),
                  if inquiry.attributes['final_sales_orders'].present?
                    percentage(inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum  / inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.count)
                  else
                    percentage(0.0)
                  end,
                  (number_with_delimiter(inquiry.attributes['invoices'].count, delimiter: ',') if inquiry.attributes['invoices'].present?),
                  format_currency(inquiry.attributes['invoices'].present? ? inquiry.attributes['invoices'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  if inquiry.attributes['final_sales_quotes'].present?
                    percentage(inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum / inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.count )
                  else
                    percentage(0.0)
                  end,
                  number_with_delimiter(inquiry.attributes['cancelled_invoiced'].count, delimiter: ','),
                  format_currency(inquiry.attributes['cancelled_invoiced'].present? ? inquiry.attributes['cancelled_invoiced'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  number_with_delimiter(inquiry.attributes['sku'].to_i, delimiter: ','),
              ]
end

json.columnFilters [
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal Company.count
json.recordsFiltered @indexed_company_reports.total_count
json.draw params[:draw]
json.indexed_records @indexed_company_reports