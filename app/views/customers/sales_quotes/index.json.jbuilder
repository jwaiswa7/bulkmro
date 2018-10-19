json.data (@sales_quotes) do |sales_quote|
  json.array! [
                  [
                      # row_action_button(overseers_inquiry_sales_quotes_path(sales_quote.inquiry), 'arrow-right', 'Go to Inquiry', 'dark')
                  ].join(' '),
                  format_date(sales_quote.sent_at),
                  sales_quote.created_by.to_s,
                  sales_quote.rows.size,
                  format_currency(sales_quote.calculated_total),
                  format_currency(sales_quote.calculated_total_with_tax),
                  format_date(sales_quote.created_at)
              ]
end

json.recordsTotal @sales_quotes.all.count
json.recordsFiltered @sales_quotes.total_count
json.draw params[:draw]