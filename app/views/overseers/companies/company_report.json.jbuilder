json.data (@indexed_company_reports) do |inquiry|
  json.array! [
                  [],
                  link_to(inquiry.attributes['name'], overseers_company_path(inquiry.attributes['company_key']), target: '_blank'),
                  link_to(inquiry.attributes['account'], overseers_account_path(inquiry.attributes['account_id']), target: '_blank'),
                  link_to(number_with_delimiter(inquiry.attributes['live_inquiries'].to_i, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company',inquiry.attributes['name'],inquiry.attributes['company_key'])]), target: '_blank'),
                  number_with_delimiter(inquiry.attributes['sales_quote_count'].to_i, delimiter: ','),
                  format_currency(inquiry.attributes['final_sales_quotes'].present? ? inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total'].to_f}.sum : 0 ) ,
                  link_to(number_with_delimiter(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].count : 0, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company',inquiry.attributes['name'],inquiry.attributes['company_key']), filter_by_value('Status','Expected Order',7)]), target: '_blank') ,
                  format_currency(inquiry.attributes['expected_order'].present? ? inquiry.attributes['expected_order'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  link_to(number_with_delimiter(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].count : 0, delimiter: ','), filtered_path(overseers_sales_orders_path, [filter_by_value('Account',inquiry.attributes['account'],inquiry.attributes['account_id'])]), target: '_blank'),
                  format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  format_currency(inquiry.attributes['final_sales_orders'].present? ? inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin'].to_f}.sum : 0),
                  if inquiry.attributes['final_sales_orders'].present?
                    percentage(inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum  / inquiry.attributes['final_sales_orders'].map{|f| f['calculated_total_margin_percentage'].to_f}.count)
                  else
                    percentage(0.0)
                  end,
                  link_to((number_with_delimiter(inquiry.attributes['invoices'].count, delimiter: ',') if inquiry.attributes['invoices'].present?), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company',inquiry.attributes['name'],inquiry.attributes['company_key'])]), target: '_blank'),
                  format_currency(inquiry.attributes['invoices'].present? ? inquiry.attributes['invoices'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  if inquiry.attributes['final_sales_quotes'].present?
                    percentage(inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.sum / inquiry.attributes['final_sales_quotes'].map{|f| f['calculated_total_margin_percentage'].to_f}.count )
                  else
                    percentage(0.0)
                  end,
                  link_to(number_with_delimiter(inquiry.attributes['cancelled_invoiced'].count, delimiter: ','), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company',inquiry.attributes['name'],inquiry.attributes['company_key']), filter_by_value('Status','Cancelled',3)]), target: '_blank'),
                  format_currency(inquiry.attributes['cancelled_invoiced'].present? ? inquiry.attributes['cancelled_invoiced'].map{|f| f['calculated_total'].to_f}.sum : 0),
                  number_with_delimiter(inquiry.attributes['sku'].to_i, delimiter: ','),
              ]
end

json.columnFilters [
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       [{"source": autocomplete_overseers_accounts_path}],
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