json.data (@accounts) do |account|
  json.array! [
      [
          if policy(account).show?
            row_action_button(ageing_report_overseers_account_companies_path(account_id: account.id), 'eye', 'View Account', 'info', :_blank)
          end,
      ].join(' '),
      account.alias,
      format_currency(account.invoices.not_cancelled_invoices.sum(&:calculated_total_with_tax)),
      format_currency(account.amount_received_against_invoice),
      format_currency(account.amount_received_on_account),
      format_currency(account.total_amount_received),
      format_currency(account.amount_overdue_outstanding),
      format_currency(account.payment_collections.sum(:amount_1_to_30_od)),
      format_currency(account.payment_collections.sum(:amount_31_to_60_od)),
      format_currency(account.payment_collections.sum(:amount_61_to_90_od)),
      format_currency(account.payment_collections.sum(:amount_more_90_od)),
      format_currency(account.not_due_outstanting),
      format_currency(account.payment_collections.sum(:amount_1_to_7_nd)),
      format_currency(account.payment_collections.sum(:amount_8_to_15_nd)),
      format_currency(account.payment_collections.sum(:amount_15_to_30_nd)),
      format_currency(account.payment_collections.sum(:amount_more_30_nd)),
      ]
end

json.recordsTotal Account.count
json.recordsFiltered @accounts.total_count
json.draw params[:draw]
