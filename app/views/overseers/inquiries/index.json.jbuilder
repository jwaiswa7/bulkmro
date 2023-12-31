json.data (@inquiries) do |inquiry|
  columns = [
      [
          if is_authorized(inquiry, 'relationship_map') && policy(inquiry).relationship_map?
            row_action_button(relationship_map_overseers_inquiry_path(inquiry.to_param), 'sitemap', 'Relationship Map', 'info', :_blank)
          end,
          if is_authorized(inquiry, 'edit') && policy(inquiry).edit?
            row_action_button(overseers_inquiry_comments_path(inquiry), 'comment-alt-check', inquiry.comments.last ? inquiry.comments.last.try(:message) : 'No comments', inquiry.comments.last ? 'success' : 'dark', :_blank)
          end,
          if is_authorized(inquiry, 'new_freight_request') && policy(inquiry).new_freight_request?
            row_action_button(new_overseers_freight_request_path(inquiry_id: inquiry.to_param), 'external-link', 'New Freight Request', 'warning')
          end,
          if is_authorized(inquiry, 'add_comment')
            link_to('', class: ['icon-title btn btn-sm btn-success comment-inquiry'], 'data-model-id': inquiry.id, title: 'Comment','data-title': 'Comment', remote: true) do
              concat content_tag(:span, '')
              concat content_tag :i, nil, class: ['fal fa-comment-lines'].join
            end
          end,
          if is_authorized(:delivery_challan, 'create') && (policy(inquiry).create_new_dc?)
            row_action_button_without_fa(new_overseers_delivery_challan_path(inquiry_id: inquiry.id, created_from: inquiry.class), 'bmro-plus-circle-icon', 'New Delivery Challan', 'success', target: :_blank)
          end,
      ].join(' '),
      link_to(inquiry.inquiry_number, edit_overseers_inquiry_path(inquiry), target: '_blank'),
      inquiry.sales_orders.where.not(order_number: nil).map { |sales_order| link_to(sales_order.order_number, overseers_inquiry_sales_order_path(inquiry, sales_order), target: '_blank') }.compact.join(' '),
      inquiry.invoices.map { |invoice| link_to(invoice.invoice_number, overseers_inquiry_sales_invoices_path(inquiry), target: '_blank') }.compact.join(' '),
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
      inquiry.sales_manager.to_s,
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
                       Overseer.managers.alphabetical.map { |s| { "label": s.full_name, "value": s.id.to_s } }.as_json,
                       []
                   ]

json.recordsTotal Inquiry.all.count
json.recordsFiltered @indexed_inquiries.total_count
json.recordsTotalValue @total_values
json.draw params[:draw]
json.recordsSummary Inquiry.statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json
json.recordsMainSummary Inquiry.main_summary_statuses.map { |status, status_id| { status_id: status_id, "label": status, "size": @statuses[status_id] } }.as_json