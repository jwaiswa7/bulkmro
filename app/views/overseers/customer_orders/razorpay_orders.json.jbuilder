json.data (@order_records) do |order|
  json.array! [
                  [
                      row_action_button_without_fa(order_data_overseers_customer_order_path(order['id']), 'bmro-icon-table bmro-icon-used-view', 'View Order Payments', 'info')
                  ].join(' '),
                  status_badge(order['status']),
                  order['id'],
                  order['amount'].present? ? format_currency((order['amount'] / 100)) : 0,
                  order['amount_due'].present? ? format_currency((order['amount_due'] / 100)) : 0,
                  order['amount_paid'].present? ? format_currency((order['amount_paid'] / 100)) : 0
              ]
end

json.recordsTotal @order_records.count
json.recordsFiltered @order_records.total_count
json.draw params[:draw]
