json.data (@purchase_order_queues) do |purchase_order_queue|
  json.array! [
                  [
                      if policy(purchase_order_queue).show?
                        row_action_button(overseers_inquiry_sales_order_path(purchase_order_queue.sales_order.inquiry, purchase_order_queue.sales_order), 'eye', 'View Sales Order', 'info')
                      end,
                      if policy(purchase_order_queue).edit?
                        #row_action_button(edit_overseers_purchase_order_queue_path(purchase_order_queue), 'pencil', 'Edit purchase_order_queue', 'warning')
                      end
                  ].join(' '),
                  purchase_order_queue.id,
                  format_date(purchase_order_queue.created_at),
                  purchase_order_queue.inquiry.inquiry_number,
                  purchase_order_queue.sales_order.order_number,
                  purchase_order_queue.inquiry.inside_sales_owner.to_s,
                  purchase_order_queue.status
              ]
end

json.recordsTotal @purchase_order_queues.model.all.count
json.recordsFiltered @purchase_order_queues.count
json.draw params[:draw]