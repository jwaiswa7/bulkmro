json.data (@sales_quotes) do |sales_quote|
  json.array! [
                  [
                      if policy(sales_quote.inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(sales_quote.inquiry.to_param), 'pencil', 'Edit Inquiry', 'warning', target: '_blank')
                      end,
                  ].join(' '),
                  sales_quote.id,
                  format_succinct_date(sales_quote.sent_at),
                  sales_quote.created_by.to_s,
                  sales_quote.rows.size,
                  format_currency(sales_quote.calculated_total),
                  format_currency(sales_quote.calculated_total_with_tax),
                  format_succinct_date(sales_quote.created_at)
              ]
end

json.recordsTotal @company.sales_quotes.count
json.recordsFiltered @sales_quotes.total_count

json.draw params[:draw]

