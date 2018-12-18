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
                  address.company.to_s.truncate(50),
                  address.to_s.truncate(50),
                  address.state.name,
                  address.city_name,
                  format_boolean(address.gst.to_s.match(/^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/)),
                  format_boolean(address.company.pan.to_s.match(/^[A-Z]{5}\d{4}[A-Z]{1}$/)),
                  address.gst,
                  address.company.pan,
                  format_boolean_label(address.synced?, 'synced'),
                  format_date(address.created_at)
              ]
end

json.recordsTotal @addresses.model.all.count
json.recordsFiltered @addresses.total_count
json.draw params[:draw]