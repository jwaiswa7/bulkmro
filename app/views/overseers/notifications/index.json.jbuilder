json.data (@notifications) do |notification|
  json.array! [
                  [
                    if notification.action_url.present?
                      row_action_button(notification.action_url, 'external-link', 'View', 'info')
                    end,
                  ].join(' '),
                  notification.message,
                  notification.sender.name,
                  time_ago_in_words(notification.created_at) + ' ago'
              ]
end

json.recordsTotal @notifications.model.all.count
json.recordsFiltered @notifications.total_count
json.draw params[:draw]
