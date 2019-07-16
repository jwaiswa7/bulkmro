json.data (@sales_invoices) do |sales_invoice|
  json.array! [
                  [
                      if is_authorized(sales_invoice, 'relationship_map')
                        row_action_button(relationship_map_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry.to_param, sales_invoice.to_param), 'sitemap', 'Relationship Map', 'info', :_blank)
                      end,
                      if is_authorized(sales_invoice, 'show') && policy(sales_invoice).show? && sales_invoice.inquiry.present?
                        [
                         row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), 'eye', 'View AR Invoice ', 'info', :_blank),
                         row_action_button(overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :pdf), 'none', 'Original with Signature', 'success', :_blank, 'get', false, 'O'),
                         # row_action_button(duplicate_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :pdf), 'none', 'Duplicate with Signature', 'success', :_blank, 'get', false, 'D'),
                         # row_action_button(triplicate_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :pdf), 'none', 'Triplicate with Signature', 'success', :_blank, 'get', false, 'T'),
                         row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, stamp: 1, format: :zip), 'stamp', 'Zip with Signature', 'info', :_blank),
                         row_action_button(make_zip_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice, format: :zip), 'file-archive', 'Zip without Signature', 'info', :_blank)
                        ]
                      end,
                      if is_authorized(sales_invoice, 'can_send_pod_email') && policy(sales_invoice).create_email_message?
                        [
                            row_action_button(dispatch_mail_to_customer_overseers_sales_invoice_path(sales_invoice), 'envelope', 'Dispatch Email', 'primary'),
                            row_action_button(delivery_mail_to_customer_overseers_sales_invoice_path(sales_invoice), 'envelope', 'Delivery Email', 'success')
                        ]
                      end,
                      if is_authorized(sales_invoice, 'show_original_invoice') && policy(sales_invoice).show_original_invoice? && sales_invoice.inquiry.present?
                        [row_action_button(url_for(sales_invoice.original_invoice), 'none', sales_invoice.original_invoice.filename, 'success', :_blank, 'get', false, 'O'),
                     row_action_button(url_for(sales_invoice.duplicate_invoice), 'none', sales_invoice.duplicate_invoice.filename, 'success', :_blank, 'get', false, 'D'),
                     row_action_button(url_for(sales_invoice.triplicate_invoice), 'none', sales_invoice.triplicate_invoice.filename, 'success', :_blank, 'get', false, 'T'),
                    ]
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count == 0)
                        row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'truck', 'Add Proof of Delivery', 'success')
                      end,
                      if is_authorized(sales_invoice, 'edit_pod') && policy(sales_invoice).edit_pod? && (sales_invoice.pod_rows.count > 0)
                        [
                            row_action_button(edit_pod_overseers_sales_invoice_path(sales_invoice), 'pencil', 'Edit Proof of Delivery', 'info'),
                        ]
                      end,
                      if is_authorized(sales_invoice, 'edit_mis_date') && policy(sales_invoice).edit_mis_date?
                        row_action_button(edit_mis_date_overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), 'calendar-alt', 'Update MIS Date', 'success')
                      end,
                  ].join(' '),
                  conditional_link(sales_invoice.invoice_number, overseers_inquiry_sales_invoice_path(sales_invoice.inquiry, sales_invoice), is_authorized(sales_invoice, 'show')),
                  sales_invoice.inquiry.present? ?  conditional_link(sales_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(sales_invoice.inquiry), is_authorized(sales_invoice.inquiry, 'edit')) : '-',
                  sales_invoice.inquiry.present? ?  conditional_link(sales_invoice.sales_order.order_number, overseers_inquiry_sales_order_path(sales_invoice.inquiry, sales_invoice.sales_order), is_authorized(sales_invoice.sales_order, 'show')) : '-',
                  link_to(sales_invoice.inquiry.company.account.to_s, overseers_account_path(sales_invoice.inquiry.company.account), target: '_blank'),
                  link_to(sales_invoice.inquiry.company.name, overseers_company_path(sales_invoice.inquiry.company, sales_invoice), target: '_blank'),
                  sales_invoice.inquiry.present? ? sales_invoice.rows.count : '',
                  status_badge(sales_invoice.status),
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.inside_sales_owner.to_s : '',
                  sales_invoice.inquiry.present? ? sales_invoice.inquiry.outside_sales_owner.to_s : '',
                  format_succinct_date(sales_invoice.delivery_date),
                  format_boolean_with_badge(sales_invoice.pod_status),
                  ((sales_invoice.inquiry.opportunity_type != 'route_through' ? 'regular' : 'route_through') if sales_invoice.inquiry.present?),
                  format_succinct_date(sales_invoice.mis_date),
                  format_succinct_date(sales_invoice.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       SalesInvoice.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       [{"label": 'True', "value": 1}, {"label": 'False', "value": 0}],
                       Inquiry.opportunity_types.slice('regular', 'route_through').map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                   ]

json.recordsTotal SalesInvoice.all.count
json.recordsFiltered @indexed_sales_invoices.total_count
json.draw params[:draw]
json.recordsSummary SalesInvoice.statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsTotalValue @total_values
