class Overseers::Inquiries::SupplierRfqsController < Overseers::Inquiries::BaseController
  before_action :set_inquiry
  before_action :set_supplier_rfq, only: [:edit, :update, :show, :draft_rfq, :send_email_request_for_quote]

  def index
    @inquiry_product_suppliers = @inquiry.inquiry_product_suppliers
    authorize_acl @inquiry_product_suppliers
    respond_to do |format|
      format.json { render 'index' }
      format.html { render 'index' }
    end
  end

  def add_supplier_rfqs
    if params['inquiry_product_ids'].present?
      params['inquiry_product_ids'].reject(&:empty?).each do |inquiry_product_id|
        inquiry_product = InquiryProduct.find(inquiry_product_id)
        params['inquiry_product_supplier_ids'].reject(&:empty?).each do |inquiry_product_supplier_id|
          inquiry_product_supplier = InquiryProductSupplier.find(inquiry_product_supplier_id)
          if inquiry_product_supplier.present?
            supplier_rfq = SupplierRfq.where(inquiry_id: @inquiry.id, supplier_id: inquiry_product_supplier.supplier.id).first_or_create
            inquiry_product_supplier.supplier_rfq = supplier_rfq
            inquiry_product_supplier.save
          end
        end if params['inquiry_product_supplier_ids'].present?
      end
      redirect_to edit_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id: @inquiry, isp_ids: params['inquiry_product_supplier_ids'])
    else
      redirect_to edit_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id: @inquiry)
    end
  end

  def edit_supplier_rfqs
    if params['isp_ids'].present?
      @inquiry_product_suppliers = InquiryProductSupplier.where(id: params['isp_ids'])
    else
      @inquiry_product_suppliers = @inquiry.inquiry_product_suppliers
    end
    @supplier_rfq_ids = @inquiry_product_suppliers.pluck(:supplier_rfq_id)
    @supplier_rfqs = SupplierRfq.where(id: @supplier_rfq_ids)
    authorize_acl :supplier_rfq
  end

  def update
    authorize_acl @supplier_rfq

    if @supplier_rfq.present?
      @supplier_rfq.assign_attributes(supplier_rfq_params.merge(overseer: current_overseer))
      @supplier_rfq.save
      supplier = Company.find(@supplier_rfq.supplier_id)
      # contact = supplier.default_contact
      contact = Contact.find_by_email('bulkmro007@gmail.com')
      if params['button'] == 'update_and_send_link'
        if contact.present?
          @email_message = @supplier_rfq.email_messages.build(overseer: current_overseer, contact: contact, inquiry: @inquiry, company: supplier)
          subject = "Bulk MRO RFQ Ref #Inq #{@supplier_rfq.inquiry.inquiry_number} #RFQ #{@supplier_rfq.id}"
          @action = 'send_email_request_for_quote'

          @email_message.assign_attributes(
              subject: subject,
              body: SupplierRfqMailer.request_for_quote_email(@email_message, @supplier_rfq).body.raw_source
          )
          @params = {
              record: [:overseers, @supplier_rfq, @email_message],
              url: "#{@supplier_rfq.to_param}/send_email_request_for_quote"
          }
          render 'shared/layouts/email_messages/new'
        end
      elsif params['button'] == 'update_and_send_link_all'

        @email_message = @supplier_rfq.email_messages.build(overseer: current_overseer, contact: contact, inquiry: @inquiry, company: supplier)
        subject = "Bulk MRO RFQ Ref #Inq #{@supplier_rfq.inquiry.inquiry_number} #RFQ #{@supplier_rfq.id}"

        @email_message.assign_attributes(
            subject: subject,
            body: SupplierRfqMailer.request_for_quote_email(@email_message, @supplier_rfq).body.raw_source
        )
        if @email_message.save
          if SupplierRfqMailer.send_request_for_quote_email(@email_message).deliver_now
            @supplier_rfq.update_attributes(email_sent_at: Time.now, status: 'Email Sent: Supplier Response Pending')
          end
        end
        flash[:notice] = 'Record updated successfully and Emails has been sent to suppliers!'
        redirect_to edit_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id: @inquiry)
      else
        flash[:notice] = 'Record updated successfully'
        redirect_to edit_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id: @inquiry)
      end
      #
    end
  end

  def send_email_request_for_quote
    authorize_acl @supplier_rfq
    @email_message = @inquiry.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry, email_type: 'Request for Quote', supplier_rfq: @supplier_rfq)
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map { |email| email.strip }) if email_message_params[:bcc].present?

    if @email_message.save
      SupplierRfqMailer.send_request_for_quote_email(@email_message).deliver_now
      @supplier_rfq.update_attributes(email_sent_at: Time.now, status: 'Email Sent: Supplier Response Pending')
      redirect_to edit_supplier_rfqs_overseers_inquiry_supplier_rfqs_path(inquiry_id: @inquiry)
      # redirect_to overseers_inquiry_sales_quotes_path(@inquiry)
    else
      render 'shared/layouts/email_messages/new'
    end
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params['inquiry_id'])
  end

  def set_supplier_rfq
    @supplier_rfq = SupplierRfq.find(params[:id])
  end

  def supplier_rfq_params
    params.require(:supplier_rfq).permit(:id,
                                         :inquiry_id,
                                         :inquiry_product_supplier_id,
                                         :inquiry_product_id,
                                         :product_id,
                                         :status,
                                         :email_sent_at,
                                         :created_by_id,
                                         :updated_by_id,
                                         inquiry_product_suppliers_attributes: [:id,
                                                                                :inquiry_id,
                                                                                :unit_cost_price,
                                                                                :lead_time,
                                                                                :last_unit_price,
                                                                                :gst,
                                                                                :quantity,
                                                                                :unit_freight,
                                                                                :final_unit_price,
                                                                                :total_price,
                                                                                :remarks, :_destroy]
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
