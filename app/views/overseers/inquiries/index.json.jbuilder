json.data (@inquiries) do |inquiry|
  columns = [
      [
          if policy(inquiry).edit?
            row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
          end,
      ].join(' '),
      inquiry.inquiry_number,
      inquiry.sales_orders.where.not(order_number:nil).map{ |sales_order| link_to(sales_order.order_number, overseers_inquiry_sales_order_path(inquiry, sales_order), target: "_blank") }.compact.join(' '),
      inquiry.invoices.map{ |invoice| link_to(invoice.invoice_number, overseers_inquiry_sales_invoices_path(inquiry), target: "_blank") }.compact.join(' '),
      inquiry_status_badge(inquiry.status),
      inquiry.account.to_s,
      inquiry.company.to_s,
      inquiry.subject,
      inquiry.contact.to_s,
      inquiry.inside_sales_owner.to_s,
      inquiry.outside_sales_owner.to_s,
      format_currency(inquiry.final_sales_quote.try(:calculated_total)),
      format_date(inquiry.created_at)
  ]
  columns = Hash[columns.collect.with_index {|item, index| [index, item]}]
  json.merge! columns.merge({"DT_RowClass": inquiry.status == 'Order Won' ? "bg-highlight-success" : ''})
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       Inquiry.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       []
                   ]


json.recordsTotal Inquiry.all.count
json.recordsFiltered @indexed_inquiries.total_count
# json.recordsTotal @inquiries.model.all.count
# json.recordsFiltered @inquiries.total_count
json.draw params[:draw]