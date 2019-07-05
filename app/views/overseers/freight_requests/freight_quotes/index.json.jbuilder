json.data (@freight_quotes) do |freight_quote|
  json.array! [
                  [
                      if is_authorized(freight_quote,'show')
                        row_action_button(overseers_freight_quote_path(freight_quote), 'eye', 'View Freight Quote', 'info')
                      end,
                      if is_authorized(freight_quote,'edit')
                        row_action_button(edit_overseers_freight_request_freight_quote_path(freight_quote.freight_request, freight_quote), 'pencil', 'Edit Freight Quote', 'warning')
                      end
                  ].join(' '),
                  freight_quote.id,
                  freight_quote.inquiry.inquiry_number,
                  freight_quote.freight_request.id,
                  format_date_time_meridiem(freight_quote.created_at),
                  if freight_quote.last_comment.present?
                    format_date_time_meridiem(freight_quote.last_comment.created_at)
                  end,
                  if freight_quote.last_comment.present?
                    format_comment(freight_quote.last_comment, trimmed: true)
                  end
              ]
end

json.recordsTotal @freight_quotes.model.all.count
json.recordsFiltered @freight_quotes.count
json.draw params[:draw]
