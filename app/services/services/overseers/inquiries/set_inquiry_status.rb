class Services::Overseers::Inquiries::SetInquiryStatus < Services::Shared::BaseService

  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    # update statuses of existing inquiries

    # set status for new inquiry creation
    if inquiry.status == 'New Inquiry' || inquiry.status == 'Lead by O/S'
      inquiry.update_attributes(:status => :'Acknowledgement Mail')
    elsif inquiry.status == 'Acknowledgement Mail'
      inquiry.update_attributes(:status => :'Cross Reference')
    elsif inquiry.status == 'Cross Reference' && inquiry.sales_quote.present?
      inquiry.update_attributes(:status => :'Preparing Quotation')
    elsif inquiry.status == 'Preparing Quotation'
      inquiry.update_attributes(:status => :'Quotation Sent')
    end

  end

  attr_accessor :inquiry
end