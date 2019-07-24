json.data (@inquiries) do |inquiry|
  json.array! [
                  [],
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  status_badge(inquiry.status),
                  link_to(inquiry.inquiry_number, edit_overseers_inquiry_path(inquiry), target: '_blank'),
                  format_succinct_date(inquiry.created_at),
                  inquiry.final_sales_quotes.present? ? inquiry.final_sales_quotes.map{ |quote| number_with_delimiter(quote.calculated_total.to_i, delimiter: ',') }.compact.join('<br/>') : '-',
                  inquiry.final_sales_quotes.present? ? inquiry.final_sales_quotes.map{ |quote| format_succinct_date(quote.created_at) }.compact.join('<br/>') : '-',

                  if inquiry.bible_sales_orders.present?
                    inquiry.bible_sales_orders.map { |order| number_with_delimiter(order.calculated_total.to_i, delimiter: ',')}.compact.join('<br/>')
                  elsif inquiry.total_sales_orders.present?
                    inquiry.total_sales_orders.map { |order| number_with_delimiter(order.calculated_total.to_i, delimiter: ',')}.compact.join('<br/>')
                  end,
                  if inquiry.bible_sales_orders.present?
                    inquiry.bible_sales_orders.map { |order| format_succinct_date(order.mis_date)}.compact.join('<br/>')
                  elsif inquiry.total_sales_orders.present?
                    inquiry.total_sales_orders.map { |order| format_succinct_date(order.created_at)}.compact.join('<br/>')
                  end,
                  if inquiry.bible_sales_orders.present?
                    inquiry.bible_sales_orders.map { |order| order.overall_margin_percentage }.compact.join('<br/>')
                  elsif inquiry.total_sales_orders.present?
                    inquiry.total_sales_orders.map { |order| order.calculated_total_margin_percentage }.compact.join('<br/>')
                  end,
                  if inquiry.bible_sales_orders.present?
                    inquiry.bible_sales_orders.map { |order| number_with_delimiter(order.total_margin.to_i, delimiter: ',')}.compact.join('<br/>')
                  elsif inquiry.total_sales_orders.present?
                    inquiry.total_sales_orders.map { |order| number_with_delimiter(order.calculated_total_margin.to_i, delimiter: ',')}.compact.join('<br/>')
                  end,
                  if inquiry.bible_sales_invoices.present?
                    number_with_delimiter(inquiry.bible_sales_invoices.count, delimiter: ',')
                  else
                    number_with_delimiter(inquiry.invoices.count, delimiter: ',')
                  end,
                  if inquiry.bible_sales_invoices.present?
                    inquiry.bible_sales_invoices.map { |invoice| invoice.mis_date}.uniq.compact.join('<br/>')
                  elsif inquiry.invoices.present?
                    inquiry.invoices.map { |invoice| invoice.mis_date}.uniq.compact.join('<br/>')
                  end
              ]
end

json.columnFilters [
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       Inquiry.statuses.except('Lead by O/S').map { |k, v| { "label": k, "value": v.to_s } }.as_json,
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

json.recordsTotal @indexed_inquiries.total_count
json.recordsFiltered @indexed_inquiries.count
json.draw params[:draw]
