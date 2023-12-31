json.data (@inquiries) do |inquiry|
  columns = [
      [
          if is_authorized(inquiry, 'edit')
            row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
          end,
      ].join(' '),
      priority_helper_format_label(inquiry.priority),
      conditional_link(inquiry.inquiry_number, edit_overseers_inquiry_path(inquiry), is_authorized(inquiry, 'edit')),
      status_badge(inquiry.status),
      inquiry.account.present? ? conditional_link(inquiry.account.to_s, overseers_account_path(inquiry.account), is_authorized(inquiry.account, 'show')) : '-',
      inquiry.company.present? ? conditional_link(inquiry.company.to_s, overseers_company_path(inquiry.company), is_authorized(inquiry.company, 'show')) : '-',
      inquiry.contact.present? ? conditional_link(inquiry.contact.to_s, overseers_contact_path(inquiry.contact), is_authorized(inquiry.contact, 'show')) : '-',
      inquiry.inside_sales_owner.to_s,
      inquiry.outside_sales_owner.to_s,
      format_currency(inquiry.calculated_total),
      format_succinct_date(inquiry.created_at)
  ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] } ]
  json.merge! columns.merge("DT_RowClass": 'bg-highlight-' + smart_queue_priority_color(inquiry.priority))
end

json.columnFilters [
                       [],
                       [],
                       [],
                       Inquiry.statuses.except('Lead by O/S').map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [{ "source": autocomplete_overseers_contacts_path }],
                       Overseer.inside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       [],
                       []
                   ]

json.recordsTotal Inquiry.smart_queue.count
json.recordsFiltered @indexed_inquiries.total_count
json.draw params[:draw]