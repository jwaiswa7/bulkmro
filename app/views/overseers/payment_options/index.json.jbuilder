

json.data (@payment_options) do |payment_option|
  json.array! [
                  [
                      if policy(payment_option).edit?
                        row_action_button(overseers_payment_option_path(payment_option), 'eye', 'View Payment Term', 'info')
                      end,
                      if policy(payment_option).edit?
                        row_action_button(edit_overseers_payment_option_path(payment_option), 'pencil', 'Edit Payment Term', 'warning')
                      end,
                  ].join(' '),
                  conditional_link(payment_option.name.to_s, overseers_payment_option_path(payment_option), policy(payment_option).edit?),
                  number_with_delimiter(payment_option.credit_limit, delimiter: ','),
                  number_with_delimiter(payment_option.general_discount, delimiter: ','),
                  number_with_delimiter(payment_option.load_limit, delimiter: ','),
                  payment_option.remote_uid.to_s,
                  format_boolean_label(payment_option.synced?, 'synced'),
                  format_succinct_date(payment_option.created_at)

  ]
end

json.recordsTotal @payment_options.model.all.count
json.recordsFiltered @payment_options.total_count
json.draw params[:draw]
