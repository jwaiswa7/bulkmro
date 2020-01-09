json.data (@inquiries) do |inquiry|
  json.array! [
                  #[
                  #    if is_authorized(inquiry,'edit?')
                  #      row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
                  #    end,
                  #].join(' '),
                  inquiry.inquiry_number,
                  status_badge(inquiry.status),
                  # inquiry.account.to_s,
                  # inquiry.company.to_s.truncate(15),
                  # inquiry.contact.to_s.truncate(10),
                  link_to(inquiry.account.to_s,  overseers_account_path(inquiry.account), target: '_blank'),
                   link_to(inquiry.company.to_s.truncate(15), overseers_company_path(inquiry.company), target: '_blank'),
                   link_to(inquiry.contact.to_s.truncate(10), overseers_contact_path(inquiry.contact), target: '_blank'),
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  format_currency(inquiry.final_sales_quote.try(:calculated_total)),
                  format_succinct_date(inquiry.created_at)
              ]
end

json.recordsTotal @inquiries.model.all.count
json.recordsFiltered @inquiries.total_count
json.draw params[:draw]
