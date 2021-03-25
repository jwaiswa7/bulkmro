json.data (@credit_notes) do |credit_note|
  json.array! [
                  [
                    if is_authorized(credit_note, 'show') && policy(credit_note).show? && credit_note.sales_invoice.inquiry.present?
                      row_action_button(overseers_credit_note_path(credit_note, format: :pdf), 'file-alt', 'Original with Signature', 'success', :_blank, 'get', '', false, 'O')
                    end
                  ].join(' '),
                  credit_note.memo_number,
                  format_succinct_date(credit_note.memo_date),
                  format_currency(credit_note.memo_amount),
                  conditional_link(credit_note.sales_invoice.invoice_number, overseers_inquiry_sales_invoice_path(credit_note.sales_invoice.inquiry, credit_note.sales_invoice), is_authorized(credit_note.sales_invoice, 'show')),
                  format_succinct_date(credit_note.sales_invoice.mis_date),
                  format_currency(credit_note.sales_invoice.metadata['base_grand_total']),
                  credit_note.sales_invoice.inquiry.present? ?  conditional_link(credit_note.sales_invoice.inquiry.inquiry_number, edit_overseers_inquiry_path(credit_note.sales_invoice.inquiry), is_authorized(credit_note.sales_invoice.inquiry, 'edit')) : '-',
                  credit_note.sales_invoice.inquiry.present? ?  conditional_link(credit_note.sales_invoice.sales_order.order_number, overseers_inquiry_sales_order_path(credit_note.sales_invoice.inquiry, credit_note.sales_invoice.sales_order), is_authorized(credit_note.sales_invoice.sales_order, 'show')) : '-',
                  credit_note.sales_invoice.outward_dispatches.map { |outward_dispatch| link_to(outward_dispatch.id, overseers_outward_dispatch_path(outward_dispatch), target: '_blank'); }.compact.join(' '),
                  link_to(credit_note.sales_invoice.inquiry.company.account.to_s, overseers_account_path(credit_note.sales_invoice.inquiry.company.account), target: '_blank'),
                  link_to(credit_note.sales_invoice.inquiry.company.name, overseers_company_path(credit_note.sales_invoice.inquiry.company, credit_note.sales_invoice), target: '_blank'),
                  credit_note.sales_invoice.inquiry.present? ? credit_note.sales_invoice.rows.count : '',
                  status_badge(credit_note.sales_invoice.status),
                  credit_note.sales_invoice.inquiry.present? ? credit_note.sales_invoice.inquiry.inside_sales_owner.to_s : '',
                  credit_note.sales_invoice.inquiry.present? ? credit_note.sales_invoice.inquiry.outside_sales_owner.to_s : '',
                  format_succinct_date(credit_note.sales_invoice.created_at)
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
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                   ]

json.recordsTotal CreditNote.all.count
json.recordsFiltered @indexed_credit_notes.total_count
json.draw params[:draw]
json.recordsTotalValue @total_values
