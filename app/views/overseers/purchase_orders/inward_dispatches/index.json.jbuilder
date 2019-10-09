json.data (@kits) do |kit|
  json.array! [
                  [
                      if is_authorized(kit, 'show') && policy(kit).show?
                        row_action_button_without_fa(overseers_kit_path(kit), 'bmro-icon-table bmro-icon-used-view', 'View Kit', 'info', :_blank)
                      end,
                      if is_authorized(kit, 'edit') && policy(kit).edit?
                        row_action_button_without_fa(edit_overseers_kit_path(kit), 'bmro-icon-table bmro-icon-pencil', 'Edit Kit', 'warning', :_blank)
                      end
                  ].join(' '),
                  kit.product.name,
                  kit.product.sku,
                  conditional_link(kit.inquiry.inquiry_number, edit_overseers_inquiry_path(kit.inquiry), is_authorized(kit.inquiry, 'edit') && policy(kit.inquiry).edit?),
                  kit.inquiry.inside_sales_owner.full_name,
                  kit.product.brand.to_s,
                  kit.product.category.name,
                  format_boolean_label(kit.synced?, 'synced'),
                  format_boolean_label(kit.product.synced?, 'synced'),
                  format_date(kit.created_at),
                  format_date(kit.product.approval.try(:created_at))
              ]
end

json.recordsTotal @kits.count
json.recordsFiltered @kits.total_count
json.draw params[:draw]
