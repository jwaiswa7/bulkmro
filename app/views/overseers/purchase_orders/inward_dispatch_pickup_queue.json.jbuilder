json.data (@inward_dispatches) do |inward_dispatch|
  json.array! [
                  [
                      if is_authorized(inward_dispatch, 'update_logistics_owner_for_inward_dispatches') && policy(inward_dispatch).update_logistics_owner_for_inward_dispatches? && (inward_dispatch.status != 'Material Delivered')
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='the_inward_dispatches[]' class='custom-control-input' value='#{inward_dispatch.id}' id='c-#{inward_dispatch.id}'><label class='custom-control-label' for='c-#{inward_dispatch.id}'></label></div>"
                      end,
                      if is_authorized(inward_dispatch, 'delivered') && policy(inward_dispatch).delivered? && is_authorized(inward_dispatch, 'can_request_invoice') && policy(inward_dispatch).can_request_invoice?
                        "<div class='d-inline-block custom-control custom-checkbox align-middle'><input type='checkbox' name='the_inward_dispatches[]' class='custom-control-input' value='#{inward_dispatch.id}' id='c-#{inward_dispatch.id}' data-po-id='#{inward_dispatch.purchase_order.id}'><label class='custom-control-label' for='c-#{inward_dispatch.id}'></label></div>"
                      end,
                      if is_authorized(inward_dispatch, 'show') && policy(inward_dispatch).show?
                        row_action_button(overseers_purchase_order_inward_dispatch_path(inward_dispatch.purchase_order, inward_dispatch), 'eye', 'View Inward Dispatch', 'info', target: :_blank)
                      end,
                      if is_authorized(inward_dispatch, 'edit') && policy(inward_dispatch).edit?
                        row_action_button(edit_overseers_purchase_order_inward_dispatch_path(inward_dispatch.purchase_order, inward_dispatch), 'pencil', 'Edit Inward Dispatch', 'warning', :_blank)
                      end,
                      if is_authorized(inward_dispatch, 'confirm_delivery') && policy(inward_dispatch).confirm_delivery?
                        row_action_button(confirm_delivery_overseers_purchase_order_inward_dispatch_path(inward_dispatch.purchase_order, inward_dispatch), 'check', 'Confirm Delivery', 'success', :_blank)
                      end,
                      if is_authorized(inward_dispatch, 'delivered') && policy(inward_dispatch).delivered? && is_authorized(inward_dispatch, 'can_request_invoice') && policy(inward_dispatch).can_request_invoice? && inward_dispatch.purchase_order.sap_sync == 'Sync'
                        row_action_button(new_overseers_invoice_request_path(purchase_order_id: inward_dispatch.purchase_order, inward_dispatch_id: inward_dispatch), 'plus', 'Create GRPO Request',  'success', target: :_blank)
                      elsif is_authorized(inward_dispatch, 'delivered') && policy(inward_dispatch).delivered? && is_authorized(inward_dispatch, 'can_request_invoice') && policy(inward_dispatch).can_request_invoice? && inward_dispatch.purchase_order.sap_sync == 'Not Sync'
                        link_to '', 'data-toggle': 'tooltip', 'data-placement': 'top', 'data-toggle': 'modal', 'data-target': '#goodsReceiptPurchaseOrderId', title: '', class: 'btn btn-sm btn-success' do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: 'fal fa-plus'
                        end
                      elsif inward_dispatch.invoice_request.present? && is_authorized(inward_dispatch.invoice_request, 'show') && policy(inward_dispatch.invoice_request).show?
                        row_action_button(overseers_invoice_request_path(inward_dispatch.invoice_request), 'eye', "View #{inward_dispatch.invoice_request.readable_status}", 'success', target: :_blank)
                      end,

                  ].join(' '),
                  link_to(inward_dispatch.purchase_order.inquiry.inquiry_number, edit_overseers_inquiry_path(inward_dispatch.purchase_order.inquiry), target: '_blank'),
                  (conditional_link(inward_dispatch.purchase_order.inquiry.company.try(:name), overseers_company_path(inward_dispatch.purchase_order.inquiry.company), is_authorized(inward_dispatch.purchase_order.inquiry, 'show') && policy(inward_dispatch.purchase_order.inquiry).show?) if inward_dispatch.purchase_order.po_request.present? && inward_dispatch.purchase_order.po_request.sales_order.present?),
                  (inward_dispatch.purchase_order.po_request.sales_order.order_number if inward_dispatch.purchase_order.po_request.present? && inward_dispatch.purchase_order.po_request.sales_order.present?),
                  (format_succinct_date(inward_dispatch.purchase_order.po_request.sales_order.mis_date) if inward_dispatch.purchase_order.po_request.present? && inward_dispatch.purchase_order.po_request.sales_order.present?),
                  (format_succinct_date(inward_dispatch.purchase_order.po_request.inquiry.customer_committed_date) if inward_dispatch.purchase_order.po_request.present?),
                  link_to(inward_dispatch.purchase_order.po_number, overseers_inquiry_purchase_orders_path(inward_dispatch.purchase_order.inquiry), target: '_blank'),
                  format_succinct_date(inward_dispatch.purchase_order.metadata['PoDate'].try(:to_date)),
                  (inward_dispatch.purchase_order.get_supplier(inward_dispatch.purchase_order.rows.first.metadata['PopProductId'].to_i).present? ? conditional_link(inward_dispatch.purchase_order.get_supplier(inward_dispatch.purchase_order.rows.first.metadata['PopProductId'].to_i).try(:name), overseers_company_path(inward_dispatch.purchase_order.get_supplier(inward_dispatch.purchase_order.rows.first.metadata['PopProductId'])), is_authorized(inward_dispatch.purchase_order.inquiry, 'show') && policy(inward_dispatch.purchase_order.inquiry).show?) : '-' if inward_dispatch.purchase_order.rows.present?),
                  inward_dispatch.purchase_order.inquiry.inside_sales_owner.to_s,
                  (inward_dispatch.logistics_owner.full_name if inward_dispatch.logistics_owner.present?),
                  inward_dispatch.purchase_order.status || inward_dispatch.purchase_order.metadata_status,
                  (inward_dispatch.purchase_order.po_request.status if inward_dispatch.purchase_order.po_request.present?),
                  (inward_dispatch.purchase_order.payment_request.status if inward_dispatch.purchase_order.payment_request.present?),
                  inward_dispatch.purchase_order.material_status,
                  if inward_dispatch.last_comment.present?
                    format_comment(inward_dispatch.last_comment, trimmed: true)
                  end,
                  format_date(inward_dispatch.expected_dispatch_date),
                  inward_dispatch.logistics_partner,
                  inward_dispatch.tracking_number,
                  format_date(inward_dispatch.expected_delivery_date)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       Overseer.logistics.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_inward_dispatches.count
json.recordsFiltered @indexed_inward_dispatches.total_count
json.draw params[:draw]
