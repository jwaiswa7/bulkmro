json.data (@company_creation_requests) do |company|
  json.array! [
  				  if policy(company.account).edit?;
                    row_action_button(new_overseers_account_company_path(company.account), 'building', 'New Company', 'success', :_blank)
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