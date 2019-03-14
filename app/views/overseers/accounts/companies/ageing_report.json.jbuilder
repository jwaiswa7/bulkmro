json.data (@companies) do |company|
  json.array! [
                  [
                      if policy(company).show?
                        row_action_button(ageing_report_overseers_company_sales_invoices_path(company), 'eye', 'View Company', 'info', :_blank)
                      end
                  ].join(' '),
                  company.account.alias,
                  conditional_link(company.to_s,  overseers_company_path(company), policy(company).show?),
                  format_currency(company.invoices.not_cancelled_invoices.sum(&:calculated_total_with_tax)),
                  format_currency(company.amount_received_against_invoice),
                  format_currency(company.amount_received_on_account),
                  format_currency(company.total_amount_received),
                  format_currency(company.amount_overdue_outstanding),
                  format_currency(company.payment_collections.sum(:amount_1_to_30_od)),
                  format_currency(company.payment_collections.sum(:amount_31_to_60_od)),
                  format_currency(company.payment_collections.sum(:amount_61_to_90_od)),
                  format_currency(company.payment_collections.sum(:amount_more_90_od)),
                  format_currency(company.not_due_outstanting),
                  format_currency(company.payment_collections.sum(:amount_1_to_7_nd)),
                  format_currency(company.payment_collections.sum(:amount_8_to_15_nd)),
                  format_currency(company.payment_collections.sum(:amount_15_to_30_nd)),
                  format_currency(company.payment_collections.sum(:amount_more_30_nd)),
              ]
end

json.recordsTotal Company.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]
