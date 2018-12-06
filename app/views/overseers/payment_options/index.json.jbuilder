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
                  payment_option.name.to_s,
                  payment_option.credit_limit,
                  payment_option.general_discount,
                  payment_option.load_limit,
                  payment_option.remote_uid.to_s,
                  payment_option.created_by.present? ? payment_option.created_by.full_name : "-",
                  payment_option.updated_by.present? ? payment_option.updated_by.full_name : "-",
                  format_date_time_meridiem(payment_option.created_at),
                  format_date_time_meridiem(payment_option.updated_at)
  ]
end

json.recordsTotal @payment_options.model.all.count
json.recordsFiltered @payment_options.total_count
json.draw params[:draw]