json.data (@accounts) do |account|
  json.array! [
                  [
                      if policy(account).show?
                        row_action_button(payment_collections_overseers_account_companies_path(account_id: account.id), 'eye', 'View Account', 'info', :_blank)
                      end,
                      if policy(account).show? && account.total_amount_outstanding > 0.0
                        row_action_button(new_overseers_payment_collection_email_path(type: 'Account', account: account), 'envelope', 'Send Email', 'dark', :_blank)
                      end
                  ].join(' '),
                  account.alias,
                  account.name,
                  format_currency(account.invoices.not_cancelled_invoices.sum(&:calculated_total_with_tax)),
                  format_currency(account.amount_received_against_invoice),
                  format_currency(account.amount_received_on_account),
                  format_currency(account.total_amount_received),
                  format_currency(account.amount_overdue_outstanding),
                  format_currency(account.total_amount_outstanding),
                  format_succinct_date(account.created_at)
              ]
end

json.recordsTotal Account.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]
