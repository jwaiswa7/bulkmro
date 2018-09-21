json.data (@accounts) do |account|
  json.array! [
                  [
                      row_action_button(overseers_account_path(account), 'eye', 'View Account', 'dark'),
                      row_action_button(new_overseers_account_company_path(account), 'building', 'New Company', 'success'),
                  ].join(' '),
                  account.to_s,
                  account.companies.size,
                  account.contacts.size,
                  format_date(account.created_at)
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]