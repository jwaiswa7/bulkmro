json.data (@company_creation_requests) do |company|
  json.array! [
  				  if company.account.present? && policy(:company).new?;
                    row_action_button(new_overseers_account_company_path(company.account,:ccr_id => company.id), 'building', 'New Company', 'success', :_blank)
            end,
            if company.account_creation_request.present? && policy(:account).new?;
              row_action_button(new_overseers_account_path(:acr_id => company.account_creation_request.id), 'building', 'New Account', 'success', :_blank)
            end,
	              company.name,
	              company.first_name,
	              company.last_name,
	              company.email,
	              company.address,
	              format_date(company.created_at)
              ]
end

json.recordsTotal @company_creation_requests.model.all.count
json.recordsFiltered @company_creation_requests.total_count
json.draw params[:draw]