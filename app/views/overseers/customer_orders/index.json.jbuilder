json.data (@customer_orders) do |customer_order|
  json.array! [
                  [
                      if policy(customer_order).show?
                        row_action_button(overseers_customer_order_path(customer_order), 'eye', 'View Customer Order', 'info', :_blank)
                      end,
                      if policy(customer_order).can_create_inquiry?
                        row_action_button(new_overseers_customer_order_inquiry_path(customer_order), 'plus-circle', 'Create Inquiry', 'success', :_blank)
                      elsif policy(customer_order.inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(customer_order.inquiry), 'pencil', 'View Inquiry', 'warning', :_blank)
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