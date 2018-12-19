json.data (@addresses) do |address|
  json.array! [

                  [
                      if policy(address).show?
                        row_action_button(overseers_company_address_path(address.company, address), 'fal fa-eye', 'View Address', 'dark', :_blank)
                      end,
                      if policy(address).edit?
                        row_action_button(edit_overseers_company_address_path(address.company, address), 'pencil', 'Edit Address', 'warning', :_blank)
                      end,
                  ].join(' '),
                  address.to_s.truncate(50),
                  format_boolean_label(address.synced?, 'synced'),
                  format_date(address.created_at)
              ]
end

json.recordsTotal @addresses.model.all.count
json.recordsFiltered @addresses.total_count
json.draw params[:draw]