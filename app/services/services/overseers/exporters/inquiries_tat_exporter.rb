class Services::Overseers::Exporters::InquiriesTatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @export_name = 'inquiries_tat'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry ID', 'Inquiry Number', 'Inquiry Created Time', 'Products', 'Inside Sales Owner', 'Sales Quote', 'SO Doc ID', 'Sales Order Number', 'Sales Order Status', 'New Inquiry(Minutes)',  'New Inquiry Date', 'Acknowledgement Mail(Minutes)', 'Acknowledgement Mail(Time)', 'Acknowledgement Mail Date', 'Cross Reference(Minutes)', 'Cross Reference(Time)', 'Cross Reference Date', 'Preparing Quotation(Minutes)', 'Preparing Quotation(Time)', 'Preparing Quotation Date', 'Quotation Sent(Minutes)', 'Quotation Sent(Time)', 'Quotation Sent Date', 'Draft SO for Approval by Sales Manager(Minutes)', 'Draft SO for Approval by Sales Manager(Time)', 'Draft SO for Approval by Sales Manager Date', 'SO Rejected by Sales Manager(Minutes)', 'SO Rejected by Sales Manager(Time)', 'SO Rejected by Sales Manager Date', 'SO Draft: Pending Accounts Approval(Minutes)', 'SO Draft: Pending Accounts Approval(Time)', 'SO Draft: Pending Accounts Approval Date', 'Rejected by Accounts(Minutes)', 'Rejected by Accounts(Time)', 'Rejected by Accounts Date', 'Hold by Accounts(Minutes)', 'Hold by Accounts(Time)', 'Hold by Accounts Date', 'Order Won(Minutes)', 'Order Won(Time)', 'Order Won Date', 'Order Lost(Minutes)', 'Order Lost(Time)', 'Order Lost Date', 'Regret(Minutes)', 'Regret(Time)', 'Regret Date']
    @export.update_attributes(export_type: 2, status: 'Enqueued')
  end

  def call
    perform_export_later('InquiriesTatExporter', @arguments)
  end

  def build_csv
    @export.update_attributes(status: 'Processing')
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |record|
      rows.push(
        inquiry_id: record.attributes['id'],
        inquiry_number: record.attributes['inquiry_number'],
        inquiry_created_at: format_date_with_time(DateTime.parse(record.attributes['inquiry_created_at'])),
        inquiry_products: record.attributes['inquiry_products'],
        inside_sales_owner: record.attributes['inside_sales_owner'],
        sales_quote: record.attributes['sales_quote'].present? ? record.attributes['sales_quote'] : '-',
        so_doc_id: record.attributes['so_doc_id'].present? ? record.attributes['so_doc_id'] : '-',
        sales_order_number: record.attributes['sales_order_number'].present? ? record.attributes['sales_order_number'] : '-',
        sales_order_status: record.attributes['sales_order_status'].present? ? record.attributes['sales_order_status'] : '-',
        new_inquiry_minutes: '-',
        time_new_inquiry: record.attributes['time_new_inquiry'].present? ? format_date_with_time(DateTime.parse(record.attributes['time_new_inquiry'])) : '-',
        status_acknowledgment_mail_minutes: record.attributes['status_acknowledgment_mail'][0]['tat'],
        status_acknowledgment_mail: record.attributes['status_acknowledgment_mail'].present? ? humanize(record.attributes['status_acknowledgment_mail'][0]['tat']) : '-',
        time_acknowledgment_mail: record.attributes['status_acknowledgment_mail'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_acknowledgment_mail'][0]['created_at'])) : '-',
        status_cross_reference_minutes: record.attributes['status_cross_reference'][0]['tat'],
        status_cross_reference: record.attributes['status_cross_reference'].present? ? humanize(record.attributes['status_cross_reference'][0]['tat']) : '-',
        time_cross_reference: record.attributes['status_cross_reference'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_cross_reference'][0]['created_at'])) : '-',
        status_preparing_quotation_minutes: record.attributes['status_preparing_quotation'][0]['tat'],
        status_preparing_quotation: record.attributes['status_preparing_quotation'].present? ? humanize(record.attributes['status_preparing_quotation'][0]['tat']) : '-',
        time_preparing_quotation: record.attributes['status_preparing_quotation'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_preparing_quotation'][0]['created_at'])) : '-',
        status_quotation_sent_minutes: record.attributes['status_quotation_sent'][0]['tat'],
        status_quotation_sent: record.attributes['status_quotation_sent'].present? ? humanize(record.attributes['status_quotation_sent'][0]['tat']) : '-',
        time_quotation_sent: record.attributes['status_quotation_sent'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_quotation_sent'][0]['created_at'])) : '-',
        status_draft_so_appr_by_sales_manager_minutes: record.attributes['status_draft_so_appr_by_sales_manager'][0]['tat'],
        status_draft_so_appr_by_sales_manager: record.attributes['status_draft_so_appr_by_sales_manager'].present? ? humanize(record.attributes['status_draft_so_appr_by_sales_manager'][0]['tat']) : '-',
        time_draft_so_appr_by_sales_manager: record.attributes['status_draft_so_appr_by_sales_manager'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_draft_so_appr_by_sales_manager'][0]['created_at'])) : '-',
        status_so_reject_by_sales_manager_minutes: record.attributes['status_so_reject_by_sales_manager'][0]['tat'],
        status_so_reject_by_sales_manager: record.attributes['status_so_reject_by_sales_manager'].present? ? humanize(record.attributes['status_so_reject_by_sales_manager'][0]['tat']) : '-',
        time_so_reject_by_sales_manager: record.attributes['status_so_reject_by_sales_manager'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_so_reject_by_sales_manager'][0]['created_at'])) : '-',
        status_so_draft_pending_acct_approval_minutes: record.attributes['status_so_draft_pending_acct_approval'][0]['tat'],
        status_so_draft_pending_acct_approval: record.attributes['status_so_draft_pending_acct_approval'].present? ? humanize(record.attributes['status_so_draft_pending_acct_approval'][0]['tat']) : '-',
        time_so_draft_pending_acct_approval: record.attributes['status_so_draft_pending_acct_approval'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_so_draft_pending_acct_approval'][0]['created_at'])) : '-',
        status_rejected_by_accounts_minutes: record.attributes['status_rejected_by_accounts'][0]['tat'],
        status_rejected_by_accounts: record.attributes['status_rejected_by_accounts'].present? ? humanize(record.attributes['status_rejected_by_accounts'][0]['tat']) : '-',
        time_rejected_by_accounts: record.attributes['status_rejected_by_accounts'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_rejected_by_accounts'][0]['created_at'])) : '-',
        status_hold_by_accounts_minutes: record.attributes['status_hold_by_accounts'][0]['tat'],
        status_hold_by_accounts: record.attributes['status_hold_by_accounts'].present? ? humanize(record.attributes['status_hold_by_accounts'][0]['tat']) : '-',
        time_hold_by_accounts: record.attributes['status_hold_by_accounts'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_hold_by_accounts'][0]['created_at'])) : '-',
        status_order_won_minutes: record.attributes['status_order_won'][0]['tat'],
        status_order_won: record.attributes['status_order_won'].present? ? humanize(record.attributes['status_order_won'][0]['tat']) : '-',
        time_order_won: record.attributes['status_order_won'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_order_won'][0]['created_at'])) : '-',
        status_order_lost_minutes: record.attributes['status_order_lost'][0]['tat'],
        status_order_lost: record.attributes['status_order_lost'].present? ? humanize(record.attributes['status_order_lost'][0]['tat']) : '-',
        time_order_lost: record.attributes['status_order_lost'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_order_lost'][0]['created_at'])) : '-',
        status_regret_minutes: record.attributes['status_regret'][0]['tat'],
        status_regret: record.attributes['status_regret'].present? ? humanize(record.attributes['status_regret'][0]['tat']) : '-',
        time_regret: record.attributes['status_regret'][0]['created_at'].present? ? format_date_with_time(DateTime.parse(record.attributes['status_regret'][0]['created_at'])) : '-'
      )
    end
    # export = Export.create!(export_type: 2, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
