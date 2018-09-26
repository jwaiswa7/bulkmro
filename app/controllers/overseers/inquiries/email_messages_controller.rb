class Overseers::Inquiries::EmailMessagesController < Overseers::Inquiries::BaseController
  def new
    @email_message = @inquiry.email_messages.build(:overseer => current_overseer, :contact => @inquiry.contact, :inquiry => @inquiry)
    @email_message.assign_attributes(
        :subject => @inquiry.subject,
        :body => InquiryMailer.acknowledgement(@email_message).body.raw_source
    )

    authorize @inquiry, :new_email_message?
  end

  def create
    @email_message = @inquiry.email_messages.build(:overseer => current_overseer, :contact => @inquiry.contact, :inquiry => @inquiry)
    @email_message.assign_attributes(email_message_params)

    authorize @inquiry, :create_email_message?

    if @email_message.save
      InquiryMailer.send_acknowledgement(@email_message).deliver_later
      redirect_to edit_overseers_inquiry_path(@inquiry), notice: flash_message(@inquiry, action_name)
    else
      render 'new'
    end
  end

  private

  def email_message_params
    params.require(:email_message).permit(
        :subject,
        :body,
        :files => []
    )
  end
end