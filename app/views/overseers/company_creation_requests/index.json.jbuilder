json.data (@company_creation_requests) do |company|
  json.array! [
  				  [
                if !company.company.present? && is_authorized(:company, 'new')
                  row_action_button_without_fa(new_overseers_company_path(ccr_id: company.id), 'bmro-icon-table bmro-icon-new-company', 'New Company', 'success', :_blank)
                end,
                if is_authorized(company, 'show')
                 row_action_button_without_fa(overseers_company_creation_request_path(company), 'bmro-icon-table bmro-icon-used-view',  'View Company Creation Request', 'info', :_blank)
                end,
                if is_authorized(company.activity, 'show')
                row_action_button_without_fa(edit_overseers_activity_path(company.activity), 'bmro-icon-table bmro-icon-pencil',  'Edit Activity', 'warning', :_blank)
                end
            ].join(' '),
	              link_to(company.name, overseers_company_creation_request_path(company), target: '_blank'),
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
