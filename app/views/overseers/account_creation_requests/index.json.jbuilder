json.data (@account_creation_requests) do |account|
  json.array! [
  				  if policy(:account).new?;
                    row_action_button(new_overseers_account_path(:acr_id => account.id), 'building', 'New Account', 'success', :_blank)
            end,
              account.name,
              account.account_type,
              format_date(account.created_at)
            ]
end
json.recordsTotal @account_creation_requests.model.all.count
json.recordsFiltered @account_creation_requests.total_count
json.draw params[:draw]