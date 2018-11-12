class Services::Overseers::Inquiries::UpdateStatus < Services::Shared::BaseService

  def initialize(inquiry, action_performed)
    @inquiry = inquiry
    @action_performed = action_performed
    @status = inquiry.status
  end

  def call
    case action_performed
    when :ack_email_sent then add_inquiry_status('Acknowledgement Mail', inquiry) if status == 'New Inquiry' || status == 'Lead by O/S'
    when :suppliers_selected then add_inquiry_status('Cross Reference', inquiry) if status == 'Acknowledgement Mail' && inquiry.products.present?
    when :sales_quote_saved then add_inquiry_status('Preparing Quotation', inquiry) if status == 'Cross Reference' && inquiry.sales_quote.present?
    when :quotation_email_sent then add_inquiry_status('Quotation Sent', inquiry) if status == 'Preparing Quotation'
    else nil
    end
  end

  private

  def add_inquiry_status(status, inquiry)
    inquiry.update_attributes(:status => status)
    stage = InquiryStatusRecord.remote_uids.key(InquiryStatusRecord.statuses[status])
    InquiryStatusRecord.create(status: status, inquiry: inquiry, remote_uid: stage)
  end

  attr_accessor :inquiry, :status, :action_performed
end