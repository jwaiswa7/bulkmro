json.data (@inquiries) do |inquiry|
  json.array! [
                  [],
                  inquiry.inside_sales_owner.to_s,
                  status_badge(inquiry.status),
                  link_to(inquiry.inquiry_number, edit_overseers_inquiry_path(inquiry), target: '_blank'),
                  format_succinct_date(inquiry.created_at),
                  inquiry.final_sales_quote.present? ? format_currency(inquiry.final_sales_quote.calculated_total) : '-',
                  inquiry.final_sales_quote.present? ? format_succinct_date(inquiry.final_sales_quote.created_at) : '-',
                  inquiry.final_sales_orders.present? ? inquiry.final_sales_orders.map { |order| format_currency(order.calculated_total)}.compact.join('<br/>') : '-',
                  inquiry.final_sales_orders.present? ? inquiry.final_sales_orders.map { |order| format_succinct_date(order.created_at)}.compact.join('<br/>') : '-',
                  inquiry.final_sales_orders.present? ? inquiry.final_sales_orders.map { |order| percentage(order.calculated_total_margin_percentage)}.compact.join('<br/>') : '-',
                  inquiry.final_sales_orders.present? ? inquiry.final_sales_orders.map { |order| format_currency(order.calculated_total_margin)}.compact.join('<br/>') : '-',
                  inquiry.invoices.count,
                  inquiry.invoices.present? ? inquiry.invoices.map { |invoice| invoice.mis_date}.uniq.compact.join('<br/>') : '-'
              ]
end

json.columnFilters [
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
                       Inquiry.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
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
