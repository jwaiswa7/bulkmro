json.data (@serieses) do |series|
  json.array! [
                  series.id,
                  series.document_type,
                  series.series,
                  series.number_length,
                  series.first_number,
                  series.last_number,
                  series.period_indicator,
                  series.series_name,
                  format_date_time_meridiem(series.created_at),
                  format_date_time_meridiem(series.updated_at)
  ]
end

json.recordsTotal @serieses.model.all.count
json.recordsFiltered @serieses.total_count
json.draw params[:draw]
