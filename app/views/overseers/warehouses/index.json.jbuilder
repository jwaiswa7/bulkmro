# frozen_string_literal: true

json.data (@warehouses) do |warehouse|
  json.array! [
                  [
                      if policy(warehouse).edit?
                        row_action_button(overseers_warehouse_path(warehouse), 'eye', 'View Warehouse', 'info')
                      end,
                      if policy(warehouse).edit?
                        row_action_button(edit_overseers_warehouse_path(warehouse), 'pencil', 'Edit Warehouse', 'warning')
                      end,
                  ].join(' '),
                  conditional_link(warehouse.name.to_s, overseers_warehouse_path(warehouse), policy(warehouse).edit?),
                  warehouse.address.state.name.to_s,
                  if warehouse.address.gst.to_s.empty?
                    'N/A'
                  else
                    warehouse.address.gst
                  end,
                  warehouse.remote_uid.to_s,
                  warehouse.address.city_name.to_s

  ]
end

json.recordsTotal @warehouses.model.all.count
json.recordsFiltered @warehouses.total_count
json.draw params[:draw]
