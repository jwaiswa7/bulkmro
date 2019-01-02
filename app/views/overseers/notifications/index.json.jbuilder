json.data (@notifications) do |notification|
  json.array! [
                  notification.message,
                  notification.overseer.name,
                  time_ago_in_words(notification.created_at)+" ago"
              ]
end

json.recordsTotal @notifications.model.all.count
json.recordsFiltered @notifications.total_count
json.draw params[:draw]
