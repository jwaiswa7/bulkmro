json.data (@inquiries) do |inquiry|
  json.array! [
                  [
                      row_action_button(customers_inquiry_path(inquiry), 'pencil', 'View Inquiry', 'warning')
                  ].join(' '),
                  inquiry.inquiry_number,
                  status_helper_format_label(inquiry.status),
                  inquiry.account.to_s,
                  inquiry.company.to_s.truncate(15),
                  inquiry.contact.to_s.truncate(10),
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  format_currency(inquiry.final_sales_quote.try(:calculated_total)),
                  format_date(inquiry.created_at)
              ]
end

json.recordsTotal @inquiries.total_count
json.recordsFiltered @inquiries.total_count
json.draw params[:draw]