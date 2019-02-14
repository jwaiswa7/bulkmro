# frozen_string_literal: true

json.data (@inquiries) do |inquiry|
  json.array! [
                  [
                      row_action_button(customers_inquiry_path(inquiry), 'eye', 'View Inquiry', 'info')
                  ].join(' '),
                  inquiry.inquiry_number,
                  status_badge(inquiry.status),
                  inquiry.company.to_s,
                  inquiry.inside_sales_owner.to_s,
                  format_currency(inquiry.final_sales_quote.try(:calculated_total)),
                  format_date(inquiry.created_at)
              ]
end

json.recordsTotal @inquiries.total_count
json.recordsFiltered @inquiries.total_count
json.draw params[:draw]
