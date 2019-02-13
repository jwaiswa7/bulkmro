

json.data (@customer_orders) do |customer_order|
  json.array! [
                  [
                      if policy(customer_order).show?
                        row_action_button(overseers_customer_order_path(customer_order), 'eye', 'View Customer Order', 'info', :_blank)
                      end,
                      if policy(customer_order).can_create_inquiry?
                        row_action_button(new_overseers_customer_order_inquiry_path(customer_order), 'plus-circle', 'Create Inquiry', 'success', :_blank)
                      elsif customer_order.inquiry.present? && policy(customer_order.inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(customer_order.inquiry), 'pencil', 'View Inquiry', 'warning', :_blank)
                      end
                  ].join(' '),
                  customer_order.online_order_number,
                  status_badge(customer_order.status),
                  customer_order.payment_method,
                  conditional_link(customer_order.contact.account.name, overseers_account_path(customer_order.contact.account), policy(customer_order.contact.account).show?),
                  customer_order.company.present? ? conditional_link(customer_order.company.name, overseers_company_path(customer_order.company), policy(customer_order.company).show?) : '-',
                  customer_order.contact.full_name,
                  customer_order.rows.count,
                  format_currency(customer_order.calculated_total),
                  format_currency(customer_order.grand_total),
                  customer_order.company.present? && customer_order.company.inside_sales_owner.present? ? customer_order.company.inside_sales_owner.full_name : '-',
                  customer_order.company.present? && customer_order.company.outside_sales_owner.present? ? customer_order.company.outside_sales_owner.full_name : '-',
                  customer_order.company.present? && customer_order.company.sales_manager.present? ? customer_order.company.sales_manager.full_name : '-',
                  format_succinct_date(customer_order.created_at)
              ]
end

json.recordsTotal @customer_orders.model.all.count
json.recordsFiltered @customer_orders.count
json.draw params[:draw]
