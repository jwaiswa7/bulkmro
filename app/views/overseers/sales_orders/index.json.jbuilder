json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if policy(sales_order).show?
                        row_action_button(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'eye', 'View Sales Order', 'info')
                      end,
                      if policy(sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'comment-alt-check', 'Comments and Approval', 'success')
                      end,
                      if policy(sales_order).go_to_inquiry?
                        row_action_button(edit_overseers_inquiry_path(sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'dark')
                      end
                  ].join(' '),
                  sales_order.order_number,
                  sales_order.id,
                  sales_order.inquiry.inquiry_number,
                  sales_order_status_badge(format_enum(sales_order.status || sales_order.legacy_request_status, humanize_text: false)),
                  format_enum(sales_order.remote_status, humanize_text: false),
                  format_date(sales_order.sent_at),
                  sales_order.created_by.to_s,
                  sales_order.inside_sales_owner.to_s,
                  sales_order.outside_sales_owner.to_s,
                  format_currency(sales_order.sales_quote.calculated_total),
                  format_currency(sales_order.calculated_total),
                  format_date(sales_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       SalesOrder.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       SalesOrder.remote_statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       [],
                       []
                   ]


json.recordsTotal SalesOrder.all.count
json.recordsFiltered @indexed_sales_orders.total_count
# json.recordsTotal @inquiries.model.all.count
# json.recordsFiltered @inquiries.total_count
json.draw params[:draw]