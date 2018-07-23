class Services::Overseers::Rfqs::SaveAndSend < Services::Shared::BaseService
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    set_subject_and_comments
    send_emails

    inquiry.save
  end

  def set_subject_and_comments
    inquiry.rfqs.each do |rfq|
      rfq.assign_attributes(
          :subject => inquiry.rfq_subject,
          :comments => inquiry.rfq_comments
      )
    end
  end

  def send_emails
    # todo send rfq emails with links
  end

  attr_reader :inquiry
end