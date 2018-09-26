json.data (@inquiries) do |inquiry|
  json.array! [
                  [
                      # if policy(inquiry).edit_suppliers?
                      #   row_action_button(edit_suppliers_overseers_inquiry_path(inquiry), 'long-arrow-right', 'Select Suppliers', 'warning')
                      # end,
                      # if policy(inquiry).edit_rfqs?
                      #   row_action_button(edit_rfqs_overseers_inquiry_rfqs_path(inquiry), 'long-arrow-right', 'Generate RFQs', 'warning')
                      # end,
                      if policy(inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
                      end,
                      # if policy(inquiry).edit_quotations?
                      #   row_action_button(edit_quotations_overseers_inquiry_rfqs_path(inquiry), 'long-arrow-right', 'Purchase Quotations', 'warning')
                      # end,
                      # if policy(inquiry).new_sales_approval?
                      #   row_action_button(new_overseers_sales_quote_sales_approval_path(inquiry.sales_quote), 'long-arrow-right', 'Approve Sales Quote', 'warning')
                      # end,
                      # if policy(inquiry).new_sales_order?
                      #   row_action_button(new_overseers_sales_approval_sales_order_path(inquiry.sales_approval), 'long-arrow-right', 'New Sales Order', 'warning')
                      # end,
                  ].join(' '),
                  inquiry.company.to_s,
                  inquiry.contact.to_s,
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  format_date(inquiry.created_at)
              ]
end

json.recordsTotal @inquiries.model.all.count
json.recordsFiltered @inquiries.total_count
json.draw params[:draw]