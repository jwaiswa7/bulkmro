json.data (@remote_requests) do |remote_request|
  json.array! [
                  [
                      if policy(remote_request).show?
                        row_action_button(overseers_remote_request_path(remote_request), 'eye', 'Show remote request', 'warning')
                      end,
                  ].join(' '),
                  if remote_request.subject.present? && policy(remote_request.subject).show?
                    [remote_request.subject.class.name, remote_request.subject.to_s].join(' > ')
                  end,
                  format_enum(remote_request.status),
                  format_enum(remote_request.method),
                  remote_request.resource,
                  format_date(remote_request.created_at)
              ]
end

json.recordsTotal @remote_requests.model.all.count
json.recordsFiltered @remote_requests.total_count
json.draw params[:draw]