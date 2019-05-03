json.data (@outward_dispatches) do |outward_dispatch|
  json.array! [
                  [
                      if policy(outward_dispatch).show?
                        row_action_button(overseers_outward_dispatch_path(outward_dispatch), 'eye', 'View Outward Dispatch', 'info', :_blank)
                      end,
                      if policy(outward_dispatch).edit?
                        row_action_button(edit_overseers_outward_dispatch_path(outward_dispatch), 'pencil', 'Edit Outward Dispatch', 'warning', :_blank)
                      end
                  ].join(' '),
                  outward_dispatch.product.name,
                  outward_dispatch.product.sku,
                  conditional_link(outward_dispatch.inquiry.inquiry_number, edit_overseers_inquiry_path(outward_dispatch.inquiry), policy(outward_dispatch.inquiry).edit?),
                  outward_dispatch.inquiry.inside_sales_owner.full_name,
                  outward_dispatch.product.brand.to_s,
                  outward_dispatch.product.category.name,
                  format_boolean_label(outward_dispatch.synced?, 'synced'),
                  format_boolean_label(outward_dispatch.product.synced?, 'synced'),
                  format_date(outward_dispatch.created_at),
                  format_date(outward_dispatch.product.approval.try(:created_at))
              ]
end

json.recordsTotal @outward_dispatches.count
json.recordsFiltered @outward_dispatches.total_count
json.draw params[:draw]
