class Overseers::Inquiries::SupplierRfqsController < Overseers::Inquiries::BaseController
  before_action :set_inquiry, only: [:index, :new, :create, :create_and_send_link, :send_email_request_for_quote]
  before_action :set_supplier_rfq, only: [:edit, :update, :show, :draft_rfq, :send_email_request_for_quote]

  def index
    inquiry_products = @inquiry.inquiry_products
  end

  def new
    @supplier_rfq = @inquiry.supplier_rfqs.build
    if params['supplier_ids'].present?
      @inquiry_product_suppliers = InquiryProductSupplier.where(id: params['supplier_ids'])
    else
      @inquiry_product_suppliers = @inquiry.inquiry_product_suppliers
    end
    authorize_acl @supplier_rfq
  end

  def create
    # inquiry_product_supplier_params = params['inquiry_product_supplier']
    inquiry_product_supplier = InquiryProductSupplier.find(params['inquiry_product_supplier']['id'])
    @inquiry_product = InquiryProduct.find(inquiry_product_supplier.inquiry_product.id) if inquiry_product_supplier.present?
    supplier_rfq_params = {inquiry_product_supplier_id: inquiry_product_supplier.id, inquiry_product_id: @inquiry_product.id, product_id: @inquiry_product.product.id, status: 'RFQ created: Not Sent' }
    @supplier_rfq = @inquiry.supplier_rfqs.build(supplier_rfq_params.merge(overseer: current_overseer))

    if @supplier_rfq.save
      inquiry_product_supplier.assign_attributes(inquiry_product_supplier_params.merge(overseer: current_overseer))
      inquiry_product_supplier.save
      @email_message = @supplier_rfq.email_messages.build(overseer: current_overseer, contact: inquiry_product_supplier.supplier.default_contact, inquiry: @inquiry, company: inquiry_product_supplier.supplier)
      subject = "Bulk MRO RFQ Ref # #{@inquiry_product.id}"
      @action = 'send_email_request_for_quote'
      @email_message.assign_attributes(
          subject: subject,
          body: SupplierRfqMailer.request_for_quote_email(@email_message, @inquiry_product, @quantity).body.raw_source
      )

      @params = {
          record: [:overseers, @supplier_rfq, @email_message],
          url: "supplier_rfqs/#{@supplier_rfq.to_param}/send_email_request_for_quote"
      }

      render 'shared/layouts/email_messages/new'
    end
  end

  # def create_and_send_link
  #   @supplier_rfq = SupplierRfq.new(supplier_rfq_params.merge(overseer: current_overseer))
  #   if params['inquiry_product_supplier'].present?
  #     inquiry_product_supplier = InquiryProductSupplier.find(params['inquiry_product_supplier']['id'])
  #     @quantity = params['inquiry_product_supplier']['inquiry_product']['quantity']
  #     @inquiry_product = inquiry_product_supplier.inquiry_product
  #     unit_cost_price = params['inquiry_product_supplier']['unit_cost_price']
  #     inquiry_product_supplier.update_attribute(:unit_cost_price, unit_cost_price)
  #     @email_message = @inquiry.email_messages.build(overseer: current_overseer, contact: inquiry_product_supplier.supplier.default_contact, inquiry: @inquiry, company: inquiry_product_supplier.supplier)
  #     subject = "Bulk MRO RFQ Ref # #{@inquiry_product.id}"
  #     @action = 'send_email_request_for_quote'
  #     @email_message.assign_attributes(
  #         subject: subject,
  #         body: InquiryMailer.request_for_quote_email(@email_message, @inquiry_product, @quantity).body.raw_source
  #     )
  #     @params = {
  #         record: [:overseers, @inquiry, @email_message],
  #         url: {action: @action, controller: 'overseers/inquiries'}
  #     }
  #
  #     render 'shared/layouts/email_messages/new'
  #   end
  # end

  def send_email_request_for_quote
    authorize_acl @supplier_rfq
    @email_message = @inquiry.email_messages.build(overseer: current_overseer, contact: @contact, inquiry: @inquiry, email_type: 'Request for Quote')
    @email_message.assign_attributes(email_message_params)

    @email_message.assign_attributes(cc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:cc].present?
    @email_message.assign_attributes(bcc: email_message_params[:cc].split(',').map {|email| email.strip}) if email_message_params[:bcc].present?

    if @email_message.save!
      SupplierRfqMailer.send_request_for_quote_email(@email_message).deliver_now
      redirect_to overseers_inquiry_sales_quotes_path(@inquiry)
    else
      render 'shared/layouts/email_messages/new'
    end
  end
  #
  # def show
  #
  # end
  #
  # def edit
  #
  # end
  #
  # def update
  #
  # end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params['inquiry_id'])
  end

  def set_supplier_rfq
    @supplier_rfq = SupplierRfq.find(params[:id])
  end

  def supplier_rfq_params
    params.require(:supplier_rfq).permit(:inquiry_id,
           :inquiry_product_supplier_id,
           :inquiry_product_id,
           :product_id,
           :status,
           :email_sent_at,
           :created_at,
           :updated_at,
           :created_by_id,
           :updated_by_id
    )
  end

  def inquiry_product_supplier_params
    params.require(:inquiry_product_supplier).permit(:inquiry_id,
           :inquiry_product_id,
           :legacy_id,
           :supplier_id,
           :unit_cost_price,
           :bp_catalog_name,
           :bp_catalog_sku,
           :lead_time,
           :last_unit_price,
           :gst, :unit_freight,
           :final_unit_price,
           :total_price,
           :remarks
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
