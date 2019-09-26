json.data (@customer_orders) do |customer_order|
  json.array! [
                  [
                      if is_authorized(customer_order, 'show') && policy(customer_order).show?
                        row_action_button_without_fa(overseers_customer_order_path(customer_order), 'bmro-icon-table bmro-icon-used-view', 'View Customer Order', 'info', :_blank)
                      end,
                      if is_authorized(customer_order, 'can_create_inquiry') && policy(customer_order).can_create_inquiry?
                        row_action_button_without_fa(new_overseers_customer_order_inquiry_path(customer_order), 'bmro-icon-table bmro-icon-circle', 'Create Inquiry', 'success', :_blank)
                      elsif customer_order.inquiry.present? && is_authorized(customer_order.inquiry, 'edit') && policy(customer_order.inquiry).edit?
                        row_action_button_without_fa(edit_overseers_inquiry_path(customer_order.inquiry), 'bmro-icon-table bmro-icon-pencil', 'View Inquiry', 'warning', :_blank)
                      end
                  ].join(' '),
                  customer_order.online_order_number,
                  status_badge(customer_order.status),
                  customer_order.payment_method,
                  conditional_link(customer_order.contact.account.name, overseers_account_path(customer_order.contact.account), is_authorized(customer_order.contact.account, 'show')),
                  customer_order.company.present? ? conditional_link(customer_order.company.name, overseers_company_path(customer_order.company), is_authorized(customer_order.company, 'show')) : '-',
                  customer_order.contact.full_name,
                  customer_order.rows.count,
                  format_currency(customer_order.calculated_total),
                  format_currency(customer_order.grand_total(for_order: true)),
                  customer_order.company.present? && customer_order.company.inside_sales_owner.present? ? customer_order.company.inside_sales_owner.full_name : '-',
                  customer_order.company.present? && customer_order.company.outside_sales_owner.present? ? customer_order.company.outside_sales_owner.full_name : '-',
                  customer_order.company.present? && customer_order.company.sales_manager.present? ? customer_order.company.sales_manager.full_name : '-',
                  format_succinct_date(customer_order.created_at)
              ]
end

json.recordsTotal @customer_orders.model.all.count
json.recordsFiltered @customer_orders.total_count
json.draw params[:draw]
