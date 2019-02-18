json.data (@tax_codes) do |tax_code|
  json.array! [
                  [
                      if policy(tax_code).edit?
                        row_action_button(edit_overseers_tax_code_path(tax_code), 'pencil', 'Edit Tax Code', 'warning')
                      end,
                  ].join(' '),
                  conditional_link(tax_code.to_s, edit_overseers_tax_code_path(tax_code), policy(tax_code).new?),
                  format_boolean(tax_code.is_active?),
                  format_boolean(tax_code.is_service?),
                  format_succinct_date(tax_code.created_at)
              ]
end

json.recordsTotal @tax_codes.model.all.count
json.recordsFiltered @tax_codes.total_count
json.draw params[:draw]
