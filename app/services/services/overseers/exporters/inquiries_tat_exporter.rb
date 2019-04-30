class Services::Overseers::Exporters::InquiriesTatExporter < Services::Overseers::Exporters::BaseExporter
  def initialize(*params)
    super(*params)
    @model = Inquiry
    @export_name = 'inquiries_tat'
    @path = Rails.root.join('tmp', filename)
    @columns = ['Inquiry ID', 'Inquiry Number', 'Inquiry Created Time', 'Products', 'Inside Sales Owner', 'Sales Quote', 'SO Doc ID', 'Sales Order Number', 'Sales Order Status', 'New Inquiry(Minutes)', 'New Inquiry', 'New Inquiry Date', 'Acknowledgement Mail(Minutes)', 'Acknowledgement Mail', 'Acknowledgement Mail Date', 'Cross Reference(Minutes)', 'Cross Reference', 'Cross Reference Date', 'Preparing Quotation(Minutes)', 'Preparing Quotation', 'Preparing Quotation Date', 'Quotation Sent(Minutes)', 'Quotation Sent', 'Quotation Sent Date', 'Draft SO for Approval by Sales Manager(Minutes)', 'Draft SO for Approval by Sales Manager', 'Draft SO for Approval by Sales Manager Date', 'SO Rejected by Sales Manager(Minutes)', 'SO Rejected by Sales Manager', 'SO Rejected by Sales Manager Date', 'SO Draft: Pending Accounts Approval(Minutes)', 'SO Draft: Pending Accounts Approval', 'SO Draft: Pending Accounts Approval Date', 'Rejected by Accounts(Minutes)', 'Rejected by Accounts', 'Rejected by Accounts Date', 'Hold by Accounts(Minutes)', 'Hold by Accounts', 'Hold by Accounts Date', 'Order Won(Minutes)', 'Order Won', 'Order Won Date', 'Order Lost(Minutes)', 'Order Lost', 'Order Lost Date', 'Regret(Minutes)', 'Regret', 'Regret Date']
  end

  def call
    perform_export_later('InquiriesTatExporter', @arguments)
  end

  def build_csv
    if @indexed_records.present?
      records = @indexed_records
    end
    records.each do |record|
      rows.push(
        inquiry_id: record.id,
        inquiry_number: record.inquiry_number,
        inquiry_created_at: record.inquiry_created_at,
        inquiry_products: record.inquiry_products,
        inside_sales_owner: record.inside_sales_owner,
        sales_quote: record.sales_quote.present? ? record.sales_quote : '-',
        so_doc_id: record.so_doc_id.present? ? record.so_doc_id : '-',
        sales_order_number: record.sales_order_number.present? ? record.sales_order_number : '-',
        sales_order_status: record.sales_order_status.present? ? record.sales_order_status : '-',
        new_inquiry_minutes: '-',
        new_inquiry: '-',
        time_new_inquiry: '-',
        status_acknowledgment_mail_minutes: record.status_acknowledgment_mail,
        status_acknowledgment_mail: record.status_acknowledgment_mail.present? ? humanize(record.status_acknowledgment_mail) : '-',
        time_acknowledgment_mail: record.time_acknowledgment_mail.present? ? format_date_with_time(DateTime.parse(record.time_acknowledgment_mail)) : '-',
        status_cross_reference_minutes: record.status_cross_reference,
        status_cross_reference: record.status_cross_reference.present? ? humanize(record.status_cross_reference) : '-',
        time_cross_reference: record.time_cross_reference.present? ? format_date_with_time(DateTime.parse(record.time_cross_reference)) : '-',
        status_preparing_quotation_minutes: record.status_preparing_quotation,
        status_preparing_quotation: record.status_preparing_quotation.present? ? humanize(record.status_preparing_quotation) : '-',
        time_preparing_quotation: record.time_preparing_quotation.present? ? format_date_with_time(DateTime.parse(record.time_preparing_quotation)) : '-',
        status_quotation_sent_minutes: record.status_quotation_sent,
        status_quotation_sent: record.status_quotation_sent.present? ? humanize(record.status_quotation_sent) : '-',
        time_quotation_sent: record.time_quotation_sent.present? ? format_date_with_time(DateTime.parse(record.time_quotation_sent)) : '-',
        status_draft_so_appr_by_sales_manager_minutes: record.status_draft_so_appr_by_sales_manager,
        status_draft_so_appr_by_sales_manager: record.status_draft_so_appr_by_sales_manager.present? ? humanize(record.status_draft_so_appr_by_sales_manager) : '-',
        time_draft_so_appr_by_sales_manager: record.time_draft_so_appr_by_sales_manager.present? ? format_date_with_time(DateTime.parse(record.time_draft_so_appr_by_sales_manager)) : '-',
        status_so_reject_by_sales_manager_minutes: record.status_so_reject_by_sales_manager,
        status_so_reject_by_sales_manager: record.status_so_reject_by_sales_manager.present? ? humanize(record.status_so_reject_by_sales_manager) : '-',
        time_so_reject_by_sales_manager: record.time_so_reject_by_sales_manager.present? ? format_date_with_time(DateTime.parse(record.time_so_reject_by_sales_manager)) : '-',
        status_so_draft_pending_acct_approval_minutes: record.status_so_draft_pending_acct_approval,
        status_so_draft_pending_acct_approval: record.status_so_draft_pending_acct_approval.present? ? humanize(record.status_so_draft_pending_acct_approval) : '-',
        time_so_draft_pending_acct_approval: record.time_so_draft_pending_acct_approval.present? ? format_date_with_time(DateTime.parse(record.time_so_draft_pending_acct_approval)) : '-',
        status_rejected_by_accounts_minutes: record.status_rejected_by_accounts,
        status_rejected_by_accounts: record.status_rejected_by_accounts.present? ? humanize(record.status_rejected_by_accounts) : '-',
        time_rejected_by_accounts: record.time_rejected_by_accounts.present? ? format_date_with_time(DateTime.parse(record.time_rejected_by_accounts)) : '-',
        status_hold_by_accounts_minutes: record.status_hold_by_accounts,
        status_hold_by_accounts: record.status_hold_by_accounts.present? ? humanize(record.status_hold_by_accounts) : '-',
        time_hold_by_accounts: record.time_hold_by_accounts.present? ? format_date_with_time(DateTime.parse(record.time_hold_by_accounts)) : '-',
        status_order_won_minutes: record.status_order_won,
        status_order_won: record.status_order_won.present? ? humanize(record.status_order_won) : '-',
        time_order_won: record.time_order_won.present? ? format_date_with_time(DateTime.parse(record.time_order_won)) : '-',
        status_order_lost_minutes: record.status_order_lost,
        status_order_lost: record.status_order_lost.present? ? humanize(record.status_order_lost) : '-',
        time_order_lost: record.time_order_lost.present? ? format_date_with_time(DateTime.parse(record.time_order_lost)) : '-',
        status_regret_minutes: record.status_regret,
        status_regret: record.status_regret.present? ? humanize(record.status_regret) : '-',
        time_regret: record.time_regret.present? ? format_date_with_time(DateTime.parse(record.time_regret)) : '-'
      )
    end
    export = Export.create!(export_type: 2, filtered: false, created_by_id: @overseer.id, updated_by_id: @overseer.id)
    generate_csv(export)
  end
end
