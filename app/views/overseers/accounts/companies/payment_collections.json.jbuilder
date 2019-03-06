json.data (@companies) do |company|
  json.array! [
                  [
                      if policy(company).show?;
                        row_action_button(payment_collection_overseers_company_sales_invoices_path(company), 'eye', 'View Company', 'info', :_blank)
                      end,
                      if policy(company).show? && company.total_amount_outstanding > 0.0
                        row_action_button(new_overseers_payment_collection_email_path(:type =>'Company',:company=> company),  'envelope', 'Send Email', 'dark', :_blank)
                      end
                  ].join(' '),
                  company.account.alias,
                  conditional_link(company.to_s,  overseers_company_path(company), policy(company).show?),
                  format_currency(company.invoices.not_cancelled.sum(&:calculated_total_with_tax)),
                  format_currency(company.amount_received_against_invoice),
                  format_currency(company.amount_received_on_account),
                  format_currency(company.total_amount_received),
                  format_currency(company.amount_overdue_outstanding),
                  format_currency(company.total_amount_outstanding),
              ]
end

json.recordsTotal Company.count
json.recordsFiltered @indexed_companies.total_count
json.draw params[:draw]