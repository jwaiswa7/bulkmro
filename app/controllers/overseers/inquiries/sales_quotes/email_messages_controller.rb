class Overseers::Inquiries::SalesQuotes::EmailMessagesController < Overseers::Inquiries::SalesQuotes::BaseController
  def new
    @email_message = @sales_quote.email_messages.build(:overseer => current_overseer, :contact => @inquiry.contact, :inquiry => @inquiry, :sales_quote => @sales_quote)
    @email_message.assign_attributes(
        :subject => @inquiry.subject,
        :body => SalesQuoteMailer.acknowledgement(@email_message).body.raw_source,
        :auto_attach => true
    )

    authorize @sales_quote, :new_email_message?
  end

  def create
    @email_message = @sales_quote.email_messages.build(
        :overseer => current_overseer,
        :contact => @inquiry.contact,
        :inquiry => @inquiry,
        :sales_quote => @sales_quote
    )

    @email_message.assign_attributes(email_message_params)

    authorize @sales_quote, :create_email_message?

    if @email_message.auto_attach?
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@sales_quote)), filename: @sales_quote.filename(include_extension: true))
    end

    if @email_message.save
      @inquiry.update_attributes(:quotation_date => @sales_quote.created_at.to_date)

      SalesQuoteMailer.send_acknowledgement(@email_message).deliver_now
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry), notice: flash_message(@sales_quote, action_name)
    else
      render 'new'
    end
  end

  private

  def email_message_params
    params.require(:email_message).permit(
        :subject,
        :body,
        :auto_attach,
        :files => []
    )
  end
end