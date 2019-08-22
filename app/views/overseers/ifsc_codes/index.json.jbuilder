json.data (@ifsc_codes) do |ifsc_code|
  json.array! [

                  [
                      if is_authorized(ifsc_code, 'edit')
                        row_action_button(edit_overseers_ifsc_code_path(ifsc_code), 'fal fa-pen', 'Edit IFSC Code', 'success', :_blank)
                      end,
                      if is_authorized(ifsc_code, 'show')
                        row_action_button(overseers_ifsc_code_path(ifsc_code), 'fal fa-eye', 'View IFSC Code', 'info', :_blank)
                      end
                  ].join(' '),
                  ifsc_code.ifsc_code,
                  ifsc_code.branch,
                  ifsc_code.address,
                  ifsc_code.city,
                  ifsc_code.district,
                  ifsc_code.state,
                  format_succinct_date(ifsc_code.created_at)
              ]
end

json.recordsTotal @ifsc_codes.count
json.recordsFiltered @indexed_ifsc_codes.total_count
json.draw params[:draw]
