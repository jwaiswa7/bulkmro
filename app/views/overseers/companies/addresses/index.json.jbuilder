json.data (@addresses) do |address|
  json.array! [

                  [
                      if is_authorized(address, 'show')
                        row_action_button(overseers_company_address_path(address.company, address), 'fal fa-eye', 'View Address', 'info', :_blank)
                      end,
                      if is_authorized(address, 'edit')
                        row_action_button(edit_overseers_company_address_path(address.company, address), 'pencil', 'Edit Address', 'warning', :_blank)
                      end,
                  ].join(' '),
                  link_to(address.to_s.truncate(50), overseers_company_address_path(address.company, address), target: '_blank'),
                  address.try(:state).try(:name),
                  address.try(:city_name),
                  address.readable_gst,
                  address.try(:gst),
                  address.try(:pincode),
                  format_boolean_label(address.synced?, 'synced'),
                  format_succinct_date(address.created_at)
              ]
end

json.recordsTotal Address.count
json.recordsFiltered @indexed_addresses.total_count
json.draw params[:draw]
