json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if policy(sales_order).edit?
                        row_action_button(edit_overseers_inquiry_sales_order_path(@inquiry, sales_order), 'pencil', 'Edit Sales Order', 'warning')
                      elsif policy(sales_order).new_revision?
                        row_action_button(new_revision_overseers_inquiry_sales_order_path(@inquiry, sales_order), 'redo-alt', 'New Sales Order Revision', 'warning')
                      end,
                      if policy(sales_order).show?
                        row_action_button(overseers_inquiry_sales_order_path(@inquiry, sales_order), 'eye', 'View Sales Order', 'dark')
                      end,
                      if policy(sales_order).comments?
                        row_action_button(overseers_inquiry_comments_path(@inquiry, sales_order_id: sales_order.to_param), 'comment-lines', 'See Comments', 'success')
                      end,
                      if policy(sales_order).resync?
                        row_action_button(resync_overseers_inquiry_sales_order_path(@inquiry, sales_order), 'retweet-alt', 'Resync with SAP', 'danger', :_self, :post)
                      end,
                      if policy(sales_order).show?
                        row_action_button(overseers_inquiry_sales_order_path(@inquiry, sales_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(sales_order).show_serialized?
                        row_action_button(url_for(sales_order.serialized_pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                  ].join(' '),
                  sales_order.order_number,
                  format_enum(sales_order.status),
                  format_enum(sales_order.remote_status),
                  format_date(sales_order.sent_at),
                  sales_order.created_by.to_s,
                  sales_order.rows.size,
                  format_currency(sales_order.sales_quote.calculated_total),
                  format_currency(sales_order.calculated_total),
                  format_date(sales_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       SalesOrder.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       SalesOrder.remote_statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]



json.recordsTotal SalesOrder.all.count
json.recordsFiltered @indexed_sales_orders.total_count
# json.recordsTotal @inquiries.model.all.count
# json.recordsFiltered @inquiries.total_count
json.draw params[:draw]