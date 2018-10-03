json.data (@addresses) do |address|
  json.array! [

                  [
                      if policy(address).edit?
                        row_action_button(edit_overseers_company_address_path(address.company, address), 'pencil', 'Edit Address', 'warning')
                      end,
                  ].join(' '),
                  address.to_s.truncate(50),
                  format_date(address.created_at)
              ]
end

json.recordsTotal @addresses.model.all.count
json.recordsFiltered @addresses.total_count
json.draw params[:draw]