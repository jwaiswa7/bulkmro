json.data (@companies) do |company|
  json.array! [
                  format_date(company.created_at),
                  company.to_s,
                  company.industry.to_s,
                  company.contacts.size,
                  [
                      row_action_button(overseers_company_path(company), 'eye', 'Show', 'warning'),
                      row_action_button(edit_overseers_account_company_path(company.account, company), 'pencil', 'Edit', 'warning'),
                      row_action_button(new_overseers_company_inquiry_path(company), 'plus-circle', 'New Inquiry', 'success'),
                  ].join(' ')
              ]
end

json.recordsTotal @companies.model.all.count
json.recordsFiltered @companies.total_count
json.draw params[:draw]