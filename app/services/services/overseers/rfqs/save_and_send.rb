class Services::Overseers::Rfqs::SaveAndSend < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    inquiry.rfqs.each do |rfq|
      rfq.assign_attributes(
          :subject => inquiry.rfq_subject,
          :comments => inquiry.rfq_comments
      )
    end

    inquiry.save
  end


  attr_reader :inquiry
end