class Overseers::PoRequests::EmailMessagesController < Overseers::PoRequests::BaseController
  before_action :set_purchase_order_details, only: [:sending_po_to_supplier, :sending_po_to_supplier_notification, :dispatch_from_supplier_delayed, :dispatch_from_supplier_delayed_notification, :material_received_in_bm_warehouse, :material_received_in_bm_warehouse_notification]
  ``
  def sending_po_to_supplier
    # if !current_overseer.accounts?
    @company_reviews = [@po_request.company_reviews.where(created_by: current_overseer, survey_type: 'Sales', company: @po_request.supplier).first_or_create]
    # end
    @to = @po_request.contact_email.present? ? @po_request.try(:contact_email) : @po_request.contact.try(:email)
    cc_addresses = [@po_request.purchase_order.logistics_owner.try(:email), 'sales@bulkmro.com', 'logistics@bulkmro.com'].compact.join(', ')
    if @po_request.purchase_order.present?
      @email_message = @po_request.purchase_order.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry, sales_order: @po_request.sales_order, cc: cc_addresses)
      @action = 'sending_po_to_supplier_notification'
      @email_message.assign_attributes(
        to: @to,
        subject: "Internal Ref Inq ##{@inquiry.inquiry_number} Purchase Order ##{@po_request.purchase_order.po_number}",
        body: PoRequestMailer.purchase_order_details(@email_message).body.raw_source,
        auto_attach: true
      )
    end
    authorize_acl @po_request, 'sending_po_to_supplier_new_email_message'
    render 'new'
  end

  def sending_po_to_supplier_notification
    @email_message = @po_request.purchase_order.email_messages.build(
      overseer: current_overseer,
      contact: @contact,
      inquiry: @inquiry,
      purchase_order: @po_request.purchase_order,
      sales_order: @po_request.sales_order,
      email_type: 'Sending PO to Supplier'
    )
    @metadata = @po_request.purchase_order.metadata.deep_symbolize_keys
    @payment_terms = PaymentOption.find_by(remote_uid: @metadata[:PoPaymentTerms])
    @metadata[:packing] = @purchase_order.get_packing(@metadata)
    @supplier = get_supplier(@purchase_order, @purchase_order.rows.first.metadata['PopProductId'].to_i)
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    authorize_acl @po_request, 'sending_po_to_supplier_create_email_message'
    if @email_message.auto_attach.present? && @email_message.auto_attach != false
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@purchase_order, locals: {inquiry: @inquiry, purchase_order: @purchase_order, metadata: @metadata, supplier: @supplier, payment_terms: @payment_terms})), filename: @purchase_order.filename(include_extension: true))
    end
    if @email_message.save
      if PoRequestMailer.send_supplier_notification(@email_message).deliver_now
        @po_request.update_attributes(sent_at: Time.now, status: :'Supplier PO Sent')
      end
      if @po_request.purchase_order.present? && @po_request.status == 'Supplier PO Sent' && @po_request.purchase_order.has_sent_email_to_supplier? && !@po_request.purchase_order.material_status.present?
        @po_request.purchase_order.material_status = 'Material Readiness Follow-Up'
        @po_request.purchase_order.save
      end
      redirect_to overseers_po_requests_path, notice: flash_message(@po_request, action_name)
    else
      render 'new'
    end
  end

  def dispatch_from_supplier_delayed
    if @po_request.purchase_order.present?
      @action = 'dispatch_from_supplier_delayed_notification'
      @email_message = @po_request.purchase_order.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry)
      @email_message.assign_attributes(
        to: @inquiry.inside_sales_owner.email,
        subject: "Ref # #{@inquiry.inquiry_number} Delay in Material Delivery",
        body: PoRequestMailer.dispatch_supplier_delayed(@email_message).body.raw_source,
        auto_attach: false
      )
    end
    authorize_acl @po_request, 'dispatch_supplier_delayed_new_email_message'
    render 'new'
  end

  def dispatch_from_supplier_delayed_notification
    @email_message = @po_request.purchase_order.email_messages.build(
      overseer: current_overseer,
      contact: @contact,
      inquiry: @inquiry,
      email_type: 'Dispatch from Supplier Delayed'
    )
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    authorize_acl @po_request, 'dispatch_supplier_delayed_create_email_message'

    if @email_message.save
      PoRequestMailer.send_dispatch_from_supplier_delayed_notification(@email_message).deliver_now
      redirect_to overseers_po_requests_path, notice: flash_message(@po_request, action_name)
    else
      render 'new'
    end
  end

  def material_received_in_bm_warehouse
    if @po_request.purchase_order.present?
      @action = 'material_received_in_bm_warehouse_notification'
      @email_message = @po_request.purchase_order.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry)
      @email_message.assign_attributes(
        to: @inquiry.inside_sales_owner.email,
        subject: "Ref # #{@inquiry.inquiry_number} Material Received in BM Warehouse",
        body: PoRequestMailer.material_received_in_bm_warehouse_details(@email_message).body.raw_source,
        auto_attach: false
      )
    end
    authorize_acl @po_request, 'material_received_in_bm_warehouse_new_email_msg'
    render 'new'
  end

  def material_received_in_bm_warehouse_notification
    @email_message = @po_request.purchase_order.email_messages.build(
      overseer: current_overseer,
      contact: @contact,
      inquiry: @inquiry,
      email_type: 'Material Received in BM Warehouse'
    )
    @email_message.assign_attributes(email_message_params)
    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    authorize_acl @po_request, 'material_received_in_bm_warehouse_create_email_msg'

    if @email_message.save
      PoRequestMailer.send_material_received_in_bm_warehouse_notification(@email_message).deliver_now
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
          files: []
      )
    end

    def set_purchase_order_details
      @inquiry = @po_request.inquiry
      @purchase_order = @po_request.purchase_order
      @metadata = @purchase_order.metadata.deep_symbolize_keys
      @supplier = @purchase_order.get_supplier(@purchase_order.rows.first.metadata['PopProductId'].to_i)
      @contact = @po_request.contact
      @metadata[:packing] = @purchase_order.get_packing(@metadata)
    end

    def get_supplier(purchase_order, product_id)
      if purchase_order.metadata['PoSupNum'].present?
        product_supplier = (Company.find_by_legacy_id(purchase_order.metadata['PoSupNum']) || Company.find_by_remote_uid(purchase_order.metadata['PoSupNum']))
        return product_supplier if purchase_order.inquiry.suppliers.include?(product_supplier) || purchase_order.is_legacy?
      end
      if purchase_order.inquiry.final_sales_quote.present?
        product_supplier = purchase_order.inquiry.final_sales_quote.rows.select {|sales_quote_row| sales_quote_row.product.id == product_id || sales_quote_row.product.legacy_id == product_id}.first
        product_supplier.supplier if product_supplier.present?
      end
    end
end
