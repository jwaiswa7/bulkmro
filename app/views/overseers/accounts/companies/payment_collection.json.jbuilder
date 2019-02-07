json.data (@companies) do |company|
  json.array! [
                  [
                      if policy(company).show?;
                        row_action_button(overseers_company_path(company), 'eye', 'View Company', 'info', :_blank)
                      end
                  ].join(' '),
                  conditional_link(company.to_s,  overseers_company_path(company), policy(company).show?),
                  format_currency(company.invoices.sum(&:calculated_total)),
                  format_currency(company.amount_received_against_invoice),
                  format_currency(company.amount_received_on_account),
                  format_currency(company.amount_received),
                  format_currency(0),
                  format_currency(company.amount_receivable - company.amount_received),

              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       []
                   ]
json.recordsTotal Company.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]