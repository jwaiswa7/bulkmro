json.data (@indexed_tat_reports) do |inquiry|
  json.array! [
                  [],
                  inquiry.attributes['inquiry_number'],
                  inquiry.attributes['inquiry_created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['inquiry_created_at'])) : '-',
                  inquiry.attributes['inside_sales_owner'],
                  inquiry.attributes['inquiry_products'].present? ? inquiry.attributes['inquiry_products'] : 0,
                  inquiry.attributes['sales_quote'].present? ? inquiry.attributes['sales_quote'] : '-',
                  inquiry.attributes['so_doc_id'].present? ? inquiry.attributes['so_doc_id'] : '-',
                  inquiry.attributes['sales_order_number'].present? ? inquiry.attributes['sales_order_number'] : '-',
                  inquiry.attributes['sales_order_status'].present? ? inquiry.attributes['sales_order_status'] : '-',
                  '-',
                  inquiry.attributes['time_new_inquiry'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['time_new_inquiry'])) : '-',
                  inquiry.attributes['status_acknowledgment_mail'][0]['tat'].present? ? inquiry.attributes['status_acknowledgment_mail'][0]['tat'] : '-',
                  inquiry.attributes['status_acknowledgment_mail'][0]['tat'].present? ? humanize(inquiry.attributes['status_acknowledgment_mail'][0]['tat']) : '-',
                  inquiry.attributes['status_acknowledgment_mail'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_acknowledgment_mail'][0]['created_at'])) : '-',

                  inquiry.attributes['status_cross_reference'][0]['tat'].present? ? inquiry.attributes['status_cross_reference'][0]['tat'] : '-',
                  inquiry.attributes['status_cross_reference'][0]['tat'].present? ? humanize(inquiry.attributes['status_cross_reference'][0]['tat']) : '-',
                  inquiry.attributes['status_cross_reference'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_cross_reference'][0]['created_at'])) : '-',

                  inquiry.attributes['status_preparing_quotation'][0]['tat'].present? ? inquiry.attributes['status_preparing_quotation'][0]['tat'] : '-',
                  inquiry.attributes['status_preparing_quotation'][0]['tat'].present? ? humanize(inquiry.attributes['status_preparing_quotation'][0]['tat']) : '-',
                  inquiry.attributes['status_preparing_quotation'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_preparing_quotation'][0]['created_at'])) : '-',

                  inquiry.attributes['status_quotation_sent'][0]['tat'].present? ? inquiry.attributes['status_quotation_sent'][0]['tat'] : '-',
                  inquiry.attributes['status_quotation_sent'][0]['tat'].present? ? humanize(inquiry.attributes['status_quotation_sent'][0]['tat']) : '-',
                  inquiry.attributes['status_quotation_sent'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_quotation_sent'][0]['created_at'])) : '-',
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['tat'].present? ? inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['tat'] : '-',
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['tat'].present? ? humanize(inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['tat']) : '-',
                  inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_draft_so_appr_by_sales_manager'][0]['created_at'])) : '-',

                  inquiry.attributes['status_so_reject_by_sales_manager'][0]['tat'].present? ? inquiry.attributes['status_so_reject_by_sales_manager'][0]['tat'] : '-',
                  inquiry.attributes['status_so_reject_by_sales_manager'][0]['tat'].present? ? humanize(inquiry.attributes['status_so_reject_by_sales_manager'][0]['tat']) : '-',
                  inquiry.attributes['status_so_reject_by_sales_manager'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_so_reject_by_sales_manager'][0]['created_at'])) : '-',

                  inquiry.attributes['status_so_draft_pending_acct_approval'][0]['tat'].present? ? inquiry.attributes['status_so_draft_pending_acct_approval'][0]['tat'] : '-',
                  inquiry.attributes['status_so_draft_pending_acct_approval'][0]['tat'].present? ? humanize(inquiry.attributes['status_so_draft_pending_acct_approval'][0]['tat']) : '-',
                  inquiry.attributes['status_so_draft_pending_acct_approval'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_so_draft_pending_acct_approval'][0]['created_at'])) : '-',

                  inquiry.attributes['status_rejected_by_accounts'][0]['tat'].present? ? inquiry.attributes['status_rejected_by_accounts'][0]['tat'] : '-',
                  inquiry.attributes['status_rejected_by_accounts'][0]['tat'].present? ? humanize(inquiry.attributes['status_rejected_by_accounts'][0]['tat']) : '-',
                  inquiry.attributes['status_rejected_by_accounts'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_rejected_by_accounts'][0]['created_at'])) : '-',

                  inquiry.attributes['status_hold_by_accounts'][0]['tat'].present? ? inquiry.attributes['status_hold_by_accounts'][0]['tat'] : '-',
                  inquiry.attributes['status_hold_by_accounts'][0]['tat'].present? ? humanize(inquiry.attributes['status_hold_by_accounts'][0]['tat']) : '-',
                  inquiry.attributes['status_hold_by_accounts'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_hold_by_accounts'][0]['created_at'])) : '-',
                  inquiry.attributes['status_order_won'][0]['tat'].present? ? inquiry.attributes['status_order_won'][0]['tat'] : '-',
                  inquiry.attributes['status_order_won'][0]['tat'].present? ? humanize(inquiry.attributes['status_order_won'][0]['tat']) : '-',
                  inquiry.attributes['status_order_won'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_order_won'][0]['created_at'])) : '-',

                  inquiry.attributes['status_order_lost'][0]['tat'].present? ? inquiry.attributes['status_order_lost'][0]['tat'] : '-',
                  inquiry.attributes['status_order_lost'][0]['tat'].present? ? humanize(inquiry.attributes['status_order_lost'][0]['tat']) : '-',
                  inquiry.attributes['status_order_lost'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_order_lost'][0]['created_at'])) : '-',

                  inquiry.attributes['status_regret'][0]['tat'].present? ? inquiry.attributes['status_regret'][0]['tat'] : '-',
                  inquiry.attributes['status_regret'][0]['tat'].present? ? humanize(inquiry.attributes['status_regret'][0]['tat']) : '-',
                  inquiry.attributes['status_regret'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['status_regret'][0]['created_at'])) : '-'
              ]
end

json.columnFilters [
                       [],
                       [],
                       [],
                       Overseer.inside.alphabetical.map {|s| {"label": s.full_name, "value": s.id.to_s}}.as_json,
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
