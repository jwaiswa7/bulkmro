json.data (@inquiries) do |inquiry|
  columns = [
      [
          if policy(inquiry).edit?
            row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
          end,
      ].join(' '),
      priority_helper_format_label(inquiry.priority),
      inquiry.inquiry_number,
      status_helper_format_label(inquiry.status),
      inquiry.account.to_s,
      inquiry.company.to_s,
      inquiry.contact.to_s,
      inquiry.inside_sales_owner.to_s,
      inquiry.outside_sales_owner.to_s,
      format_currency(inquiry.calculated_total),
      format_date(inquiry.created_at)
  ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] } ]
  json.merge! columns.merge({"DT_RowClass": "bg-highlight-" + priority_color(inquiry.priority)})
end

json.recordsTotal Inquiry.all.count
json.recordsFiltered @inquiries.total_count
json.draw params[:draw]