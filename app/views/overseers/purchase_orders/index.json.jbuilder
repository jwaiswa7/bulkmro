json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if policy(purchase_order).show?
                        row_action_button(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(purchase_order).show_document?
                        row_action_button(url_for(purchase_order.document), 'file-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,

                      if policy(purchase_order).can_request_invoice?
                        row_action_button(new_overseers_invoice_request_path(:purchase_order_id => purchase_order.to_param), 'dollar-sign', 'GRPO Request', 'success', :_blank)
                      end,
                      if policy(purchase_order).new_email_message?
                        row_action_button(new_overseers_po_request_email_message_path(purchase_order.po_request), 'envelope', 'Send Notification', 'dark', :_blank)
                      end
                  ].join(' '),
                  conditional_link(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry) , policy(purchase_order.inquiry).edit? ),
                  conditional_link(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), policy(purchase_order.inquiry).edit?),
                  (purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if purchase_order.rows.present? ),
                  format_star((purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:rating) if purchase_order.rows.present? )),
                  purchase_order.inquiry.company.present? ? conditional_link(purchase_order.inquiry.company.try(:name), overseers_company_path(purchase_order.inquiry.company), policy(purchase_order.inquiry).show?) : "-",
                  purchase_order.status || purchase_order.metadata_status,
                  purchase_order.rows.count,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  purchase_order.inquiry.outside_sales_owner.to_s,
                  (format_succinct_date(purchase_order.metadata['PoDate'].to_date) if ( purchase_order.metadata['PoDate'].present? && purchase_order.valid_po_date? )),
                  purchase_order.material_status,
                  if purchase_order.payment_request.present?
                    purchase_order.payment_request.status
                  end,
                  if purchase_order.payment_request.present?
                    purchase_order.payment_request.percent_amount_paid
                  end,
                  format_succinct_date(purchase_order.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       PurchaseOrder.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       []
                   ]

json.recordsTotal PurchaseOrder.all.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
json.recordsSummary PurchaseOrder.statuses.map {|status, status_id| {:status_id => status_id ,:"label" => status, :"size" => @statuses[status_id]}}.as_json
json.recordsTotalValue @total_values
json.companyRating @indexed_purchase_orders.map{|cmp| {:id => cmp.supplier_id ,:"rating" => cmp.company_rating}}.as_json
