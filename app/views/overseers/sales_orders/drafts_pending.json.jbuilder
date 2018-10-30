json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if policy(sales_order).show?
                        row_action_button(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'eye', 'View Sales Order', 'dark')
                      end,
                      if policy(sales_order).resync?
                        row_action_button(resync_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'retweet-alt', 'Resync with SAP', 'danger', :_self, :post)
                      end,
                      if policy(sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'comment-lines', 'See Comments', 'dark')
                      end,
                      if policy(sales_order).go_to_inquiry?
                        row_action_button(overseers_inquiry_sales_orders_path(sales_order.inquiry), 'arrow-right', 'Go to Inquiry', 'dark')
                      end
                  ].join(' '),
                  sales_order.id,
                  sales_order.inquiry.inquiry_number,
                  sales_order_status_badge(format_enum(sales_order.status || sales_order.legacy_request_status, humanize_text: false)),
                  format_date(sales_order.sent_at),
                  sales_order.created_by.to_s,
                  sales_order.inside_sales_owner.to_s,
                  sales_order.outside_sales_owner.to_s,
                  format_date(sales_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesOrder.remote_statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       [],
                       []
                   ]


json.recordsTotal @sales_orders.count
json.recordsFiltered @drafts_pending_count
json.draw params[:draw]