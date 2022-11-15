json.data (@sales_quotes) do |sales_quote|
  columns = [
                  [
                      row_action_button(customers_quote_path(sales_quote), 'eye', 'View Quote', 'info', :_blank),
                      if !is_api_request?
                        row_action_button(customers_quote_path(sales_quote, format: :pdf), 'file-pdf', 'Download Quote', 'dark', :_blank)
                      end
                  ].join(' '),
                  if policy(current_customers_contact).admin_columns?
                  sales_quote.company&.to_s
                  end,
                  if policy(current_customers_contact).admin_columns?
                  sales_quote.inquiry&.contact&.to_s
                  end,
                  sales_quote.inquiry.inquiry_number,
                  format_date(sales_quote.created_at),
                  sales_quote.rows.size,
                  format_currency(sales_quote.calculated_total),
                  sales_quote.inquiry.inside_sales_owner.to_s,
                  status_badge(sales_quote.changed_status(sales_quote.inquiry.status)),
                  format_date(sales_quote.created_at),
                  format_date(sales_quote.inquiry.valid_end_time)
                ]
  2.times{columns.delete_at(1)} unless policy(current_customers_contact).admin_columns?
  json.merge! columns
end

json.columnFilters [
                       [],
                       @sales_quotes.map{ |sales_quote| {label: sales_quote.company.to_s, value: sales_quote.company.id}}.uniq,
                       [{ "source": autocomplete_overseers_company_contacts_path(current_company) }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal SalesQuote.all.count
json.recordsFiltered @indexed_sales_quotes.total_count
json.draw params[:draw]
