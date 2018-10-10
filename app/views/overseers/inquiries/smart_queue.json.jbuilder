json.data (@inquiries) do |inquiry|
  data = [
                  [
                      if policy(inquiry).edit?
                        row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
                      end,
                  ].join(' '),
                  inquiry.inquiry_number,
                  status_helper_format_label(inquiry.status),
                  inquiry.account.to_s,
                  inquiry.company.to_s,
                  inquiry.contact.to_s,
                  inquiry.inside_sales_owner.to_s,
                  inquiry.outside_sales_owner.to_s,
                  format_currency(inquiry.calculated_total),
                  inquiry.color(inquiry.priority.to_f),
                  format_date(inquiry.created_at)
              ]
  data = Hash[data.collect.with_index { |item,index| [index, item] } ]
  json.merge! data
  additions =  {
      "DT_RowClass": "red"
  }
  json.merge! additions
end

json.recordsTotal Inquiry.all.count
json.recordsFiltered @inquiries.total_count
# json.recordsTotal @inquiries.model.all.count
# json.recordsFiltered @inquiries.total_count
json.draw params[:draw]