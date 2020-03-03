json.data (@inquiry_product_suppliers) do |inquiry_product_supplier|
  json.array! [
                  [
                    # if is_authorized(inquiry_product_suppliers ,'show')
                    #   row_action_button(overseers_inquiry_product_suppliers_path(inquiry_product_suppliers), 'eye', 'View Outward Dispatch', 'info', :_blank)
                    # end,
                    # if is_authorized(inquiry_product_suppliers,'edit')
                    #   row_action_button(edit_overseers_inquiry_product_suppliers_path(inquiry_product_suppliers), 'edit', 'Edit Outward Dispatch', 'warning', :_blank)
                    # end,
                    # if is_authorized(inquiry_product_suppliers, 'index')
                    #   link_to('', class: ['btn btn-sm btn-success comment-outward-dispatch'], 'data-model-id': inquiry_product_suppliers.id, title: 'Comment', remote: true) do
                    #     concat content_tag(:span, '')
                    #     concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
                    #   end
                    # end,

                  ].join(' '),
                  link_to(@inquiry.inquiry_number, edit_overseers_inquiry_path(@inquiry), target: '_blank'),
                  inquiry_product_supplier.inquiry_product.to_s,
                  inquiry_product_supplier.supplier.to_s,
                  inquiry_product_supplier.inquiry_product.quantity,
                  inquiry_product_supplier.lead_time,
                  inquiry_product_supplier.unit_cost_price,
                  inquiry_product_supplier.final_unit_price,
                  inquiry_product_supplier.total_price,
                  inquiry_product_supplier.remarks,
                  format_date(inquiry_product_supplier.created_at),
              ]
end

json.recordsTotal @inquiry_product_suppliers.count
json.recordsFiltered @inquiry_product_suppliers.count
json.draw params[:draw]
