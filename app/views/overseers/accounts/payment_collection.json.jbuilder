json.data (@accounts) do |account|
  json.array! [
                  [
                      row_action_button(payment_collection_overseers_account_companies_path(account_id: account.id), 'eye', 'View Account', 'info', :_blank)
                  ].join(' '),
                  account.alias,
                  if account.invoices.not_cancelled_invoices.present?
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
                  else
                    ' - '
                  end,
                  '',
                  if account.invoices.not_cancelled_invoices.present? && (account.sales_receipts.with_amount_on_account.present? || account.sales_receipts.with_amount_by_invoice.present?)
                    format_currency(account.invoices.not_cancelled_invoices.sum(&:calculated_total) - (account.sales_receipts.sum(&:payment_amount_received)))
                  else
                    ' - '
                  end,
                  format_succinct_date(account.created_at)
              ]
end

json.recordsTotal @accounts.model.all.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]