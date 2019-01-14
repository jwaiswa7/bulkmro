json.data (@company_creation_requests) do |company|
  json.array! [
  				  [
                if company.account.present? && policy(:company).new?;
                    row_action_button(new_overseers_account_company_path(company.account,:ccr_id => company.id), 'building', 'New Company', 'success', :_blank)
                else
                  link_to '#', :disabled => true, :'data-toggle' => 'tooltip', :title => "First create new account",:class => 'btn btn-sm btn-warninggit 'do
                    concat content_tag(:span, '')
                    concat content_tag :i, nil, class: 'fal fa-building'
                  end
                end,
                if !company.account.present?  && policy(:account).new?;
                  row_action_button(new_overseers_account_path(:ccr_id => company.id), 'building',  'New Account', 'success', :_blank)
                end,
                if policy(company).show?;
                    row_action_button(overseers_company_creation_request_path(company), 'eye',  'View Company cCreation Request', 'info', :_blank)
                end
            ],
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