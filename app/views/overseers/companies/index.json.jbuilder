json.data (@companies) do |company|
  json.array! [
                  [
                      if policy(company).show?; row_action_button(overseers_company_path(company), 'eye', 'View Company', 'dark') end,
                      if policy(company).edit?; row_action_button(edit_overseers_account_company_path(company.account, company), 'pencil', 'Edit Company', 'warning') end,
                      if policy(company).new_inquiry?; row_action_button(new_overseers_inquiry_path(company_id: company.to_param), 'plus-circle', 'New Inquiry', 'success') end,
                  ].join(' '),
                  company.to_s,
                  company.contacts.size,
                  company.addresses.size,
                  company.inquiries.size,
                  format_date(company.created_at)
              ]
end

json.recordsTotal @companies.model.all.count
json.recordsFiltered @companies.total_count
json.draw params[:draw]