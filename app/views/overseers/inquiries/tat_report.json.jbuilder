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
                  inquiry.attributes['acknowledgment_mail_mins'].present? ? inquiry.attributes['acknowledgment_mail_mins'] : '-',
                  inquiry.attributes['acknowledgment_mail_mins'].present? ? humanize(inquiry.attributes['acknowledgment_mail_mins']) : '-',
                  inquiry.attributes['acknowledgment_mail_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['acknowledgment_mail_date'])) : '-',

                  inquiry.attributes['cross_reference_mins'].present? ? inquiry.attributes['cross_reference_mins'] : '-',
                  inquiry.attributes['cross_reference_mins'].present? ? humanize(inquiry.attributes['cross_reference_mins']) : '-',
                  inquiry.attributes['cross_reference_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['cross_reference_date'])) : '-',

                  inquiry.attributes['preparing_quotation_mins'].present? ? inquiry.attributes['preparing_quotation_mins'] : '-',
                  inquiry.attributes['preparing_quotation_mins'].present? ? humanize(inquiry.attributes['preparing_quotation_mins']) : '-',
                  inquiry.attributes['preparing_quotation_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['preparing_quotation_date'])) : '-',

                  inquiry.attributes['quotation_sent_mins'].present? ? inquiry.attributes['quotation_sent_mins'] : '-',
                  inquiry.attributes['quotation_sent_mins'].present? ? humanize(inquiry.attributes['quotation_sent_mins']) : '-',
                  inquiry.attributes['quotation_sent_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['quotation_sent_date'])) : '-',

                  inquiry.attributes['draft_so_appr_by_sales_manager_mins'].present? ? inquiry.attributes['draft_so_appr_by_sales_manager_mins'] : '-',
                  inquiry.attributes['draft_so_appr_by_sales_manager_mins'].present? ? humanize(inquiry.attributes['draft_so_appr_by_sales_manager_mins']) : '-',
                  inquiry.attributes['draft_so_appr_by_sales_manager_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['draft_so_appr_by_sales_manager_date'])) : '-',

                  inquiry.attributes['so_reject_by_sales_manager_mins'].present? ? inquiry.attributes['so_reject_by_sales_manager_mins'] : '-',
                  inquiry.attributes['so_reject_by_sales_manager_mins'].present? ? humanize(inquiry.attributes['so_reject_by_sales_manager_mins']) : '-',
                  inquiry.attributes['so_reject_by_sales_manager_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['so_reject_by_sales_manager_date'])) : '-',

                  inquiry.attributes['so_draft_pending_acct_approval_mins'].present? ? inquiry.attributes['so_draft_pending_acct_approval_mins'] : '-',
                  inquiry.attributes['so_draft_pending_acct_approval_mins'].present? ? humanize(inquiry.attributes['so_draft_pending_acct_approval_mins']) : '-',
                  inquiry.attributes['so_draft_pending_acct_approval_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['so_draft_pending_acct_approval_date'])) : '-',

                  inquiry.attributes['rejected_by_accounts_mins'].present? ? inquiry.attributes['rejected_by_accounts_mins'] : '-',
                  inquiry.attributes['rejected_by_accounts_mins'].present? ? humanize(inquiry.attributes['rejected_by_accounts_mins']) : '-',
                  inquiry.attributes['rejected_by_accounts_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['rejected_by_accounts_date'])) : '-',

                  inquiry.attributes['hold_by_accounts_mins'].present? ? inquiry.attributes['hold_by_accounts_mins'] : '-',
                  inquiry.attributes['hold_by_accounts_mins'].present? ? humanize(inquiry.attributes['hold_by_accounts_mins']) : '-',
                  inquiry.attributes['hold_by_accounts_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['hold_by_accounts_date'])) : '-',

                  inquiry.attributes['order_won_mins'].present? ? inquiry.attributes['order_won_mins'] : '-',
                  inquiry.attributes['order_won_mins'].present? ? humanize(inquiry.attributes['order_won_mins']) : '-',
                  inquiry.attributes['order_won_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['order_won_date'])) : '-',

                  inquiry.attributes['order_lost_mins'].present? ? inquiry.attributes['order_lost_mins'] : '-',
                  inquiry.attributes['order_lost_mins'].present? ? humanize(inquiry.attributes['order_lost_mins']) : '-',
                  inquiry.attributes['order_lost_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['order_lost_date'])) : '-',

                  inquiry.attributes['regret_mins'].present? ? inquiry.attributes['regret_mins'] : '-',
                  inquiry.attributes['regret_mins'].present? ? humanize(inquiry.attributes['regret_mins']) : '-',
                  inquiry.attributes['regret_date'].present? ? format_date_with_time(DateTime.parse(inquiry.attributes['regret_date'])) : '-'
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
