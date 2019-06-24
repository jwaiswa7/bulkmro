class Overseers::OutwardDispatches::EmailMessagesController < Overseers::OutwardDispatches::BaseController
  before_action :set_other_dispatch, only: [:dispatch_mail_to_customer, :dispatch_mail_to_customer_notification]

  def dispatch_mail_to_customer
    # @to = @inquiry.contact.try(:email)
    @to = current_overseer.try(:email)
    # cc_addresses = [@inquiry.inside_sales_owner.try(:email), @inquiry.outside_sales_owner.try(:email), @inquiry.procurement_operations.try(:email), 'sales@bulkmro.com', 'logistics@bulkmro.com'].compact.join(', ')
    cc_addresses = []

    @email_message = @outward_dispatch.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry, sales_order: @sales_order, outward_dispatch: @outward_dispatch, cc: cc_addresses)
    @action = 'dispatch_mail_to_customer_notification'
    @email_message.assign_attributes(
        to: @to,
        subject: "Ref# #{@inquiry.inquiry_number} - Your Order # #{@inquiry.customer_po_number} - Dispatch Notification",
        body: OutwardDispatchMailer.dispatch_mail_to_customer(@email_message).body.raw_source,
        auto_attach: true
    )
    authorize @outward_dispatch, :dispatch_mail_to_customer?
    render 'new'
  end

  def dispatch_mail_to_customer_notification
    @email_message = @outward_dispatch.email_messages.build(
        overseer: current_overseer,
        contact: @contact,
        inquiry: @inquiry,
        sales_order: @sales_order,
    )
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    authorize @outward_dispatch, :dispatch_mail_to_customer_notification?

    if @email_message.auto_attach?
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@sales_invoice, {stamp:true})), filename: 'original_' + @sales_invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@sales_invoice, {duplicate: true, stamp:true})), filename:'duplicate_' + @sales_invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@sales_invoice, {triplicate:true, stamp:true})), filename: 'triplicate_' + @sales_invoice.filename(include_extension: true))
    end

    if @email_message.save
      OutwardDispatchMailer.send_customer_notification(@email_message).deliver_now
      redirect_to overseers_outward_dispatches_path, notice: flash_message(@outward_dispatch, action_name)
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

    def set_other_dispatch
      @ar_invoice_request = @outward_dispatch.ar_invoice_request
      @inquiry = @ar_invoice_request.inquiry
      @sales_order = @ar_invoice_request.sales_order
      @sales_invoice = @ar_invoice_request.sales_invoice
      @contact = @inquiry.contact
    end

end
