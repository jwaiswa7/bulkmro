json.data (@sales_orders) do |sales_order|
  json.array! [
                 [
                     row_action_button_without_fa(new_accounts_confirmation_overseers_inquiry_sales_order_path(sales_order.inquiry.to_param, sales_order.to_param), 'bmro-icon-table bmro-icon-comment', 'Account Approval', 'warning'),
                     row_action_button_without_fa(overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order, format: :pdf), 'bmro-icon-table bmro-icon-pdf', 'Download', 'dark', :_blank)
                 ].join(' '),
                 sales_order.inquiry.inquiry_number,
                 sales_order.inquiry.company.to_s,
                 sales_order.inside_sales_owner.to_s,
                 sales_order.inquiry.billing_address.present? ? format_boolean(sales_order.inquiry.billing_address.is_sez) : '-',
                 sales_order.inquiry.bill_from.to_s,
                 sales_order.inquiry.inquiry_currency.present? ? sales_order.inquiry.inquiry_currency.currency.to_s : 'INR',
                 format_succinct_date(sales_order.created_at)
              ]
end

json.recordsTotal @sales_orders.count
json.recordsFiltered @sales_orders.total_count
json.draw params[:draw]