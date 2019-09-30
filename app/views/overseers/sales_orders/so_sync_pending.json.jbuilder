json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if is_authorized(sales_order, 'show')
                        row_action_button_without_fa(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'bmro-icon-table bmro-icon-used-view', 'View Sales Order', 'info')
                      end,
                      if is_authorized(sales_order, 'resync')
                        row_action_button_without_fa(resync_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'bmro-icon-table bmro-icon-resync', 'Resync with SAP', 'danger', :_self, :post)
                      end,
                      if is_authorized(sales_order, 'comments')
                        row_action_button_without_fa(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'bmro-icon-table bmro-icon-comment', 'Comments and Approval', 'success')
                      end,
                      if is_authorized(sales_order, 'go_to_inquiry') && policy(sales_order).go_to_inquiry?
                        row_action_button_without_fa(edit_overseers_inquiry_path(sales_order.inquiry), 'bmro-icon-table bmro-icon-comments-approval', 'Go to Inquiry', 'dark')
                      end
                  ].join(' '),
                  sales_order.id,
                  conditional_link(sales_order.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_order.inquiry), policy(sales_order.inquiry).edit?),
                  sales_order.order_number,
                  status_badge(format_enum(sales_order.order_status || sales_order.legacy_request_status, humanize_text: false)),
                  format_succinct_date(sales_order.sent_at),
                  sales_order.approval.present? ? format_date_time_meridiem(sales_order.approval.created_at) : '-',
                  sales_order.created_by.to_s,
                  sales_order.inside_sales_owner.to_s,
                  sales_order.outside_sales_owner.to_s,
                  format_succinct_date(sales_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesOrder.remote_statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [],
                       []
                   ]


json.recordsTotal @sales_orders.count
json.recordsFiltered @drafts_pending_count
json.draw params[:draw]
