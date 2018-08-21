json.data (@accounts) do |account|
  json.array! [
                  format_date(account.created_at),
                  account.to_s,
                  account.companies.size,
                  account.contacts.size,
                  [
                      row_action_button(new_overseers_account_company_path(account), 'building', 'New Company', 'success'),
                      row_action_button(new_overseers_account_contact_path(account), 'user-tie', 'New Contact', 'success'),
                  ].join(' ')
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]