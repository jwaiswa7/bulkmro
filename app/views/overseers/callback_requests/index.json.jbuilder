json.data (@callback_requests) do |callback_request|
  columns = [
                  [
                      if is_authorized(callback_request,'show')
                        row_action_button(overseers_callback_request_path(callback_request), 'eye', 'Show Callback Request', 'info', :_blank)
                      end,
                  ].join(' '),
                  status_badge(callback_request.status),
                  callback_request.hits.present? ? callback_request.hits.to_i : nil,
                  format_enum(callback_request.method).to_s.upcase,
                  callback_request.resource,
                  callback_request.response.to_s[0..120],
                  format_succinct_date(callback_request.created_at)
              ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] }]
  json.merge! columns.merge("DT_RowClass": 'bg-highlight-' + status_color(callback_request.status))
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       CallbackRequest.resources.map{ |k, v| { "label": k.titlecase, "value": v.to_s } }.as_json,
                       [],
                       []
                   ]

json.recordsTotal @callback_requests.model.all.count
json.recordsFiltered @indexed_callback_request.total_count
json.draw params[:draw]
