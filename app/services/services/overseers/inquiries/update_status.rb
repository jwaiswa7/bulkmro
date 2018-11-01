class Services::Overseers::Inquiries::UpdateStatus < Services::Shared::BaseService

  def initialize(inquiry, action_performed)
    @inquiry = inquiry
    @action_performed = action_performed
    @status = inquiry.status
  end

  def call
    case action_performed
    when :ack_email_sent
      inquiry.update_attributes(:status => :'Acknowledgement Mail') if status == 'New Inquiry' || status == 'Lead by O/S'
    when :suppliers_selected
      inquiry.update_attributes(:status => :'Cross Reference') if status == 'Acknowledgement Mail' && inquiry.products.present?
    when :sales_quote_saved
      inquiry.update_attributes(:status => :'Preparing Quotation') if status == 'Cross Reference' && inquiry.sales_quote.present?
    when :quotation_email_sent
      inquiry.update_attributes(:status => :'Quotation Sent') if status == 'Preparing Quotation'
    else
      nil
    end
  end

  attr_accessor :inquiry, :status, :action_performed
end