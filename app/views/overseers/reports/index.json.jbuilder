json.data (@reports) do |report|
  json.array! [
                  [
                      if is_authorized(report,'show')
                        row_action_button(overseers_report_path(report), 'eye', 'Show Report', 'info')
                      end,
                  ].join(' '),
                  report.name.titlecase,
                  report.uid,
                  format_succinct_date(report.updated_at)
              ]
end

json.recordsTotal @reports.model.all.count
json.recordsFiltered @reports.total_count
json.draw params[:draw]