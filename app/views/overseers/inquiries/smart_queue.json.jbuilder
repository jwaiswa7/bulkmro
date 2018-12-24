json.data (@inquiries) do |inquiry|
  columns = [
      [
          if policy(inquiry).edit?
            row_action_button(edit_overseers_inquiry_path(inquiry), 'pencil', 'Edit Inquiry', 'warning')
          end,
      ].join(' '),
      priority_helper_format_label(inquiry.priority),
      link_to(inquiry.inquiry_number, edit_overseers_inquiry_path(inquiry), target: '_blank'),
      status_badge(inquiry.status),
      link_to(inquiry.account.to_s, overseers_account_path(inquiry.account), target: "_blank"),
      link_to(inquiry.company.to_s, overseers_company_path(inquiry.company), target: "_blank"),
      link_to(inquiry.contact.to_s, overseers_contact_path(inquiry.contact), target: "_blank"),
      inquiry.inside_sales_owner.to_s,
      inquiry.outside_sales_owner.to_s,
      format_currency(inquiry.calculated_total),
      format_date(inquiry.created_at)
  ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] } ]
  json.merge! columns.merge({"DT_RowClass": "bg-highlight-" + smart_queue_priority_color(inquiry.priority)})
end

json.columnFilters [
                       [],
                       [],
                       [],
                       Inquiry.statuses.map {|k, v| {:"label" => k, :"value" => v.to_s}}.as_json,
                       [{"source": autocomplete_overseers_accounts_path}],
                       [{"source": autocomplete_overseers_companies_path}],
                       [{"source": autocomplete_overseers_contacts_path}],
                       Overseer.inside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       Overseer.outside.alphabetical.map {|s| {:"label" => s.full_name, :"value" => s.id.to_s}}.as_json,
                       [],
                       []
                   ]

json.recordsTotal Inquiry.smart_queue.count
json.recordsFiltered @indexed_inquiries.total_count
json.draw params[:draw]