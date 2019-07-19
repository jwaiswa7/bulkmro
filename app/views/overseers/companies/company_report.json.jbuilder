json.data (@indexed_company_reports) do |company|
  json.array! [
                  [],
                  link_to(Company.find(company['key']).name, overseers_company_path(Company.find(company['key']).name), target: '_blank'),
                  link_to(Company.find(company['key']).account.to_s, overseers_account_path(Company.find(company['key']).account), target: '_blank'),
                  if @date_range.present?
                    link_to(number_with_delimiter(company['inquiries_size']['value'].to_i, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                  else
                    link_to(number_with_delimiter(company['live_inquiries']['value'].to_i, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id)]), target: '_blank')
                  end,
                  number_with_delimiter(company['sales_quotes']['value'].to_i, delimiter: ','),
                  format_currency(company['sales_quotes_total']['value'].to_i, precision: 0, show_symbol: false),
                  if @date_range.present?
                    link_to(number_with_delimiter(company['expected_orders']['value'].to_i, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company',  Company.find(company['key']).name, Company.find(company['key']).id), filter_by_value('Status', 'Expected Order', 7), filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                  else
                    link_to(number_with_delimiter(company['expected_orders']['value'].to_i, delimiter: ','), filtered_path(overseers_inquiries_path, [filter_by_value('Company',  Company.find(company['key']).name, Company.find(company['key']).id), filter_by_value('Status', 'Expected Order', 7)]), target: '_blank')
                  end,
                  format_currency(company['expected_orders_total']['value'].to_i, precision: 0, show_symbol: false),
                    # if @date_range.present?
                    #   link_to(number_with_delimiter(company['sales_orders']['value'].to_i, delimiter: ','), filtered_path(overseers_sales_orders_path, [filter_by_value('Account', Company.find(company['key']).account.to_s, Company.find(company['key']).account.id),filter_by_date_range('Date+of+inquiry', @date_range)]), target: '_blank')
                    # else
                    link_to(number_with_delimiter(company['sales_orders']['value'].to_i, delimiter: ','), filtered_path(overseers_sales_orders_path, [filter_by_value('Account', Company.find(company['key']).account.to_s, Company.find(company['key']).account.id)]), target: '_blank'),
                  # end,
                  format_currency(company['sales_orders_total']['value'].to_i, precision: 0, show_symbol: false),
                  format_currency(company['sales_orders_margin']['value'].to_i, precision: 0, show_symbol: false),
                  if company['sales_orders']['value'].to_i != 0
                    percentage(company['sales_orders_margin_percentage']['value'].to_f / company['sales_orders']['value'].to_i, show_symbol: false)
                  else
                    percentage(0.0, show_symbol: false)
                  end,
                    # if @date_range.present?
                    #   link_to((number_with_delimiter(company['sales_invoices']['value'].to_i, delimiter: ',')), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id),filter_by_date_range('Invoice+Date', @date_range)]), target: '_blank')
                    # else
                    link_to((number_with_delimiter(company['sales_invoices']['value'].to_i, delimiter: ',')), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id)]), target: '_blank'),
                  # end,
                  format_currency(company['sales_invoices_total']['value'].to_i, precision: 0, show_symbol: false),
                  if company['sales_quotes']['value'].to_i != 0
                    percentage(company['sales_quotes_margin_percentage']['value'].to_f / company['sales_quotes']['value'].to_i, show_symbol: false)
                  else
                    percentage(0.0, show_symbol: false)
                  end,
                    # if @date_range.present?
                    #   link_to(number_with_delimiter(company['cancelled_invoiced']['value'].to_i, delimiter: ','), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id), filter_by_value('Status', 'Cancelled', 3),filter_by_date_range('Invoice+Date', @date_range)]), target: '_blank')
                    # else
                    link_to(number_with_delimiter(company['cancelled_invoiced']['value'].to_i, delimiter: ','), filtered_path(overseers_sales_invoices_path, [filter_by_value('Company', Company.find(company['key']).name, Company.find(company['key']).id), filter_by_value('Status', 'Cancelled', 3)]), target: '_blank'),
                  # end,
                  format_currency(company['cancelled_invoiced_total']['value'].to_i, precision: 0, show_symbol: false),
                  number_with_delimiter(company['sku']['value'].to_i, delimiter: ','),
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
