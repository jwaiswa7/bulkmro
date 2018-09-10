json.data (@companies) do |company|
  json.array! [
                  [
                      row_action_button(overseers_company_path(company), 'eye', 'View Company', 'dark'),
                      row_action_button(edit_overseers_account_company_path(company.account, company), 'pencil', 'Edit Company', 'warning'),
                      row_action_button(new_overseers_inquiry_path(company_id: company.to_param), 'plus-circle', 'New Inquiry', 'success'),
                  ].join(' '),
                  company.to_s,
                  company.industry.to_s,
                  company.contacts.size,
                  format_date(company.created_at)
              ]
end

json.recordsTotal @companies.model.all.count
json.recordsFiltered @companies.total_count
json.draw params[:draw]