json.data (@callback_requests) do |callback_request|
  columns = [
                  [
                      if policy(callback_request).show?
                        row_action_button(overseers_callback_request_path(callback_request), 'eye', 'Show Remote Request', 'info', :_blank)
                      end,
                  ].join(' '),
                  remote_request_status_badge(callback_request.status),
                  callback_request.hits.present? ? callback_request.hits.to_i : nil ,
                  format_enum(callback_request.method),
                  callback_request.resource,
                  callback_request.response.to_s[0..120],
                  format_date(callback_request.created_at)
              ]
  columns = Hash[columns.collect.with_index {|item, index| [index, item]}]
  json.merge! columns.merge({"DT_RowClass": "bg-highlight-" + remote_request_status_color(callback_request.status)})
end

json.recordsTotal @callback_requests.model.all.count
json.recordsFiltered @callback_requests.total_count
json.draw params[:draw]