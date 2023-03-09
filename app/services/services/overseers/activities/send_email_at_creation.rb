class Services::Overseers::Activities::SendEmailAtCreation < Services::Shared::BaseService
  def initialize(activity, current_overseer)
    @activity = activity
    @current_overseer = current_overseer
  end

  def call
    @activity.overseers.each do |assignee|
      @email_message = @activity.email_messages.build(activity: @activity ,overseer: @current_overseer)
      @email_message.assign_attributes(
      to: assignee.email,
      subject: "Activity is Created",
      body: ActivityMailer.email_activity_creation(@email_message , assignee).body.raw_source,
      )
      if @email_message.save
        service = Services::Shared::EmailMessages::BaseService.new()
        service.send_email_message_with_sendgrid(@email_message)

      end
    end
  end
  attr_accessor :activity, :current_overseer

end



