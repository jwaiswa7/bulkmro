json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      row_action_button(customers_order_path(sales_order), 'eye', 'View Sales Order', 'info'),
                      row_action_button(customers_order_path(sales_order, format: :pdf), 'file-pdf', 'Download Sales Order', 'dark', :_blank)
                  ].join(' '),
                  sales_order.order_number,
                  sales_order.inquiry.inquiry_number,
                  format_date(sales_order.created_at),
                  sales_order.inquiry.customer_po_number,
                  sales_order.inquiry.company.to_s,
                  format_currency(sales_order.calculated_total),
                  format_currency(sales_order.calculated_total),
                  sales_order_format_label(sales_order.status.to_s),
              ]
end

json.recordsTotal @sales_orders.all.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]