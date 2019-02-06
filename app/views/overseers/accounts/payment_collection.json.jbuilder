json.data (@accounts) do |account|
  json.array! [
                  [
                      row_action_button(overseers_account_path(account), 'eye', 'View Account', 'info', :_blank)
                  ].join(' '),
                  account.alias,
                  if account.invoices.present?
                    format_currency(account.invoices.not_cancelled_invoices.sum(&:calculated_total))
                  else
                    ' - '
                  end,
                  if account.sales_receipts.with_amount_by_invoice.present?
                    format_currency(account.sales_receipts.with_amount_by_invoice.sum(&:payment_amount_received))
                  else
                     ' - '
                  end,
                  if account.sales_receipts.with_amount_on_account.present?
                    format_currency(account.sales_receipts.with_amount_on_account.sum(&:payment_amount_received))
                  else
                    ' - '
                  end,
                  if account.sales_receipts.with_amount_on_account.present? || account.sales_receipts.with_amount_by_invoice.present?
                    format_currency(account.sales_receipts.sum(&:payment_amount_received))
                  end,
                  20,
                  ' - ',
                  format_succinct_date(account.created_at)
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]