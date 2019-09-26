json.data (@measurement_units) do |measurement_unit|
  json.array! [
                  [
                      if is_authorized(measurement_unit,'edit')
                        row_action_button_without_fa(edit_overseers_measurement_unit_path(measurement_unit), 'bmro-icon-table bmro-icon-pencil', 'Edit Measurement Unit', 'warning')
                      end,
                  ].join(' '),
                  conditional_link(measurement_unit.to_s, edit_overseers_measurement_unit_path(measurement_unit),  is_authorized(measurement_unit,'edit')),
                  format_succinct_date(measurement_unit.created_at)
              ]
end

json.recordsTotal @measurement_units.model.all.count
json.recordsFiltered @measurement_units.total_count
json.draw params[:draw]
