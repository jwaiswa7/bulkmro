json.data (@accounts) do |account|
  json.array! [
                  [
                      if policy(account).show?
                        row_action_button(payment_collection_overseers_account_companies_path(account_id: account.id), 'eye', 'View Account', 'info', :_blank)
                      end,
                      if policy(account).show?
                        row_action_button(new_overseers_payment_collection_email_path(:type =>'Account',:account => account), 'envelope', 'Send Email', 'dark', :_blank)
                      end
                  ].join(' '),
                  account.alias,
                  if account.invoices.not_cancelled_invoices.present?
                    format_currency(account.invoices.not_cancelled_invoices.sum(&:calculated_total_with_tax))
                  else
                    ' - '
                  end,
                  if account.sales_receipts.with_amount_by_invoice.present?
                   format_currency(account.amount_received_against_invoice)
                  else
                     ' - '
                  end,
                  if account.sales_receipts.with_amount_on_account.present?
                   format_currency(account.amount_received_on_account)
                  else
                    ' - '
                  end,
                  if account.sales_receipts.with_amount_on_account.present? || account.sales_receipts.with_amount_by_invoice.present?
                   format_currency(account.total_amount_received)
                  else
                    ' - '
                  end,
                  format_currency(account.amount_overdue_outstanding),
                  if account.invoices.not_cancelled_invoices.present? && (account.sales_receipts.with_amount_on_account.present? || account.sales_receipts.with_amount_by_invoice.present?)
                    format_currency(account.total_amount_outstanding)
                  else
                    ' - '
                  end,
                  format_succinct_date(account.created_at)
              ]
end

json.recordsTotal Account.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]