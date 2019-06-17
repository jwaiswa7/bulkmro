json.data (@annual_targets) do |annual_target|
  json.array! [
                  [
                      if policy(annual_target).show?
                        row_action_button(overseers_annual_target_path(annual_target), 'eye', 'View Annual Target', 'info')
                      end,
                      if policy(annual_target).edit?
                        row_action_button(edit_overseers_annual_target_path(annual_target), 'pencil', 'Edit Annual Target', 'warning')
                      end
                  ].join(' '),
                  annual_target.overseer.to_s,
                  annual_target.year,
                  annual_target.inquiry_target,
                  annual_target.invoice_target,
                  annual_target.company_target,
                  annual_target.invoice_margin_target,
                  annual_target.order_target,
                  annual_target.order_margin_target,
                  annual_target.new_client_target
              ]
end

json.recordsTotal @annual_targets.count
json.recordsFiltered @annual_targets.total_count
json.draw params[:draw]
