json.data(@rfqs) do |rfq|
  json.array! [
                  [
                      row_action_button(edit_rfq_suppliers_rfq_index_path(rfq_id: rfq.id), 'pencil', 'Edit RFQ', 'warning', :_blank)
                  ].join(' '),
                  link_to(rfq.id, edit_rfq_suppliers_rfq_index_path(rfq_id: rfq.id), target: '_blank'),
                  rfq.inquiry.inquiry_number,
                  rfq.inquiry.subject,
                  format_date_with_time(rfq.email_sent_at),
                  rfq.inquiry_product_suppliers.map { |ips| ips.inquiry_product.product }.count,
                  format_date_with_time(rfq.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       []
                   ]

json.recordsTotal @rfqs.count
json.recordsFiltered @rfqs.count
json.draw params[:draw]
