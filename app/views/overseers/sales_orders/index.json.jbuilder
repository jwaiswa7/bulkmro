json.data (@sales_orders) do |sales_order|
  json.array! [
                  [
                      if is_authorized(sales_order, 'relationship_map')
                        row_action_button(relationship_map_overseers_inquiry_sales_order_path(sales_order.inquiry.to_param, sales_order.to_param), 'sitemap', 'Relationship Map', 'info', :_blank)
                      end,
                      if is_authorized(sales_order, 'comments')
                        row_action_button(overseers_inquiry_comments_path(sales_order.inquiry, sales_order_id: sales_order.to_param), 'comment-alt-check', sales_order.comments.last ? sales_order.comments.last.try(:message) : 'Comments and Approval', sales_order.comments.last ? 'success' : 'dark', :_blank)
                      end,
                      if is_authorized(sales_order, 'edit_mis_date')
                        row_action_button(edit_mis_date_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'calender-alt', 'Update MIS Date', 'success', :_blank)
                      end,
                      if is_authorized(sales_order, 'can_request_po') && sales_order.status == 'Approved' && sales_order.remote_status != 'Cancelled by SAP'
                        row_action_button(new_purchase_orders_requests_overseers_sales_order_path(sales_order.to_param), 'file-alt', 'PO Request', 'success', :_blank)
                      end,
=begin
                      if is_authorized(sales_order, 'can_request_invoice')
                        row_action_button(new_overseers_invoice_request_path(sales_order_id: sales_order.to_param), 'dollar-sign', 'GRPO Request', 'success', :_blank)
                      end,
=end
                      if is_authorized(sales_order, 'new_freight_request') && policy(sales_order.sales_quote).new_freight_request?
                        row_action_button(new_overseers_freight_request_path(sales_order_id: sales_order.to_param), 'external-link', 'New Freight Request', 'warning')
                      end,
                      if is_authorized(sales_order, 'material_dispatched_to_customer_new_email_msg')
                        row_action_button(material_dispatched_to_customer_overseers_sales_order_email_messages_path(sales_order), 'envelope', 'Material Dispatched to Customer Notification', 'dark', :_blank)
                      end,
                      if is_authorized(sales_order, 'material_delivered_to_customer_new_email_msg')
                        row_action_button(material_delivered_to_customer_overseers_sales_order_email_messages_path(sales_order), 'envelope', 'Material Delivered to Customer Notification', 'dark', :_blank)
                      end,
                      if is_authorized(sales_order, 'debugging')
                        row_action_button(debugging_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'cogs', 'Debugging', 'danger', :_blank)
                      end,
                      if is_authorized(sales_order, 'revise_committed_delivery_date') && policy(sales_order).delivery_date_revision_allowed?
                        row_action_button(revise_committed_delivery_date_overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), 'calendar', 'Revise Customer Committed Delivery Date', 'dark', :_blank)
                      end,
                      if is_authorized(sales_order, 'index')
                        link_to('', class: ['icon-title btn btn-sm btn-success comment-sales-order'], 'data-model-id': sales_order.id, title: 'Comment', 'data-title': 'Comment', remote: true) do
                          concat content_tag(:span, '')
                          concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                        end
                      end,
                      if is_authorized(:delivery_challan, 'create') && (policy(sales_order).create_new_dc?)
                        row_action_button_without_fa(new_overseers_delivery_challan_path(sales_order_id: sales_order.id, inquiry_id: sales_order.inquiry.id, created_from: sales_order.class), 'bmro-plus-circle-icon', 'New Delivery Challan', 'success', target: :_blank)
                      end,

                  ].join(' '),
                  conditional_link(sales_order.order_number.present? ? sales_order.order_number : '-', overseers_inquiry_sales_order_path(sales_order.inquiry, sales_order), is_authorized(sales_order, 'show')),
                  format_succinct_date(sales_order.mis_date),
                  format_succinct_date(sales_order.inquiry.customer_committed_date),
                  conditional_link(sales_order.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_order.inquiry), is_authorized(sales_order.inquiry, 'edit') && policy(sales_order.inquiry).edit?),
                  sales_order.invoices.map { |invoice| link_to(invoice.invoice_number, overseers_inquiry_sales_invoice_path(sales_order.inquiry, invoice), target: '_blank') }.compact.join(' '),
                  sales_order.inquiry.customer_po_sheet.attached? ? link_to(["<i class='bmro-fa-file-alt'></i>", sales_order.inquiry.po_subject].join('').html_safe, sales_order.inquiry.customer_po_sheet, target: '_blank') : sales_order.inquiry.po_subject,
                  status_badge(format_enum(sales_order.order_status, humanize_text: false)),
                  status_badge(format_enum(sales_order.remote_status, humanize_text: false)),
                  conditional_link(sales_order.inquiry.company.account.name, overseers_account_path(sales_order.inquiry.company.account), is_authorized(sales_order.inquiry.company.account, 'show')),
                  sales_order.company.to_s,
                  sales_order.inside_sales_owner.to_s,
                  sales_order.outside_sales_owner.to_s,
                  sales_order.inquiry&.billing_contact.present? ? sales_order.inquiry.billing_contact.try(:name) : '',
                  format_currency(sales_order.sales_quote.calculated_total),
                  format_currency(sales_order.calculated_total),
                  sales_order.calculated_total_margin,
                  format_invoiced_qty(sales_order.get_invoiced_qty, sales_order.total_qty),
                  format_succinct_date(sales_order.created_at),
                  status_badge(sales_order.remote_uid.present? ? 'Sync' : 'Not Sync')
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       SalesOrder.statuses.map { |k, v| {"label": k, "value": v.to_s} }.as_json,
                       SalesOrder.remote_statuses.map { |k, v| {"label": k, "value": v.to_s} }.as_json,
                       [{"source": autocomplete_overseers_accounts_path}],
                       [{"source": autocomplete_overseers_companies_path(is_customer: true)}],
                       Overseer.inside.alphabetical.map { |s| {"label": s.full_name, "value": s.id.to_s} }.as_json,
                       Overseer.outside.alphabetical.map { |s| {"label": s.full_name, "value": s.id.to_s} }.as_json,
                       [{ "source": autocomplete_overseers_contacts_path }],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]


json.recordsTotal SalesOrder.all.count
json.recordsFiltered @indexed_sales_orders.total_count
json.draw params[:draw]
json.recordsSummary SalesOrder.statuses.map { |status, status_id| {status_id: status_id, "label": status, "size": @statuses[status_id]} }.as_json
json.recordsMainSummary SalesOrder.main_summary_statuses.map {|status, status_id| {status_id: status_id, "label": status, "size": @statuses[status_id]}}.as_json
json.recordsTotalValue @total_values
json.recordsStatus @statuses
json.recordsOverallStatusCount @statuses_count
json.recordsOverallStatusValue @sales_order_total