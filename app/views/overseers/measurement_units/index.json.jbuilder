json.data (@measurement_units) do |mu|
  json.array! [
                  [
                      row_action_button(edit_overseers_measurement_unit_path(mu), 'pencil', 'Edit Measurement Units', 'warning'),
                  ].join(' '),
                  mu.to_s,
                  format_date(mu.created_at)
              ]
end

json.recordsTotal @measurement_units.model.all.count
json.recordsFiltered @measurement_units.total_count
json.draw params[:draw]