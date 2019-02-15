json.data (@company_creation_requests) do |company|
  json.array! [
  				  [
                if !company.company.present? && policy(:company).new?
                  row_action_button(new_overseers_company_path(ccr_id: company.id), 'building', 'New Company', 'success', :_blank)
                end,
                if policy(company).show?;
                  row_action_button(overseers_company_creation_request_path(company), 'eye',  'View Company Creation Request', 'info', :_blank)
                end,
                if policy(company.activity).show?;
                  row_action_button(edit_overseers_activity_path(company.activity), 'pencil',  'Edit Activity', 'success', :_blank)
                end
            ].join(' '),
	              company.name,
	              company.first_name,
	              company.last_name,
	              company.email,
                format_boolean(company.is_supplier?),
                format_boolean(company.is_customer?),
                format_succinct_date(company.created_at)
              ]
end
json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @company_creation_requests.model.all.count
json.recordsFiltered @company_creation_requests.total_count
json.draw params[:draw]
