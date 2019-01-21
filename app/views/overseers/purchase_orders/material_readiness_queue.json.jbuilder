json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      if policy(purchase_order).show?
                        row_action_button(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(purchase_order).show_document?
                        row_action_button(url_for(purchase_order.document), 'file-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,
                      if policy(purchase_order).edit_material_followup?
                        row_action_button(edit_material_followup_overseers_purchase_order_path(purchase_order), 'list-alt', 'Edit Material Followup', 'success')
                      end,
                      if policy(purchase_order).new_pickup_request?
                        row_action_button(new_overseers_purchase_order_material_pickup_request_path(purchase_order), 'plus-circle', 'Create Material Pickup Request', 'success', target: :_blank)
                      end
                  ].join(' '),
                  link_to(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry), target: "_blank"),
                  link_to(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), target: "_blank"),
                  (purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if purchase_order.rows.present?),
                  (purchase_order.inquiry.company.try(:name) if purchase_order.inquiry.company.present?),
                  purchase_order.status || purchase_order.metadata_status,
                  purchase_order.material_status,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  purchase_order.inquiry.outside_sales_owner.to_s,
                  format_succinct_date(purchase_order.created_at),
                  format_succinct_date(purchase_order.followup_date),
                  if purchase_order.last_comment.present?
                    format_comment(purchase_order.last_comment, trimmed: true)
                  end
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [{"source": autocomplete_overseers_companies_path}],
                       [{"source": autocomplete_overseers_companies_path}],
                       [],
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       []
                   ]

json.recordsTotal @purchase_orders.all.count
json.recordsFiltered @purchase_orders.total_count
json.draw params[:draw]