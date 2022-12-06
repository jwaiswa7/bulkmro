json.data (@rfqs) do |rfq|
  columns = [
                row_action_button(customers_rfq_path(rfq), 'eye', 'View RFQ', 'info', :_blank),
                rfq.inquiry.inquiry_number,
                format_date(rfq.created_at),
                rfq.inquiry.company.to_s,
                rfq.inquiry.contact.to_s,
                rfq.subject,
                rfq.inquiry.inside_sales_owner.to_s
            ]
  columns.delete_at(3) unless policy(current_customers_contact).admin_columns?
  json.merge! columns
end

json.columnFilters [
                        [],
                        [],
                        [],
                        @rfqs.map {|rfq| { "label": rfq.inquiry.company.to_s, "value": rfq.inquiry.company.id }}.uniq,
                        @rfqs.map {|rfq| { "label": rfq.inquiry.contact.to_s, "value": rfq.inquiry.contact.id }}.uniq,
                        [],
                        []
                    ]

json.recordsTotal @rfqs.count
json.recordsFiltered @indexed_rfqs.total_count
json.draw params[:draw]
