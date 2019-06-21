class Services::Shared::EmailMessages::SendEmail < Services::Shared::EmailMessages::BaseService
  def initialize(entity)
    @entity = entity
  end

  def new
    @email_message = @entity.email_messages.build(overseer: current_overseer, contact: @entity.contact, inquiry: @entity)
    @email_message.assign_attributes(subject: @entity.subject,
        body: InquiryMailer.acknowledgement(@email_message).body.raw_source,
    )

    authorize @entity, :new_email_message?
  end



  def create
    @email_message = @entity.email_messages.build(overseer: current_overseer, contact: @entity.contact, inquiry: @entity)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?
    authorize @entity, :create_email_message?

    if @email_message.save
      InquiryMailer.send_acknowledgement(@email_message).deliver_now
      Services::Overseers::Inquiries::UpdateStatus.new(@entity, :ack_email_sent).call

      redirect_to edit_overseers_inquiry_path(@entity), notice: flash_message(@inquiry, action_name)
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
