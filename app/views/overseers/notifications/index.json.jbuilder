json.data (@notifications) do |notification|
  json.array! [
                  notification.id,
                  notification.message,
                  format_date(notification.created_at)
              ]
end

json.recordsTotal @notifications.model.all.count
json.recordsFiltered @notifications.total_count
json.draw params[:draw]
