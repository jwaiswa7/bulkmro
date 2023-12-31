json.data (@customer_orders) do |customer_order|
  json.array! [

                  [
                      row_action_button(customers_customer_order_path(customer_order), 'fal fa-eye', 'View Order Contents', 'info'),
                      if customer_order.pending?
                        row_action_button(customers_customer_order_path(customer_order), 'comment-alt-check', 'Comments and Approval', 'success')
                      end
                  ].join(' '),
                  status_badge(customer_order.status),
                  customer_order.online_order_number,
                  customer_order.customer_po_sheet.attached? ? link_to(["<i class='fal fa-file-alt mr-1'></i>", customer_order.customer_po_sheet.filename].join('').html_safe, customer_order.customer_po_sheet, target: '_blank') : '-',
                  customer_order.rows.count,
                  format_date(customer_order.created_at),
                  customer_order.contact.name,
                  format_currency(customer_order.calculated_total),
                  format_currency(customer_order.grand_total(for_order: true)),
              ]
end

json.recordsTotal @customer_orders.model.all.count
json.recordsFiltered @customer_orders.total_count
json.draw params[:draw]
