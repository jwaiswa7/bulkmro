json.data (@kits) do |kit|
  json.array! [
                  [
                      if policy(kit).show?
                        row_action_button(overseers_kit_path(kit), 'eye', 'View Kit', 'info')
                      end,
                      if policy(kit).edit?
                        row_action_button(edit_overseers_kit_path(kit), 'pencil', 'Edit Kit', 'warning')
                      end
                  ].join(' '),
                  kit.product.name,
                  kit.product.sku,
                  kit.product.brand.to_s,
                  kit.product.category.name,
                  format_boolean_label(kit.synced?, 'synced'),
                  format_boolean_label(kit.product.synced?, 'synced'),
                  format_date(kit.created_at),
                  format_date(kit.product.approval.try(:created_at))
              ]
end

json.recordsTotal @kits.model.all.count
json.recordsFiltered @kits.count
json.draw params[:draw]