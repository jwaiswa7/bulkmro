json.data (@tax_codes) do |tax_code|
  json.array! [
                  [
                      if policy(tax_code).edit?
                        row_action_button(edit_overseers_tax_code_path(tax_code), 'pencil', 'Edit Tax Code', 'warning')
                      end,
                  ].join(' '),
                  tax_code.to_s,
                  format_date(tax_code.created_at)
              ]
end

json.recordsTotal @tax_codes.model.all.count
json.recordsFiltered @tax_codes.total_count
json.draw params[:draw]
