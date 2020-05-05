class Services::Overseers::Inquiries::UpdateStatus < Services::Shared::BaseService
  def initialize(subject, action_performed, should_update_status: true)
    @should_update_status = should_update_status
    @subject = subject

    @inquiry = if subject.is_a?(Inquiry)
      subject
    else
      subject.inquiry
    end

    @action_performed = action_performed
    @status = inquiry.status

    if ['Regret', 'Order Lost', 'Order Won'].include? @inquiry.status
      @should_update_status = false
    end
  end

  def call
    case action_performed
    when :new_inquiry then
      log_inquiry_status('New Inquiry')
    when :ack_email_sent then
      log_inquiry_status('Acknowledgement Mail') if status == 'New Inquiry' || status == 'Lead by O/S'
    when :cross_reference then
      log_inquiry_status('Cross Reference') if get_status_value(status) <= get_status_value('Acknowledgement Mail') && inquiry.products.present?
    when :rfq_sent then
      log_inquiry_status('RFQ Sent') if inquiry.supplier_rfqs.present?
    when :pq_received then
      log_inquiry_status('PQ Received') if inquiry.supplier_rfqs.present?
    when :sales_quote_saved then
      log_inquiry_status('Preparing Quotation') if inquiry.sales_quotes.any?
    when :quotation_email_sent then
      log_inquiry_status('Quotation Sent') if status == 'Preparing Quotation' && inquiry.final_sales_quote.present?
    when :expected_order then
      log_inquiry_status('Expected Order')
    when :order_confirmed then
      log_inquiry_status('Draft SO for Approval by Sales Manager')
    when :order_approved_by_sales_manager then
      log_inquiry_status('SO Draft: Pending Accounts Approval')
    when :order_rejected_by_sales_manager then
      log_inquiry_status('SO Rejected by Sales Manager')
    when :order_won then
      log_inquiry_status('Order Won')
    when :sap_rejected then
      log_inquiry_status('Rejected by Accounts')
    when :order_lost then
      log_inquiry_status('Order Lost')
    when :regret_request then
      log_inquiry_status('Regret Request')
    else
      log_inquiry_status(inquiry.status)
    end
  end

  private

    def log_inquiry_status(status)
      if should_update_status
        inquiry.update_attributes(status: status)
      end
      send_notification(status)
      inquiry_status_record = InquiryStatusRecord.where(status: status, inquiry: inquiry, subject_type: subject.class.name, subject_id: subject.try(:id)).first_or_create
      previous_status = inquiry_status_record.fetch_previous_status_record if status != 'New Inquiry'
      minutes = previous_status.present? ? inquiry_status_record.calculate_turn_around_time(previous_status) : ''
      inquiry_status_record.update_attributes(previous_status_record_id: previous_status.id, tat_minutes: minutes) if previous_status.present?
    end

    def get_status_value(status)
      Inquiry.statuses[status]
    end

    def send_notification(status)
      if inquiry.saved_change_to_status && status != 'New Inquiry'
        @notification = Services::Overseers::Notifications::Notify.new(Overseer.system_overseer, 'System')
        @notification.send_inquiry_status_changed(
          inquiry.inside_sales_owner,
            'update',
            inquiry,
            Rails.application.routes.url_helpers.overseers_inquiry_path(inquiry),
            status
        )
      end
    end
    attr_accessor :subject, :inquiry, :status, :action_performed, :should_update_status
end
