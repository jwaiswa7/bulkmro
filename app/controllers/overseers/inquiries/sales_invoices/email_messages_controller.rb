class Overseers::Inquiries::SalesInvoices::EmailMessagesController < Overseers::Inquiries::SalesInvoicesController
  before_action :set_sales_invoice, only: [:new, :create]



  def new
    @email_message = @sales_invoice.email_messages.build(overseer: current_overseer, contact: @inquiry.contact, inquiry: @inquiry)
    subject = "Ref# #{@inquiry.inquiry_number}- Your Order #{@inquiry.customer_po_number} - Delivery Notification."
    @email_message.assign_attributes(
      subject: subject,
      body: SalesInvoiceMailer.acknowledgement(@email_message).body.raw_source,
      auto_attach: true,
        )

    authorize @sales_invoice, :new_email_message?
  end

  def create
    @email_message = @sales_invoice.email_messages.build(overseer: current_overseer, contact: @inquiry.contact, inquiry: @inquiry)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    authorize @sales_invoice, :create_email_message?

    if  params['email_message']['auto_attach']
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@sales_invoice, @locals)), filename: @sales_invoice.filename(include_extension: true))
    end
    if @email_message.save!
      SalesInvoiceMailer.send_acknowledgement(@email_message).deliver_now
      Services::Overseers::Inquiries::UpdateStatus.new(@sales_invoice, :ack_email_sent).call

      redirect_to overseers_sales_invoices_path, notice: flash_message(@sales_invoice, action_name)
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

    def set_sales_invoice
      @inquiry = Inquiry.find(params[:inquiry_id])
      @sales_invoice = @inquiry.invoices.find(params[:sales_invoice_id])
      @locals = { stamp: true }
    end
end
