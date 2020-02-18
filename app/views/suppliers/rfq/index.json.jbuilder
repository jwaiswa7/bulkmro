json.data(@rfqs) do |rfq|
  json.array! [
                  [
                    if rfq.supplier_rfq_revisions.present?
                      row_action_button(edit_rfq_suppliers_rfq_index_path(rfq_id: rfq.id), 'redo-alt', 'Create RFQ Revision', 'success', :_blank)
                    else
                      row_action_button(edit_rfq_suppliers_rfq_index_path(rfq_id: rfq.id), 'pencil', 'Edit RFQ', 'warning', :_blank)
                    end,
                    row_action_button(suppliers_rfq_path(id: rfq.id), 'eye', 'View RFQ', 'warning', :_blank)
                  ].join(' '),
                  link_to(rfq.id, edit_rfq_suppliers_rfq_index_path(rfq_id: rfq.id), target: '_blank'),
                  rfq.inquiry.inquiry_number,
                  rfq.inquiry.subject,
                  rfq.status,
                  format_date_with_time(rfq.email_sent_at),
                  rfq.inquiry_product_suppliers.map { |ips| ips.inquiry_product.product }.count,
                  rfq.calculated_total.present? ? format_currency(rfq.calculated_total, show_symbol: false) : 0.0,
                  rfq.calculated_total_with_tax.present? ? format_currency(rfq.calculated_total_with_tax, show_symbol: false) : 0.0,
                  format_date_with_time(rfq.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       SupplierRfq.statuses.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @rfqs.count
json.recordsFiltered @rfqs.count
json.draw params[:draw]
json.recordsFiltered
json.recordsTotalValue @total_values
