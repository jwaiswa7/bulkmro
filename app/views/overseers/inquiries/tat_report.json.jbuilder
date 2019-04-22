json.data (@indexed_tat_reports) do |inquiry|
  json.array! [
                  [],
                  inquiry.attributes['inquiry_number'],
                  inquiry.attributes['inquiry_created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['inquiry_created_at'])) : '-',
                  inquiry.attributes['inquiry_products'],
                  inquiry.attributes['inside_sales_owner'],
                  inquiry.attributes['sales_quote'],
                  inquiry.attributes['so_doc_id'],
                  inquiry.attributes['sales_order_number'],
                  inquiry.attributes['sales_order_status'],
                  '-',
                  '-',
                  '-',
                  inquiry.attributes['time_new_inquiry'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_new_inquiry'])) : '-',
                  inquiry.attributes['status_acknowledgment_mail'],
                  inquiry.attributes['status_acknowledgment_mail'].present? ? ((inquiry.attributes['status_acknowledgment_mail']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_acknowledgment_mail'].present? ? ((inquiry.attributes['status_acknowledgment_mail']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_acknowledgment_mail'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_acknowledgment_mail'])) : '-',
                  inquiry.attributes['status_cross_reference'],
                  inquiry.attributes['status_cross_reference'].present? ? ((inquiry.attributes['status_cross_reference']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_cross_reference'].present? ? ((inquiry.attributes['status_cross_reference']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_cross_reference'],
                  inquiry.attributes['status_preparing_quotation'],
                  inquiry.attributes['status_preparing_quotation'].present? ? ((inquiry.attributes['status_preparing_quotation']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_preparing_quotation'].present? ? ((inquiry.attributes['status_preparing_quotation']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_preparing_quotation'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_preparing_quotation'])) : '-',
                  inquiry.attributes['status_quotation_sent'],
                  inquiry.attributes['status_quotation_sent'].present? ? ((inquiry.attributes['status_quotation_sent']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_quotation_sent'].present? ? ((inquiry.attributes['status_quotation_sent']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_quotation_sent'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_quotation_sent'])) : '-',
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'],
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'].present? ? ((inquiry.attributes['status_draft_so_appr_by_sales_manager']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'].present? ? ((inquiry.attributes['status_draft_so_appr_by_sales_manager']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_draft_so_appr_by_sales_manager'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_draft_so_appr_by_sales_manager'])) : '-',
                  inquiry.attributes['status_so_reject_by_sales_manager'],
                  inquiry.attributes['status_so_reject_by_sales_manager'].present? ? ((inquiry.attributes['status_so_reject_by_sales_manager']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_so_reject_by_sales_manager'].present? ? ((inquiry.attributes['status_so_reject_by_sales_manager']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_so_reject_by_sales_manager'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_so_reject_by_sales_manager'])) : '-',
                  inquiry.attributes['status_so_draft_pending_acct_approval'],
                  inquiry.attributes['status_so_draft_pending_acct_approval'].present? ? ((inquiry.attributes['status_so_draft_pending_acct_approval']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_so_draft_pending_acct_approval'].present? ? ((inquiry.attributes['status_so_draft_pending_acct_approval']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_so_draft_pending_acct_approval'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_so_draft_pending_acct_approval'])) : '-',
                  inquiry.attributes['status_rejected_by_accounts'],
                  inquiry.attributes['status_rejected_by_accounts'].present? ? ((inquiry.attributes['status_rejected_by_accounts']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_rejected_by_accounts'].present? ? ((inquiry.attributes['status_rejected_by_accounts']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_rejected_by_accounts'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_rejected_by_accounts'])) : '-',
                  inquiry.attributes['status_hold_by_accounts'],
                  inquiry.attributes['status_hold_by_accounts'].present? ? ((inquiry.attributes['status_hold_by_accounts']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_hold_by_accounts'].present? ? ((inquiry.attributes['status_hold_by_accounts']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_hold_by_accounts'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_hold_by_accounts'])) : '-',
                  inquiry.attributes['status_order_won'],
                  inquiry.attributes['status_order_won'].present? ? ((inquiry.attributes['status_order_won']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_order_won'].present? ? ((inquiry.attributes['status_order_won']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_order_won'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_order_won'])) : '-',
                  inquiry.attributes['status_order_lost'],
                  inquiry.attributes['status_order_lost'].present? ? ((inquiry.attributes['status_order_lost']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_order_lost'].present? ? ((inquiry.attributes['status_order_lost']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_order_lost'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_order_lost'])) : '-',
                  inquiry.attributes['status_regret'],
                  inquiry.attributes['status_regret'].present? ? ((inquiry.attributes['status_regret']) / 60.0).ceil.abs : '-',
                  inquiry.attributes['status_regret'].present? ? ((inquiry.attributes['status_regret']) / 1440.0).ceil.abs : '-',
                  inquiry.attributes['time_regret'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_regret'])) : '-'
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       [],
                       []
                   ]

json.recordsTotal @indexed_tat_reports.count
json.recordsFiltered @indexed_tat_reports.total_count
json.draw params[:draw]
