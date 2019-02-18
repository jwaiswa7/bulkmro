json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if policy(purchase_order).show?
                        row_action_button(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(purchase_order).show_document?
                        row_action_button(url_for(purchase_order.document), 'file-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,
                  ].join(' '),
                  link_to(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry), target: '_blank'),
                  link_to(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), target: '_blank'),
                  (purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if purchase_order.rows.present?),
                  (purchase_order.inquiry.company.try(:name) if purchase_order.inquiry.company.present?),
                  purchase_order.status || purchase_order.metadata_status,
                  purchase_order.rows.count,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  purchase_order.inquiry.outside_sales_owner.to_s,
                  format_date(purchase_order.created_at)
              ]
end

json.recordsTotal PurchaseOrder.all.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
