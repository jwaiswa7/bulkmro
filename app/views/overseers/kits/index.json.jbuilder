json.data (@kits) do |kit|
  json.array! [
                  [
                      if is_authorized(kit, 'show') && policy(kit).show?
                        row_action_button(overseers_kit_path(kit), 'fa-eye', 'View Kit', 'info', :_blank)
                      end,
                      if is_authorized(kit, 'edit') && policy(kit).edit?
                        row_action_button(edit_overseers_kit_path(kit), 'fa-pencil', 'Edit Kit', 'warning', :_blank)
                      end
                  ].join(' '),
                  conditional_link(kit.product.present? ? kit.product.name : '-', overseers_kit_path(kit), is_authorized(kit.product, 'edit')),
                  kit.product.sku,
                  conditional_link(kit.inquiry.inquiry_number, edit_overseers_inquiry_path(kit.inquiry), is_authorized(kit.inquiry, 'edit')),
                  kit.inquiry.inside_sales_owner.full_name,
                  kit.product.brand.to_s,
                  kit.product.category.name,
                  format_boolean(kit.product.is_service?),
                  format_boolean_label(kit.synced?, 'synced'),
                  format_boolean_label(kit.product.synced?, 'synced'),
                  format_succinct_date(kit.created_at),
                  format_succinct_date(kit.product.approval.try(:created_at))
              ]
end

json.recordsTotal @kits.count
json.recordsFiltered @kits.total_count
json.draw params[:draw]