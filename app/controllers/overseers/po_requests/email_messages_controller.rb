class Overseers::PoRequests::EmailMessagesController < Overseers::PoRequests::BaseController
  before_action :set_purchase_order_details, only: [:sending_po_to_supplier, :sending_po_to_supplier_notification, :dispatch_from_supplier_delayed, :dispatch_from_supplier_delayed_notification]
``
  def sending_po_to_supplier
    if @po_request.purchase_order.present?
      @email_message = @po_request.purchase_order.email_messages.build(:overseer => current_overseer, :contact => @contact, :inquiry => @inquiry, :sales_order => @po_request.sales_order, to: @to)
      @action = "sending_po_to_supplier_notification"
      @email_message.assign_attributes(
          :subject => "Internal Ref Inq ##{@inquiry.id} Purchase Order ##{@po_request.purchase_order.po_number}",
          :body => PoRequestMailer.purchase_order_details(@email_message).body.raw_source,
          :auto_attach => true
      )
    end
    authorize @po_request, :sending_po_to_supplier_new_email_message?
    render 'new'
  end

  def sending_po_to_supplier_notification
    @email_message = @po_request.purchase_order.email_messages.build(
        :overseer => current_overseer,
        :contact => @contact,
        :inquiry => @inquiry,
        :purchase_order => @po_request.purchase_order,
        :sales_order => @po_request.sales_order,
        :email_type => "Sending PO to Supplier"
    )
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(:cc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(:bcc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize @po_request, :sending_po_to_supplier_create_email_message?

    if @email_message.auto_attach?
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@po_request.purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier})), filename: @po_request.purchase_order.filename(include_extension: true))
    end

    if @email_message.save
        if PoRequestMailer.send_supplier_notification(@email_message).deliver_now
          @po_request.update_attributes(:sent_at => Time.now)
        end
      redirect_to overseers_po_requests_path, notice: flash_message(@po_request, action_name)
    else
      render 'new'
    end
  end

  def dispatch_from_supplier_delayed
    if @po_request.purchase_order.present?
      @action = "dispatch_from_supplier_delayed_notification"
      @email_message = @po_request.purchase_order.email_messages.build(:overseer => current_overseer, :contact => @contact, :inquiry => @inquiry, :to => @to)
      @email_message.assign_attributes(
          :to => @inquiry.inside_sales_owner.email,
          :subject => "Ref # #{@inquiry.id} Delay in Material Delivery",
          :body => PoRequestMailer.dispatch_supplier_delayed(@email_message).body.raw_source,
          :auto_attach => false
      )
    end
    authorize @po_request, :dispatch_supplier_delayed_new_email_message?
    render 'new'
  end

  def dispatch_from_supplier_delayed_notification
    @email_message = @po_request.purchase_order.email_messages.build(
        :overseer => current_overseer,
        :contact => @contact,
        :inquiry => @inquiry,
        :email_type => "Dispatch from Supplier Delayed"
    )
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(:cc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(:bcc => email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize @po_request, :dispatch_supplier_delayed_create_email_message?

    if @email_message.save
      PoRequestMailer.send_dispatch_from_supplier_delayed_notification(@email_message).deliver_now
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
    @contact = @po_request.contact.present? ? @po_request.contact : @supplier.company_contacts.first.contact
    @metadata[:packing] = @purchase_order.get_packing(@metadata)
    @to_email = @po_request.contact_email.present? ? @po_request.try(:contact_email) : @po_request.contact.try(:email)
    @to = @to_email.present? ? @to_email : @supplier.company_contacts.first.contact.email
  end
end
