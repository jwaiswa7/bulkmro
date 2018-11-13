class Services::Overseers::Inquiries::UpdateStatus < Services::Shared::BaseService

  def initialize(subject, inquiry, action_performed, update_inquiry)
    @update_inquiry = update_inquiry
    @subject = subject
    @inquiry = inquiry
    @action_performed = action_performed
    @status = inquiry.status
  end

  def call
    case action_performed
    when :ack_email_sent then add_inquiry_status('Acknowledgement Mail', inquiry, nil, update_inquiry ) if status == 'New Inquiry' || status == 'Lead by O/S'
    when :suppliers_selected then add_inquiry_status('Cross Reference', inquiry, nil, update_inquiry ) if status == 'Acknowledgement Mail' && inquiry.products.present?
    when :sales_quote_saved then add_inquiry_status('Preparing Quotation', inquiry, nil, update_inquiry ) if status == 'Cross Reference' && inquiry.sales_quote.present?
    when :quotation_email_sent then add_inquiry_status('Quotation Sent', inquiry, nil, update_inquiry ) if status == 'Preparing Quotation'
    when :expected_order then add_inquiry_status('Expected Order', inquiry, sales_order, update_inquiry )
    when :order_confirmed then add_inquiry_status('Draft SO for Approval by Sales Manager', inquiry, sales_order, update_inquiry )
    when :order_rejected_by_sales_manager then add_inquiry_status('SO Rejected by Sales Manager', inquiry, sales_order, update_inquiry )
    when :order_won then add_inquiry_status('Order Won', inquiry, sales_order, update_inquiry )
    when :sap_rejected then add_inquiry_status('SAP Rejected', inquiry, sales_order, update_inquiry )
    else nil
    end
  end

  private

  def add_inquiry_status(status, inquiry, subject, update_inquiry)
    if update_inquiry
      inquiry.update_attributes(:status => status)
    end
    InquiryStatusRecord.where(status: status, inquiry: inquiry, subject_type: subject.class.name, subject_id: subject.id).first_or_create do |inquiry_status_record|
      inquiry_status_record.remote_uid = status
    end
  end

  attr_accessor :subject, :inquiry, :status, :action_performed, :update_inquiry
end