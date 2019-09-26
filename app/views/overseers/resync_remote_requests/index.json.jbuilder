json.data (@remote_requests) do |remote_request|
  columns = [
                  [
                      if is_authorized(remote_request,'show')
                        row_action_button_without_fa(overseers_resync_remote_request_path(remote_request), 'bmro-icon-table bmro-icon-used-view', 'Show Remote Request', 'info')
                      end,
                      row_action_button(resend_failed_request_overseers_resync_remote_request_path(remote_request), 'retweet-alt', 'Resend Remote Request', 'warning')
                  ].join(' '),
                  remote_request.hits,
                  if remote_request.subject.present? && is_authorized(remote_request.subject,'show')
                    [remote_request.subject.class.name, remote_request.subject.to_s].join(' > ')
                  end,
                  status_badge(remote_request.status),
                  format_enum(remote_request.method).to_s.upcase,
                  remote_request.manage_remote_request_data(remote_request),
                  remote_request.resource,
                  format_date_with_time(remote_request.created_at)
              ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] }]
  json.merge! columns.merge("DT_RowClass": 'bg-highlight-' + status_color(remote_request.status))
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       RemoteRequest.resources.map { |k, v| { 'label': k.titlecase, 'value': v.to_s } }.as_json,
                       []
                   ]

json.recordsTotal @remote_requests.model.all.count
json.recordsFiltered @remote_requests.total_count
json.draw params[:draw]
