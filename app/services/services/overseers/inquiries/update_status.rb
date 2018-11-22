class Services::Overseers::Inquiries::UpdateStatus < Services::Shared::BaseService

  def initialize(subject, inquiry, action_performed, update_inquiry)
    @update_inquiry = update_inquiry
    @subject = subject
    @inquiry = inquiry
    @action_performed = action_performed
    @status = inquiry.status

    if ['Regret','Order Lost','Order Won'].include? @inquiry.status
      @update_inquiry = false
    end
  end

  def call
    case action_performed
    when :new_inquiry then
      add_inquiry_status('New Inquiry', inquiry, nil, update_inquiry)
    when :ack_email_sent then
      add_inquiry_status('Acknowledgement Mail', inquiry, nil, update_inquiry) if status == 'New Inquiry' || status == 'Lead by O/S'
    when :cross_reference then
      add_inquiry_status('Cross Reference', inquiry, nil, update_inquiry) if get_status_value(status) <= get_status_value('Acknowledgement Mail') && inquiry.products.present?
    when :sales_quote_saved then
      add_inquiry_status('Preparing Quotation', inquiry, subject, update_inquiry) if inquiry.sales_quotes.any?
    when :quotation_email_sent then
      add_inquiry_status('Quotation Sent', inquiry, subject, update_inquiry) if status == 'Preparing Quotation' && inquiry.final_sales_quote.present?
    when :expected_order then
      add_inquiry_status('Expected Order', inquiry, subject, update_inquiry)
    when :order_confirmed then
      add_inquiry_status('Draft SO for Approval by Sales Manager', inquiry, subject, update_inquiry)
    when :order_approved_by_sales_manager then
      add_inquiry_status('SO Draft: Pending Accounts Approval', inquiry, subject, update_inquiry)
    when :order_rejected_by_sales_manager then
      add_inquiry_status('SO Rejected by Sales Manager', inquiry, subject, update_inquiry)
    when :order_won then
      add_inquiry_status('Order Won', inquiry, subject, update_inquiry)
    when :sap_rejected then
      add_inquiry_status('SAP Rejected', inquiry, subject, update_inquiry)
    when :order_lost then
      add_inquiry_status('Order Lost', inquiry, subject, update_inquiry)
    when :regret then
      add_inquiry_status('Regret', inquiry, subject, update_inquiry)
    else
      nil
    end
  end

  private

  def add_inquiry_status(status, inquiry, subject, update_inquiry)
    if update_inquiry
      inquiry.update_attributes(:status => status)
    end
    InquiryStatusRecord.where(status: status, inquiry: inquiry, subject_type: subject.try(:class).try(:name), subject_id: subject.try(:id)).first_or_create
  end

  def get_status_value(status)
    Inquiry.statuses[status]
  end


  attr_accessor :subject, :inquiry, :status, :action_performed, :update_inquiry
end