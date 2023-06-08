class Overseers::Companies::EmailMessagesController < Overseers::Companies::BaseController

    def new 
        @email_message = @company.email_messages.build(overseer: current_overseer)
        @email_message.assign_attributes(
          to: @company.contacts&.first&.email,
          subject: "Request for customer feedback",
          body: CustomerFeedbackMailer.feedback_requested(@email_message).body.raw_source,
          auto_attach: false
        )
    end

   def create

    @email_message = @company.email_messages.build(overseer: current_overseer)
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?
  
    if @email_message.save
        CustomerFeedbackMailer.request_feedback(@email_message).deliver_later
      redirect_to overseers_company_path(@company), notice: flash_message(@email_message, action_name)
    else
      render 'new'
    end

   end

   private 

   def email_message_params
    params.require(:email_message).permit(
      :subject,
        :body,
        :to,
        :cc,
        :bcc,
        :auto_attach,
        files: []
    )
   end

end