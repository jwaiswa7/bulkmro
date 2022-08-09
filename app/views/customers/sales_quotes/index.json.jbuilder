json.data (@sales_quotes) do |sales_quote|
  json.array! [
                  [
                      row_action_button(customers_quote_path(sales_quote), 'eye', 'View Quote', 'info', :_blank),
                      if !is_api_request?
                        row_action_button(customers_quote_path(sales_quote, format: :pdf), 'file-pdf', 'Download Quote', 'dark', :_blank)
                      end
                  ].join(' '),
                  sales_quote.inquiry.inquiry_number,
                  format_date(sales_quote.created_at),
                  sales_quote.rows.size,
                  format_currency(sales_quote.calculated_total),
                  sales_quote.inquiry.inside_sales_owner.to_s,
                  status_badge(sales_quote.changed_status(sales_quote.inquiry.status)),
                  format_succinct_date(sales_quote.created_at),
                  format_date(sales_quote.inquiry.valid_end_time)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @sales_quotes.count
json.recordsFiltered @indexed_sales_quotes.total_count
json.draw params[:draw]
