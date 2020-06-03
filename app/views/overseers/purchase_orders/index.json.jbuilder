json.data (@purchase_orders) do |purchase_order|
  json.array! [
                  [
                      row_action_button_without_fa(relationship_map_overseers_inquiry_purchase_order_path(purchase_order.inquiry.to_param, purchase_order.to_param), 'fal fa-sitemap', 'Relationship Map', 'info', :_blank),
                      if is_authorized(purchase_order, 'show') && policy(purchase_order).show?
                        [row_action_button_without_fa(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order), 'bmro-icon-table bmro-icon-used-view', 'View PO', 'info', :_blank),
                         row_action_button_without_fa(overseers_inquiry_purchase_order_path(purchase_order.inquiry, purchase_order, format: :pdf), 'bmro-icon-table bmro-icon-pdf', 'Download', 'dark', :_blank)
                        ]
                      end,
                      if purchase_order.document.present? && is_authorized(purchase_order, 'show_document') && policy(purchase_order).show_document?
                        row_action_button_without_fa(url_for(purchase_order.document), 'bmro-icon-table bmro-icon-pdf', purchase_order.document.filename, 'dark', :_blank)
                      end,
                      if (policy(purchase_order).logistics? || policy(purchase_order).admin?) && purchase_order.status != 'cancelled'
                        link_to('', class: 'btn btn-sm btn-danger cancel-purchase-order', 'data-purchase-order-id': purchase_order.id, title: 'Cancel Purchase Order', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['bmro-icon-table bmro-icon-ban'].join
                        end
                      end,
                      if is_authorized(purchase_order, 'change_material_status') && policy(purchase_order).change_material_status? && !(purchase_order.material_status == 'Manually Closed') && policy(purchase_order).developer?
                        row_action_button_without_fa(change_material_status_overseers_purchase_order_path(purchase_order, is_manual: true), 'bmro-icon-table bmro-icon-peoplemate', 'Change PO Status', 'success', :_blank)
                      end,
=begin
                      if policy(purchase_order).can_request_invoice?
                        row_action_button(new_overseers_invoice_request_path(purchase_order_id: purchase_order.to_param), 'dollar-sign', 'GRPO Request', 'success', :_blank)
                      end
=end
                  ].join(' '),
                  conditional_link(purchase_order.po_number, overseers_inquiry_purchase_orders_path(purchase_order.inquiry), is_authorized(purchase_order.inquiry, 'edit')),
                  conditional_link(purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(purchase_order.inquiry), is_authorized(purchase_order.inquiry, 'edit')),
                  (purchase_order.supplier.present? ? conditional_link(purchase_order.supplier.try(:name), overseers_company_path(purchase_order.supplier), is_authorized(purchase_order.inquiry, 'show')) : '-'),
                  format_star((purchase_order.get_supplier(purchase_order.rows.first.metadata['PopProductId'].to_i).try(:rating) if purchase_order.rows.present?)),
                  purchase_order.inquiry.company.present? ? conditional_link(purchase_order.inquiry.company.try(:name), overseers_company_path(purchase_order.inquiry.company), is_authorized(purchase_order.inquiry, 'show')) : '-',
                  purchase_order.status || purchase_order.metadata_status,
                  purchase_order.rows.count,
                  purchase_order.inquiry.inside_sales_owner.to_s,
                  purchase_order.inquiry.outside_sales_owner.to_s,
                  (format_succinct_date(purchase_order.metadata['PoDate'].to_date) if purchase_order.metadata['PoDate'].present? && purchase_order.valid_po_date?),
                  purchase_order.material_status,
                  if purchase_order.payment_request.present?
                    status_badge(purchase_order.payment_request.status)
                  end,
                  (percentage(purchase_order.payment_request.percent_amount_paid, precision: 2) if purchase_order.payment_request.present?),
                  format_succinct_date(purchase_order.created_at),
                  status_badge(purchase_order.sap_sync)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       PurchaseOrder.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [],
                       []
                   ]

json.recordsTotal PurchaseOrder.all.count
json.recordsFiltered @indexed_purchase_orders.total_count
json.draw params[:draw]
json.recordsSummary PurchaseOrder.statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsMainSummary PurchaseOrder.main_summary_statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsTotalValue @total_values
json.companyRating @indexed_purchase_orders.map { |cmp| { id: cmp.supplier_id, "rating": cmp.company_rating } }.as_json
