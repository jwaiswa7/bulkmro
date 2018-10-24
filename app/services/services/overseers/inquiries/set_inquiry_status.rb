class Services::Overseers::Inquiries::SetInquiryStatus < Services::Shared::BaseService

  def initialize(inquiry, action_name = nil)
    @inquiry = inquiry
    @action_name = action_name
  end

  def call
    if (inquiry.status == 'New Inquiry' || inquiry.status == 'Lead by O/S') && action_name == "acknowledgement email sent"
      inquiry.update_attributes(:status => :'Acknowledgement Mail')
    elsif inquiry.status == 'Acknowledgement Mail' && inquiry.products.present? && !action_name
      inquiry.update_attributes(:status => :'Cross Reference')
    elsif inquiry.status == ('Cross Reference' && inquiry.sales_quote.present?) || action_name == "quotation saved"
      inquiry.update_attributes(:status => :'Preparing Quotation')
    elsif inquiry.status == 'Preparing Quotation'|| action_name == "quotation sent"
      inquiry.update_attributes(:status => :'Quotation Sent')
    end
  end

  attr_accessor :inquiry, :action_name
end