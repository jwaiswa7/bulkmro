json.data (@material_readiness_followups) do |material_readiness_followup|
  json.array! [
                  [
                      if policy(material_readiness_followup.purchase_order).show?
                        row_action_button(overseers_inquiry_purchase_order_path(material_readiness_followup.purchase_order.inquiry, material_readiness_followup.purchase_order, format: :pdf), 'file-pdf', 'Download', 'dark', :_blank)
                      end,
                      if policy(material_readiness_followup.purchase_order).show_document?
                        row_action_button(url_for(material_readiness_followup.purchase_order.document), 'file-pdf', material_readiness_followup.purchase_order.document.filename, 'dark', :_blank)
                      end,
                      if policy(material_readiness_followup).edit?
                        row_action_button(edit_overseers_purchase_order_material_readiness_followup_path(material_readiness_followup.purchase_order, material_readiness_followup), 'pencil', 'Edit Pickup Request', 'warning')
                      end,
                      if policy(material_readiness_followup).confirm_delivery?
                        row_action_button(edit_overseers_purchase_order_material_readiness_followup_path(material_readiness_followup.purchase_order, material_readiness_followup), 'check', 'Confirm Delivery', 'success')
                      end,
                  ].join(' '),
                  link_to(material_readiness_followup.purchase_order.po_number, overseers_inquiry_purchase_orders_path(material_readiness_followup.purchase_order.inquiry), target: "_blank"),
                  link_to(material_readiness_followup.purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(material_readiness_followup.purchase_order.inquiry), target: "_blank"),
                  (material_readiness_followup.purchase_order.get_supplier(material_readiness_followup.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name) if material_readiness_followup.purchase_order.rows.present?),
                  (material_readiness_followup.purchase_order.inquiry.company.try(:name) if material_readiness_followup.purchase_order.inquiry.company.present?),
                  material_readiness_followup.purchase_order.status || material_readiness_followup.purchase_order.metadata_status,
                  material_readiness_followup.purchase_order.inquiry.inside_sales_owner.to_s,
                  material_readiness_followup.purchase_order.inquiry.outside_sales_owner.to_s,
                  format_date(material_readiness_followup.purchase_order.created_at),
                  if material_readiness_followup.purchase_order.last_comment.present?
                    format_date_time_meridiem(material_readiness_followup.purchase_order.last_comment.updated_at)
                  end,
                  if material_readiness_followup.purchase_order.last_comment.present?
                    format_comment(material_readiness_followup.purchase_order.last_comment, trimmed: true)
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
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       []
                   ]

json.recordsTotal @material_readiness_followups.model.count
json.recordsFiltered @material_readiness_followups.count
json.draw params[:draw]