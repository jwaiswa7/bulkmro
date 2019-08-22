json.data (@indexed_tat_reports) do |inquiry|
  inquiry_record = Inquiry.find_by(inquiry_number: inquiry.attributes['inquiry_number']) if inquiry.attributes['inquiry_number'].present?
  sales_order = SalesOrder.find(inquiry.attributes['so_doc_id']) if inquiry.attributes['so_doc_id'].present?
  json.array! [
                  [],
                  conditional_link(inquiry_record.attributes['inquiry_number'], edit_overseers_inquiry_path(inquiry_record), is_authorized(inquiry_record, 'edit') && policy(inquiry_record).edit?),
                  inquiry.attributes['inquiry_created_at'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['inquiry_created_at'])) : '-',
                  inquiry.attributes['inside_sales_owner'],
                  inquiry.attributes['inquiry_products'].present? ? inquiry.attributes['inquiry_products'] : 0,
                  inquiry.attributes['sales_quote'].present? ? inquiry.attributes['sales_quote'] : '-',
                  inquiry.attributes['so_doc_id'].present? ? inquiry.attributes['so_doc_id'] : '-',
                  inquiry.attributes['sales_order_number'].present? ? conditional_link(inquiry.attributes['sales_order_number'], overseers_inquiry_sales_order_path(inquiry_record, sales_order), is_authorized(sales_order, 'show')) : '-',
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
