json.data (@sales_orders) do |sales_order|
  columns = [
      [
          if policy(sales_order).show?
            row_action_button(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'eye', 'View Sales Order', 'info')
          end,
          if policy(sales_order).comments?
            row_action_button(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'comment-alt-check', 'Comments and Approval', 'success')
          end
      ].join(' '),
      sales_order.order_number.present? ? conditional_link(sales_order.order_number, overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), policy(sales_order.inquiry).show?) : "",
      sales_order.id,
      conditional_link(sales_order.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_order.inquiry), policy(sales_order.inquiry).edit?),
      status_badge(format_enum(sales_order.order_status || sales_order.legacy_request_status, humanize_text: false)),
      format_succinct_date(sales_order.sent_at),
      sales_order.created_by.to_s,
      sales_order.inside_sales_owner.to_s,
      sales_order.outside_sales_owner.to_s,
      [sales_order.calculated_total_margin_percentage, '%'].join(''),
      format_currency(sales_order.sales_quote.calculated_total),
      format_currency(sales_order.calculated_total),
      format_succinct_date(sales_order.created_at)
  ]

  columns = Hash[columns.collect.with_index {|item, index| [index, item]}]
  json.merge! columns.merge({"DT_RowClass": sales_order.calculated_total_margin_percentage.to_f < 10 ? "bg-highlight-danger" : ''})
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       SalesOrder.statuses.except("Approved","Cancelled").map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       SalesOrder.remote_statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
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
json.status @indexed_sales_orders
json.recordsSummary SalesOrder.statuses.map {|status, status_id| {:status_id => status_id ,:"label" => status, :"size" => @statuses[status_id]}}.as_json
json.recordsTotalValue @total_values