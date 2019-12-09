json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if is_authorized(sales_order,'show')
                        row_action_button_without_fa(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'bmro-icon-table bmro-icon-used-view', 'View Sales Order', 'info', :_blank)
                      end,
                      if is_authorized(sales_order,'comments')
                        row_action_button_without_fa(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'bmro-icon-table bmro-icon-comment', 'Comments and Approval', 'success', :_blank)
                      end,
                      if is_authorized(sales_order,'go_to_inquiry') && policy(sales_order).go_to_inquiry?
                       row_action_button_without_fa(edit_overseers_inquiry_path(sales_order.inquiry), 'bmro-icon-table bmro-icon-comments-approval', 'Go to Inquiry', 'dark', :_blank)
                      end,
                      if is_authorized(sales_order,'edit_mis_date')
                        row_action_button_without_fa(edit_mis_date_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'bmro-icon-table bmro-icon-calender', 'Update MIS Date', 'success', :_blank)
                      end,
                      if is_authorized(sales_order,'can_request_po')
                        row_action_button_without_fa(new_purchase_orders_requests_overseers_sales_order_path(sales_order.to_param), 'bmro-icon-table bmro-icon-file', 'PO Request', 'success', :_blank)
                      end,
                      if is_authorized(sales_order,'can_request_invoice')
                       row_action_button_without_fa(new_overseers_invoice_request_path(sales_order_id: sales_order.to_param), 'bmro-icon-table bmro-icon-dollar', 'GRPO Request', 'success', :_blank)
                      end,
                      if is_authorized(sales_order.sales_quote,'new_freight_request') && policy(sales_order.sales_quote).new_freight_request?
                        row_action_button_without_fa(new_overseers_freight_request_path(sales_order_id: sales_order.to_param), 'bmro-icon-table bmro-icon-new-freight', 'New Freight Request', 'warning')
                      end
                  ].join(' '),
                  sales_order.order_number.present? ? conditional_link(sales_order.order_number, overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), is_authorized(sales_order.inquiry,'show')) : '-',
                  conditional_link(sales_order.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_order.inquiry), is_authorized(sales_order.inquiry,'edit')),
                  status_badge(format_enum(sales_order.order_status, humanize_text: false)),
                  status_badge(format_enum(sales_order.remote_status, humanize_text: false)),
                  conditional_link(sales_order.inquiry.company.account.name, overseers_account_path(sales_order.inquiry.company.account), is_authorized(sales_order.inquiry.company.account,'show')),
                  sales_order.inside_sales_owner.to_s,
                  sales_order.outside_sales_owner.to_s,
                  format_currency(sales_order.sales_quote.calculated_total),
                  format_currency(sales_order.calculated_total),
                  format_currency(sales_order.invoice_total),
                  format_succinct_date(sales_order.mis_date),
                  format_succinct_date(sales_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       SalesOrder.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       SalesOrder.remote_statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [],
                       []
                   ]


json.recordsTotal SalesOrder.remote_approved.count
json.recordsFiltered @indexed_sales_orders.total_count
json.recordsTotalValue @total_values
json.draw params[:draw]
json.recordsSummary SalesOrder.remote_statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsOverallStatusCount @statuses_count
json.recordsOverallStatusValue @not_invoiced_total
