json.data (@banks) do |bank|
  json.array! [

                  [
                      if is_authorized(bank, 'show')
                        row_action_button_without_fa(overseers_bank_path(bank), 'bmro-icon-table bmro-icon-used-view', 'View bank', 'info', :_blank)
                      end,
                      if is_authorized(bank, 'edit')
                        row_action_button_without_fa(edit_overseers_bank_path(bank), 'bmro-icon-table bmro-icon-pencil', 'Edit bank', 'warning', :_blank)
                      end
                  ].join(' '),
                  bank.name,
                  bank.code,
                  bank.swift_number,
                  bank.iban,
                  format_boolean_label(bank.synced?, 'synced'),
                  format_succinct_date(bank.created_at)
              ]
end

json.recordsTotal @banks.count
json.recordsFiltered @indexed_banks.total_count
json.draw params[:draw]
