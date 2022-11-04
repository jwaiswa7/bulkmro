class Overseers::Activities::EmailMessagesController < Overseers::Activities::BaseController
  def minutes_of_meeting
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @action = 'minutes_of_meeting_notification'
    @email_message.assign_attributes(
      to: @activity&.contact&.email,
      subject: "Minutes of Meeting",
      body: ActivityMailer.minutes_of_meeting(@email_message).body.raw_source,
    )

    # authorize_acl @inquiry, 'new_email_message'
    render 'new'
  end

  def minutes_of_meeting_notification
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?
    # authorize_acl @activity, 'create_email_message'

    if @email_message.save     
      ActivityMailer.send_minutes_of_meeting(@email_message).deliver_now
      @activity.update_attributes(activity_status: 'MOM Sent')
      redirect_to overseers_activities_path, notice: "Email Message has Successfully Send"
    else
      render 'new'
    end
  end

  def follow_up_email
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @action = 'follow_up_email_notification'
    @email_message.assign_attributes(
      to: @activity&.contact&.email,
      subject: "Following up - #{@activity.company&.name} <> Bulk MRO Industrial Supply Pvt Ltd",
      body: ActivityMailer.follow_up(@email_message).body.raw_source,
    )

    # authorize_acl @inquiry, 'new_email_message'
    render 'new'
  end

  def follow_up_email_notification
    @email_message = @activity.email_messages.build(overseer: current_overseer, activity: @activity)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?
    # authorize_acl @activity, 'create_email_message'

    if @email_message.save
      ActivityMailer.send_follow_up(@email_message).deliver_now
      @activity.update_attributes(activity_status: 'Customer follow-up email sent')
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
