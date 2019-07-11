class Overseers::SalesInvoicesController < Overseers::BaseController
  before_action :set_invoice, only: [:edit_pod, :update_pod, :delivery_mail_to_customer, :delivery_mail_to_customer_notification, :dispatch_mail_to_customer, :dispatch_mail_to_customer_notification]

  def index
    authorize_acl :sales_invoice

    respond_to do |format|
      format.html {
        service = Services::Overseers::SalesInvoices::ProofOfDeliverySummary.new(params, current_overseer)
        service.call

        @invoice_over_month = service.invoice_over_month
        @regular_pod_over_month = service.regular_pod_over_month
        @route_through_pod_over_month = service.route_through_pod_over_month
        @pod_over_month = @regular_pod_over_month.merge(@route_through_pod_over_month) { |key, regular_value, route_through_value| regular_value['doc_count'] + route_through_value['doc_count']}
      }
      format.json do
        service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer)
        service.call
        @indexed_sales_invoices = service.indexed_records
        @sales_invoices = service.records
        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_invoices, SalesInvoice)
        status_service.call
        @total_values = status_service.indexed_total_values
        @statuses = status_service.indexed_statuses
      end
    end
  end

  def edit_pod
    authorize_acl @invoice
    if !@invoice.pod_rows.present?
      @invoice.pod_rows.build
    end
  end

  def update_pod
    authorize_acl @invoice
    @invoice.assign_attributes(invoice_params)
    if @invoice.save
      redirect_to edit_pod_overseers_sales_invoice_path, notice: flash_message(@invoice, action_name)
    end
  end

  def autocomplete
    @sales_invoices = ApplyParams.to(SalesInvoice.all, params)
    authorize_acl @sales_invoices
  end

  def export_all
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesExporter.new([], current_overseer, [])
    service.call

    redirect_to url_for(Export.sales_invoices.not_filtered.last.report)
  end

  def export_filtered_records
    authorize_acl :sales_invoice
    service = Services::Overseers::Finders::SalesInvoices.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::SalesInvoicesExporter.new([], current_overseer, service.records)
    export_service.call
  end

  def export_rows
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoiceRowsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_rows.last.report)
  end

  def export_for_logistics
    authorize_acl :sales_invoice
    service = Services::Overseers::Exporters::SalesInvoicesLogisticsExporter.new
    service.call

    redirect_to url_for(Export.sales_invoice_logistics.last.report)
  end


  def delivery_mail_to_customer
    @email_message = @invoice.email_messages.build(overseer: current_overseer, contact: @invoice.inquiry.contact, inquiry: @invoice.inquiry, sales_invoice: @invoice)
    subject = "Ref# #{@invoice.inquiry.inquiry_number}- Your Order #{@invoice.inquiry.customer_po_number} - Delivery Notification"
    @action = 'delivery_mail_to_customer_notification'
    @email_message.assign_attributes(
      subject: subject,
      body: SalesInvoiceMailer.delivery_mail(@email_message).body.raw_source,
      auto_attach: true,
      cc: 'logistics@bulkmro.com, sales@bulkmro.com'
        )
    @params = {
        record: [:overseers, @invoice, @email_message],
        url: {action: @action, controller: 'overseers/sales_invoices'},
        attachment: {'Original Invoice' => overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank), 'Duplicate Invoice' => duplicate_overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank), 'Triplicate Invoice' => triplicate_overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank)}
    }


    authorize_acl @invoice
    render 'shared/layouts/email_messages/new'
  end

  def delivery_mail_to_customer_notification
    @email_message = @invoice.email_messages.build(overseer: current_overseer, contact: @invoice.inquiry.contact, inquiry: @invoice.inquiry, sales_invoice: @invoice, email_type: 'Material Delivered to Customer')
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize_acl @invoice

    if params['email_message']['auto_attach']
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Original_' + @invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Duplicate_' + @invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Triplicate_' + @invoice.filename(include_extension: true))
    end


    if @email_message.save!
      SalesInvoiceMailer.send_delivery_mail(@email_message).deliver_now
      redirect_to overseers_sales_invoices_path, notice: flash_message(@invoice, action_name)
    else
      render 'shared/layouts/email_messages/new'
    end
  end



  def dispatch_mail_to_customer
    @email_message = @invoice.email_messages.build(overseer: current_overseer, contact: @invoice.inquiry.contact, inquiry: @invoice.inquiry, sales_invoice: @invoice)
    subject = "Ref# #{@invoice.inquiry.inquiry_number}- Your Order #{@invoice.inquiry.customer_po_number} - Dispatch Notification"
    @action = 'dispatch_mail_to_customer_notification'
    @email_message.assign_attributes(
      subject: subject,
      body: SalesInvoiceMailer.dispatch_mail(@email_message).body.raw_source,
      auto_attach: true,
      cc: 'logistics@bulkmro.com, sales@bulkmro.com'
    )
    @params = {
        record: [:overseers, @invoice, @email_message],
        url: {action: @action, controller: 'overseers/sales_invoices'},
        attachment: {'Original Invoice' => overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank), 'Duplicate Invoice' => duplicate_overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank), 'Triplicate Invoice' => triplicate_overseers_inquiry_sales_invoice_path(@invoice.inquiry, @invoice, format: :pdf, target: :_blank)}
    }


    authorize_acl @invoice
    render 'shared/layouts/email_messages/new'
  end

  def dispatch_mail_to_customer_notification
    @email_message = @invoice.email_messages.build(overseer: current_overseer, contact: @invoice.inquiry.contact, inquiry: @invoice.inquiry, sales_invoice: @invoice, email_type: 'Material Dispatched to Customer')
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    authorize_acl @invoice

    if params['email_message']['auto_attach']
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Original_' + @invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Duplicate_' + @invoice.filename(include_extension: true))
      @email_message.files.attach(io: File.open(RenderPdfToFile.for(@invoice, stamp: true)), filename: 'Triplicate_' + @invoice.filename(include_extension: true))
    end


    if @email_message.save!
      SalesInvoiceMailer.send_delivery_mail(@email_message).deliver_now
      redirect_to overseers_sales_invoices_path, notice: flash_message(@invoice, action_name)
    else
      render 'shared/layouts/email_messages/new'
    end
  end

  def autocomplete
    sales_invoices = SalesInvoice.all
    if params[:inquiry_id].present?
      sales_invoices = SalesInvoice.joins(:inquiry).where(inquiries: {id: params[:inquiry_id]})
    end
    @sales_invoices = ApplyParams.to(sales_invoices, params)

    authorize :sales_invoice
  end



  private

    def set_invoice
      @invoice ||= SalesInvoice.find(params[:id])
    end

    def invoice_params
      params.require(:sales_invoice).permit(

        :delivery_date,
        :delivery_completed,
        pod_rows_attributes: [
            :id,
            :delivery_date,
            :sales_invoice_id,
            :_destroy,
            attachments: []
        ]
      )
    end

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
