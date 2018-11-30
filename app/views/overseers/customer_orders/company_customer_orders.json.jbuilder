json.data (@customer_orders) do |customer_order|
  json.array! [
                  [
                      if policy(customer_order).show?
                        row_action_button(overseers_customer_orders_view_path(customer_order), 'eye', 'View customer_order', 'info')
                      end,
                      if policy(customer_order).edit?
                        row_action_button(new_from_customer_order_overseers_inquiries_path(company_id: customer_order.company.to_param, customer_order_id: customer_order.to_param), 'plus-circle', 'Create Inquiry', 'success')
                      end
                  ].join(' '),
                  customer_order.contact.account.name,
                  customer_order.company.present? ? customer_order.company.name : "-",
                  customer_order.contact.full_name,
                  customer_order.rows.count,
                  customer_order.company.present? && customer_order.company.inside_sales_owner.present? ? customer_order.company.inside_sales_owner.full_name : "-",
                  customer_order.company.present? && customer_order.company.outside_sales_owner.present? ? customer_order.company.outside_sales_owner.full_name : "-",
                  customer_order.company.present? && customer_order.company.sales_manager.present? ? customer_order.company.sales_manager.full_name : "-",
                  format_date(customer_order.created_at)
              ]
end

json.recordsTotal @customer_orders.model.all.count
json.recordsFiltered @customer_orders.count
json.draw params[:draw]