class Services::Overseers::Exporters::InquiriesTatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @export_name = 'inquiries_tat'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry ID', 'Inquiry Number', 'Inquiry Created Time', 'Products', 'Inside Sales Owner', 'Sales Quote', 'SO Doc ID', 'Sales Order Number', 'Sales Order Status', 'New Inquiry(Minutes)',  'New Inquiry Date', 'Acknowledgement Mail(Minutes)', 'Acknowledgement Mail(Time)', 'Acknowledgement Mail Date', 'Cross Reference(Minutes)', 'Cross Reference(Time)', 'Cross Reference Date', 'Preparing Quotation(Minutes)', 'Preparing Quotation(Time)', 'Preparing Quotation Date', 'Quotation Sent(Minutes)', 'Quotation Sent(Time)', 'Quotation Sent Date', 'Draft SO for Approval by Sales Manager(Minutes)', 'Draft SO for Approval by Sales Manager(Time)', 'Draft SO for Approval by Sales Manager Date', 'SO Rejected by Sales Manager(Minutes)', 'SO Rejected by Sales Manager(Time)', 'SO Rejected by Sales Manager Date', 'SO Draft: Pending Accounts Approval(Minutes)', 'SO Draft: Pending Accounts Approval(Time)', 'SO Draft: Pending Accounts Approval Date', 'Rejected by Accounts(Minutes)', 'Rejected by Accounts(Time)', 'Rejected by Accounts Date', 'Hold by Accounts(Minutes)', 'Hold by Accounts(Time)', 'Hold by Accounts Date', 'Order Won(Minutes)', 'Order Won(Time)', 'Order Won Date', 'Order Lost(Minutes)', 'Order Lost(Time)', 'Order Lost Date', 'Regret(Minutes)', 'Regret(Time)', 'Regret Date']
  end

  def call
    perform_export_later('InquiriesTatExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end

    @export = Export.create!(export_type: 2, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id, status: 'Processing')

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
        status_acknowledgment_mail_minutes: record.attributes['acknowledgment_mail_mins'],
        status_acknowledgment_mail: record.attributes['acknowledgment_mail_mins'].present? ? humanize(record.attributes['acknowledgment_mail_mins']) : '-',
        time_acknowledgment_mail: record.attributes['acknowledgment_mail_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['acknowledgment_mail_date'])) : '-',
        status_cross_reference_minutes: record.attributes['cross_reference_mins'],
        status_cross_reference: record.attributes['cross_reference_mins'].present? ? humanize(record.attributes['cross_reference_mins']) : '-',
        time_cross_reference: record.attributes['cross_reference_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['cross_reference_date'])) : '-',
        status_preparing_quotation_minutes: record.attributes['preparing_quotation_mins'],
        status_preparing_quotation: record.attributes['preparing_quotation_mins'].present? ? humanize(record.attributes['preparing_quotation_mins']) : '-',
        time_preparing_quotation: record.attributes['preparing_quotation_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['preparing_quotation_date'])) : '-',
        status_quotation_sent_minutes: record.attributes['quotation_sent_mins'],
        status_quotation_sent: record.attributes['quotation_sent_mins'].present? ? humanize(record.attributes['quotation_sent_mins']) : '-',
        time_quotation_sent: record.attributes['quotation_sent_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['quotation_sent_date'])) : '-',
        status_draft_so_appr_by_sales_manager_minutes: record.attributes['draft_so_appr_by_sales_manager_mins'],
        status_draft_so_appr_by_sales_manager: record.attributes['draft_so_appr_by_sales_manager_mins'].present? ? humanize(record.attributes['draft_so_appr_by_sales_manager_mins']) : '-',
        time_draft_so_appr_by_sales_manager: record.attributes['draft_so_appr_by_sales_manager_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['draft_so_appr_by_sales_manager_date'])) : '-',
        status_so_reject_by_sales_manager_minutes: record.attributes['so_reject_by_sales_manager_mins'],
        status_so_reject_by_sales_manager: record.attributes['so_reject_by_sales_manager_mins'].present? ? humanize(record.attributes['so_reject_by_sales_manager_mins']) : '-',
        time_so_reject_by_sales_manager: record.attributes['draft_so_appr_by_sales_manager_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['draft_so_appr_by_sales_manager_date'])) : '-',
        status_so_draft_pending_acct_approval_minutes: record.attributes['so_draft_pending_acct_approval_mins'],
        status_so_draft_pending_acct_approval: record.attributes['so_draft_pending_acct_approval_mins'].present? ? humanize(record.attributes['so_draft_pending_acct_approval_mins']) : '-',
        time_so_draft_pending_acct_approval: record.attributes['so_draft_pending_acct_approval_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['so_draft_pending_acct_approval_date'])) : '-',
        status_rejected_by_accounts_minutes: record.attributes['so_reject_by_sales_manager_mins'],
        status_rejected_by_accounts: record.attributes['so_reject_by_sales_manager_mins'].present? ? humanize(record.attributes['so_reject_by_sales_manager_mins']) : '-',
        time_rejected_by_accounts: record.attributes['so_reject_by_sales_manager_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['so_reject_by_sales_manager_date'])) : '-',
        status_hold_by_accounts_minutes: record.attributes['hold_by_accounts_mins'],
        status_hold_by_accounts: record.attributes['hold_by_accounts_mins'].present? ? humanize(record.attributes['hold_by_accounts_mins']) : '-',
        time_hold_by_accounts: record.attributes['hold_by_accounts_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['hold_by_accounts_date'])) : '-',
        status_order_won_minutes: record.attributes['order_won_mins'],
        status_order_won: record.attributes['order_won_mins'].present? ? humanize(record.attributes['order_won_mins']) : '-',
        time_order_won: record.attributes['order_won_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['order_won_date'])) : '-',
        status_order_lost_minutes: record.attributes['order_lost_mins'],
        status_order_lost: record.attributes['order_lost_mins'].present? ? humanize(record.attributes['order_lost_mins']) : '-',
        time_order_lost: record.attributes['order_lost_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['order_lost_date'])) : '-',
        status_regret_minutes: record.attributes['regret_mins'],
        status_regret: record.attributes['regret_mins'].present? ? humanize(record.attributes['regret_mins']) : '-',
        time_regret: record.attributes['regret_date'].present? ? format_date_with_time(DateTime.parse(record.attributes['regret_date'])) : '-'
      )
    end
    @export.update_attributes(status: 'Completed')
    generate_csv(@export)
  end
end
