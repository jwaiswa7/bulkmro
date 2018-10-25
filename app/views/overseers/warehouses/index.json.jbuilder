json.data (@warehouses) do |warehouse|
  json.array! [
                  [
                      if policy(warehouse).edit?
                        row_action_button(overseers_warehouse_path(warehouse), 'eye', 'View Warehouse', 'dark')
                      end,
                      if policy(warehouse).edit?
                        row_action_button(edit_overseers_warehouse_path(warehouse), 'pencil', 'Edit Warehouse', 'warning')
                      end,
                  ].join(' '),
                  warehouse.name.to_s,
                  warehouse.address.state.name.to_s,
                  if warehouse.address.gst.to_s.empty?
                      "N/A"
                  else
                    warehouse.address.gst
                  end,
                  warehouse.remote_uid.to_s,
                  warehouse.address.city_name.to_s

  ]
end

json.recordsTotal @warehouses.model.all.count
json.recordsFiltered @indexed_warehouses.total_count
json.draw params[:draw]