json.data (@addresses) do |address|
  json.array! [

                  [
                      if policy(address).show?
                        row_action_button(overseers_company_address_path(address.company, address), 'fal fa-eye', 'View Address', 'info', :_blank)
                      end,
                      if policy(address).edit?
                        row_action_button(edit_overseers_company_address_path(address.company, address), 'pencil', 'Edit Address', 'warning', :_blank)
                      end,
                  ].join(' '),
                  link_to(address.company.to_s.truncate(50), overseers_company_path(address.company), target: "_blank"),
                  address.to_s.truncate(50),
                  address.state.name,
                  address.city_name,
                  validate_gst(address.gst.to_s),
                  validate_pan(address.company.pan.to_s),
                  address.gst,
                  address.company.pan,
                  format_boolean_label(address.synced?, 'synced'),
                  format_date(address.created_at)
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{:"label" => "True", :"value" => true},{:"label" => "False", :"value" => false}],
                       [{:"label" => "True", :"value" => true},{:"label" => "False", :"value" => false}],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal Address.count
json.recordsFiltered @indexed_addresses.total_count
json.draw params[:draw]