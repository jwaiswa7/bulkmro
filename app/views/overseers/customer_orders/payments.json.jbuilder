# frozen_string_literal: true

json.data (@payments) do |payment|
  json.array! [
                  [
                      row_action_button(overseers_customer_order_path(payment.customer_order), 'eye', 'View Customer Order', 'info', :_blank),
                      row_action_button(refresh_payment_overseers_customer_orders_path(payment_id: payment.to_param), 'sync', 'Refresh', 'success')
                  ].join(' '),
                  status_badge(payment.status),
                  payment.customer_order.online_order_number,
                  payment.payment_id,
                  format_currency((payment.amount / 100)),
                  format_succinct_date(payment.created_at)
              ]
end

json.recordsTotal @payments.all.count
json.recordsFiltered @payments.total_count
json.draw params[:draw]
