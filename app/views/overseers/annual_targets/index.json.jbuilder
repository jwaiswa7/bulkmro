json.data (@annual_targets) do |annual_target|
  json.array! [
                  [],
                  annual_target.overseer.to_s,
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
