json.data (@sales_quotes) do |sales_quote|
  json.array! [
                  [
                      row_action_button(customers_quote_path(sales_quote), 'eye', 'View Quote', 'info'),
                      row_action_button(customers_quote_path(sales_quote, format: :pdf), 'file-pdf', 'Download Quote', 'dark', :_blank)
                  ].join(' '),
                  sales_quote.inquiry.inquiry_number,
                  format_date(sales_quote.created_at),
                  sales_quote.rows.size,
                  format_currency(sales_quote.calculated_total),
                  sales_quote.inquiry.inside_sales_owner.to_s,
                  format_date(sales_quote.inquiry.valid_end_time),
                  inquiry_status_badge(sales_quote.inquiry.status),
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       Inquiry.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json
                   ]

json.recordsTotal @sales_quotes.count
json.recordsFiltered @indexed_sales_quotes.total_count
json.draw params[:draw]