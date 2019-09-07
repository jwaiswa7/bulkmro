json.data (@accounts) do |account|
  json.array! [
                  [
                      row_action_button(overseers_account_path(account), 'eye', 'View Account', 'info', :_blank),
                      if is_authorized(account, 'edit');
                        row_action_button(edit_overseers_account_path(account), 'pencil', 'Edit Account', 'warning', :_blank)
                      end,
                      if is_authorized(:company, 'new')
                        row_action_button(new_overseers_account_company_path(account), 'building', 'New Company', 'success', :_blank)
                      end,
                      if is_authorized('account', 'can_add_edit_target')
                        account.annual_targets.present? ? row_action_button(overseers_annual_target_path(account.annual_targets.last), 'bullseye', 'View Target', 'warning') : row_action_button(new_overseers_annual_target_path(account_id: account), 'bullseye', 'Add Target', 'danger')
                      end
                  ].join(' '),
                  conditional_link(account.to_s, overseers_account_path(account), is_authorized(account, 'show')),
                  account.companies.size,
                  account.addresses.size,
                  account.contacts.size,
                  account.inquiries.size,
                  format_boolean_label(account.synced?, 'synced'),
                  format_boolean(account.is_supplier?),
                  format_boolean(account.is_customer?),
                  format_succinct_date(account.created_at)
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]
