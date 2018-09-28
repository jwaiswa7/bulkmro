json.data (@inquiries) do |inquiry|
  json.array! [
                  [
                      if policy(inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
                      end,
                  ].join(' '),
                  format_status_label(inquiry.status),
                  inquiry.id,
                  inquiry.account.to_s,
                  inquiry.company.to_s,
                  inquiry.contact.to_s,
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  format_currency(inquiry.final_sales_quote.try(:calculated_total)),
                  format_date(inquiry.created_at)
              ]
end

json.recordsTotal Inquiry.all.count
json.recordsFiltered @indexed_inquiries.total_count
json.draw params[:draw]