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
                  address.to_s.truncate(50),
                  address.state.name,
                  address.city_name,
                  format_boolean(address.validate_gst),
                  address.gst,
                  format_boolean_label(address.synced?, 'synced')
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [{:"label" => "Yes", :"value" => true},{:"label" => "No", :"value" => false}],
                       [],
                       []
                   ]

json.recordsTotal Address.count
json.recordsFiltered @indexed_addresses.total_count
json.draw params[:draw]