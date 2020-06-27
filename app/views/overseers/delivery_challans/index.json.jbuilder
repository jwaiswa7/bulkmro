json.data (@delivery_challans) do |delivery_challan|
  columns = [
      [
          # if is_authorized(delivery_challan.inquiry, 'relationship_map') && policy(delivery_challan.inquiry).relationship_map?
          #   row_action_button(relationship_map_overseers_inquiry_path(delivery_challan.inquiry.to_param), 'sitemap', 'Relationship Map', 'info', :_blank)
          # end,
          # if is_authorized(delivery_challan.inquiry, 'new_freight_request') && policy(delivery_challan.inquiry).new_freight_request?
          #   row_action_button(new_overseers_freight_request_path(inquiry_id: delivery_challan.inquiry.to_param), 'external-link', 'New Freight Request', 'warning')
          # end,
          # if is_authorized(delivery_challan.inquiry, 'add_comment')
          #   link_to('', class: ['icon-title btn btn-sm btn-success comment-inquiry'], 'data-model-id': delivery_challan.inquiry.id, title: 'Comment','data-title': 'Comment', remote: true) do
          #     concat content_tag(:span, '')
          #     concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
          #   end
          # end,
      ].join(' '),
      link_to(delivery_challan.inquiry.inquiry_number, edit_overseers_inquiry_path(delivery_challan.inquiry), target: '_blank'),
      link_to(delivery_challan.sales_order.order_number, overseers_inquiry_sales_order_path(delivery_challan.inquiry, delivery_challan.sales_order), target: '_blank'),
      delivery_challan.sales_order.rows.map(&:quantity).sum.to_i,
      delivery_challan.rows.map(&:quantity).sum.to_i + '/',
      status_badge(inquiry.status), 
      link_to(inquiry.account.to_s, overseers_account_path(inquiry.account), target: '_blank'),
      link_to(inquiry.company.to_s, overseers_company_path(inquiry.company), target: '_blank'),
      inquiry.customer_po_sheet.attached? ? link_to(["<i class='bmro-fa-file-alt'></i>", inquiry.po_subject].join('').html_safe, inquiry.customer_po_sheet, target: '_blank') : inquiry.po_subject,
      format_succinct_date(inquiry.quotation_followup_date),
      format_succinct_date(inquiry.customer_committed_date),
      if inquiry.contact.present?
        link_to(inquiry.contact.to_s, overseers_contact_path(inquiry.contact), target: '_blank')
      end,
      inquiry.inside_sales_owner.to_s,
      inquiry.outside_sales_owner.to_s,
      inquiry.opportunity_type,
      inquiry.margin_percentage,
      format_currency(inquiry.try(:potential_amount), show_symbol: false),
      format_currency(inquiry.final_sales_quote.try(:calculated_total), show_symbol: false),
      format_succinct_date(inquiry.created_at)
  ]
  columns = Hash[columns.collect.with_index { |item, index| [index, item] }]
  json.merge! columns.merge("DT_RowClass": inquiry.status == 'Order Won' ? 'bg-highlight-success' : '')
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       Inquiry.statuses.except('Lead by O/S').map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [{ "source": autocomplete_overseers_accounts_path }],
                       [{ "source": autocomplete_overseers_companies_path }],
                       [],
                       [],
                       [],
                       [{ "source": autocomplete_overseers_contacts_path }],
                       Overseer.inside_with_additional_overseers.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Overseer.outside_with_additional_overseers.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       Inquiry.opportunity_types.map { |k, v| { "label": k, "value": v.to_s } }.as_json,
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal Inquiry.all.count
json.recordsFiltered @indexed_inquiries.total_count
json.recordsTotalValue @total_values
json.draw params[:draw]
json.recordsSummary Inquiry.statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsMainSummary Inquiry.main_summary_statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json