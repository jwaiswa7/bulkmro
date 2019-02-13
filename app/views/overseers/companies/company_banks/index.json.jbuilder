

json.data (@company_banks) do |company_bank|
  json.array! [

                  [
                      if policy(company_bank).show?
                        row_action_button(overseers_company_company_bank_path(company_bank.company, company_bank), 'fal fa-eye', 'View bank', 'dark')
                      end,
                      if policy(company_bank).edit?
                        row_action_button(edit_overseers_company_company_bank_path(company_bank.company, company_bank), 'pencil', 'Edit bank', 'warning')
                      end
                  ].join(' '),
                  company_bank.bank.name,
                  company_bank.bank.code,
                  company_bank.branch,
                  company_bank.account_name,
                  company_bank.account_number,
                  format_boolean_label(company_bank.synced?, 'synced'),
                  format_date(company_bank.created_at)
              ]
end

json.recordsTotal @company_banks.count
json.recordsFiltered @indexed_company_banks.total_count
json.draw params[:draw]
