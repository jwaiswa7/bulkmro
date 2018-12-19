json.data (@accounts) do |account|
  json.array! [
                  [
                      row_action_button(overseers_account_path(account), 'eye', 'View Account', 'info', :_blank),
                      if policy(account).edit?;
                        row_action_button(edit_overseers_account_path(account), 'pencil', 'Edit Account', 'warning', :_blank)
                      end,
                      if policy(account).edit?;
                        row_action_button(new_overseers_account_company_path(account), 'building', 'New Company', 'success', :_blank)
                      end,
                  ].join(' '),
                  account.to_s,
                  account.companies.size,
                  account.addresses.size,
                  account.contacts.size,
                  account.inquiries.size,
                  format_boolean_label(account.synced?, 'synced'),
                  format_date(account.created_at)
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]