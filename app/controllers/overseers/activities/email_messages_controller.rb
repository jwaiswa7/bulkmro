class Overseers::Activities::EmailMessagesController < Overseers::Activities::BaseController
  def new
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @email_message.assign_attributes(
      to: @activity.contact.email,
      subject: "Minutes of Meeting",
      body: ActivityMailer.minutes_of_meeting(@email_message).body.raw_source,
    )

    # authorize_acl @inquiry, 'new_email_message'
  end

  def create
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?
    # authorize_acl @activity, 'create_email_message'

    if @email_message.save
      ActivityMailer.send_minutes_of_meeting(@email_message).deliver_now
    #   Services::Overseers::Inquiries::UpdateStatus.new(@activity, :ack_email_sent).call

      redirect_to overseers_activities_path, notice: "Email Message has Successfully Send"
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
          files: []
      )
    end
end
