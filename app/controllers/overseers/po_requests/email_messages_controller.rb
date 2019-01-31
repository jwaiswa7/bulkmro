class Overseers::PoRequests::EmailMessagesController < Overseers::PoRequests::BaseController
  before_action :set_purchase_order_details, only: [:new, :create]

  def new
    if @po_request.purchase_order.present?
      @email_message = @po_request.purchase_order.email_messages.build(:overseer => current_overseer, :contact => @supplier.company_contacts.first.contact, :inquiry => @inquiry, :sales_order => @po_request.sales_order)
      if params[:type] == "sending_purchase_order"
        email_content = @po_request.sending_purchase_order(@email_message, @po_request, @inquiry)
        authorize @po_request, :new_email_message?
      elsif params[:type] == "dispatch_from_supplier_delayed"
        email_content = @po_request.dispatch_from_supplier_delayed(@email_message, @inquiry)
        authorize @po_request, :dispatch_supplier_delayed_new_email_message?
      end
      @email_message.assign_attributes(
          :subject => email_content[:subject],
          :body => email_content[:body].body.raw_source,
          :auto_attach => email_content[:auto_attach]
      )
    end
  end

  def create
    @email_message = @po_request.purchase_order.email_messages.build(
        :overseer => current_overseer,
        :contact => @supplier.company_contacts.first.contact,
        :inquiry => @inquiry,
        :purchase_order => @po_request.purchase_order,
        :sales_order => @po_request.sales_order
    )

    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(:cc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(:bcc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize @po_request, :create_email_message?

    if @email_message.auto_attach?
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@po_request.purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier})), filename: @po_request.purchase_order.filename(include_extension: true))
    end

    if @email_message.save
      if params[:type] == "sending_purchase_order"
        if PoRequestMailer.send_supplier_notification(@email_message).deliver_now
          @po_request.update_attributes(:sent_at => Time.now)
        end
      elsif params[:type] == "dispatch_from_supplier_delayed"
        PoRequestMailer.send_dispatch_from_supplier_delayed_notification(@email_message).deliver_now
      end
      redirect_to overseers_po_requests_path, notice: flash_message(@po_request, action_name)
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
        :files => []
    )
  end

  def set_purchase_order_details
    @inquiry = @po_request.inquiry
    @purchase_order = @po_request.purchase_order
    @metadata = @purchase_order.metadata.deep_symbolize_keys
    @supplier = @purchase_order.get_supplier(@purchase_order.rows.first.metadata['PopProductId'].to_i)
    @metadata[:packing] = @purchase_order.get_packing(@metadata)
  end
end
