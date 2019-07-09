json.data (@po_requests) do |po_request|
  json.array! [
                  [
                      if po_request.sales_order.present? && (is_authorized(po_request, 'edit'))
                        row_action_button(edit_overseers_po_request_path(po_request), 'pencil', 'Edit PO Request', 'warning')
                      elsif is_authorized(po_request, 'edit') && po_request.status != 'Cancelled'
                        row_action_button(edit_overseers_inquiry_po_request_path(po_request.inquiry, po_request), 'pencil', 'Edit PO Request', 'warning')
                      end,
                      if is_authorized(po_request, 'can_cancel')&& policy(po_request).can_cancel?
                        link_to('', class: ['btn btn-sm btn-dark cancel-po_request'], 'data-po-request-id': po_request.id, title: 'Cancel', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end,
                      if is_authorized(po_request, 'index') && policy(po_request).index?
                        link_to('', class: ['btn btn-sm btn-success comment-po-request'], 'data-po-request-id': po_request.id, title: 'Comment', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                        end
                      end,
                      if po_request.po_request_type == 'Stock' && is_authorized(po_request, 'can_reject') && policy(po_request).can_reject?
                        link_to('', class: ['btn btn-sm btn-danger cancel-po_request'], 'data-po-request-id': po_request.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      elsif is_authorized(po_request, 'can_reject') && policy(po_request).can_reject?
                        link_to('', class: po_request.status != 'Supplier PO Request Rejected' ? ['btn btn-sm btn-danger cancel-po_request'] : ['btn btn-sm btn-danger cancel-po_request disabled'], 'data-po-request-id': po_request.id, title: 'Reject', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-ban'].join
                        end
                      end, '<br/>', '<br/>',
                      if is_authorized(po_request, 'new_payment_request') && policy(po_request).new_payment_request?
                        row_action_button(new_overseers_po_request_payment_request_path(po_request), 'dollar-sign', 'Payment Request', 'success', :_blank)
                      elsif is_authorized(po_request, 'show_payment_request') && po_request.payment_request.present?
                        row_action_button(overseers_payment_request_path(po_request.payment_request), 'eye', 'View Payment Request', 'info', :_blank)
                      end,
                      if is_authorized(po_request, 'sending_po_to_supplier_new_email_message') && policy(po_request).sending_po_to_supplier_new_email_message? && current_overseer.smtp_password.present?
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Send Purchase Order to Supplier', 'dark', :_blank)
                      else
                        row_action_button(sending_po_to_supplier_overseers_po_request_email_messages_path(po_request), 'envelope', 'Enter SMTP settings', 'dark disabled')
                      end,
                      if is_authorized(po_request, 'material_received_in_bm_warehouse_new_email_msg') && policy(po_request).material_received_in_bm_warehouse_new_email_msg? && current_overseer.smtp_password.present?
                        row_action_button(material_received_in_bm_warehouse_overseers_po_request_email_messages_path(po_request), 'envelope', 'Material Received in BM Warehouse', 'warning', :_blank)
                      else
                        row_action_button(material_received_in_bm_warehouse_overseers_po_request_email_messages_path(po_request), 'envelope', 'Enter SMTP settings', 'warning disabled')
                      end,

                  ].join(' '),
                  attribute_boxes([{ request_number: conditional_link(po_request.id, overseers_po_request_path(po_request), is_authorized(po_request, 'show'))}, { inquiry_number: conditional_link(po_request.inquiry.inquiry_number, edit_overseers_inquiry_path(po_request.inquiry), is_authorized(po_request.inquiry, 'edit')) }, { order: po_request.purchase_order.present? && (po_request.status == 'Supplier PO: Created Not Sent') ? link_to(po_request.purchase_order.po_number, overseers_inquiry_purchase_order_path(po_request.inquiry, po_request.purchase_order), target: '_blank') :  po_request.sales_order.present? ? link_to(po_request.sales_order.order_number, overseers_inquiry_sales_order_path(po_request.inquiry.id, po_request.sales_order.id), target: '_blank') : '-'}]),
                  attribute_boxes([{ supplier: po_request.supplier.present? ? conditional_link(po_request.supplier.to_s, overseers_company_path(po_request.supplier), is_authorized(po_request.supplier, 'show')) : '-'}, { customer: po_request.inquiry.company.present? ? conditional_link(po_request.inquiry.company.to_s, overseers_company_path(po_request.inquiry.company), is_authorized(po_request.inquiry.company, 'show')) : '-'}]),
                  attribute_boxes([ { supplier: po_request.supplier_committed_date.present? ? po_request.supplier_committed_date : 'N / A' }, { customer: po_request.inquiry.customer_committed_date }]),
                  attribute_boxes([{ buying: po_request.buying_price }, { selling: po_request.selling_price }]),
                  attribute_boxes([{ margin: po_request.po_margin_percentage.to_s+"-"+po_request.po_margin.to_s  }, { overal: po_request.sales_order.present? ? po_request.sales_order.calculated_total_margin_percentage : 0 }]),
                  attribute_boxes([{ po_status: status_badge(po_request.status) }, { email_status: status_badge(po_request.try(:purchase_order).try(:has_sent_email_to_supplier?) ? 'Supplier PO Sent' : 'Supplier PO: Not Sent to Supplier') }]),
                  if po_request.last_comment.present?
                    format_comment(po_request.last_comment, trimmed: true)
                  end,
                  po_request.inquiry.inside_sales_owner.to_s,
                  format_succinct_date(po_request.created_at),
                  if po_request.last_comment.present?
                    format_succinct_date(po_request.last_comment.updated_at)
                  end,
              ]
end

json.recordsTotal @po_requests.count
json.recordsFiltered @po_requests.total_count
json.draw params[:draw]
