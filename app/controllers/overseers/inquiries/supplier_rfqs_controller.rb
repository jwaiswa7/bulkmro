class Overseers::Inquiries::SupplierRfqsController < Overseers::Inquiries::BaseController
  before_action :set_inquiry, only: [:index, :new, :create]
  before_action :set_supplier_rfq, only: [:edit, :update, :show, :draft_rfq]

  def index
    inquiry_products = @inquiry.inquiry_products
  end

  def new
    @supplier_rfq = SupplierRfq.new
    if params['supplier_ids'].present?
      @inquiry_product_suppliers = InquiryProductSupplier.where(id: params['supplier_ids'])
    else
      @inquiry_product_suppliers = @inquiry.inquiry_product_suppliers
    end
    authorize_acl @supplier_rfq
  end

  def create
    @supplier_rfq = SupplierRfq.new(supplier_rfq_params.merge(overseer: current_overseer))
    if params['inquiry_product_supplier'].present?
      inquiry_product_supplier = InquiryProductSupplier.find(params['inquiry_product_supplier']['id'])
      @quantity = params['inquiry_product_supplier']['inquiry_product']['quantity']
      @inquiry_product = inquiry_product_supplier.inquiry_product
      unit_cost_price = params['inquiry_product_supplier']['unit_cost_price']
      inquiry_product_supplier.update_attribute(:unit_cost_price, unit_cost_price)
      @email_message = @inquiry.email_messages.build(overseer: current_overseer, contact: inquiry_product_supplier.supplier.default_contact, inquiry: @inquiry, company: inquiry_product_supplier.supplier)
      subject = "Bulk MRO RFQ Ref # #{@inquiry_product.id}"
      @action = 'send_email_request_for_quote'
      @email_message.assign_attributes(
          subject: subject,
          body: InquiryMailer.request_for_quote_email(@email_message, @inquiry_product, @quantity).body.raw_source
      )
      @params = {
          record: [:overseers, @inquiry, @email_message],
          url: {action: @action, controller: 'overseers/inquiries'}
      }

      render 'shared/layouts/email_messages/new'
    end
  end

  def show

  end

  def edit

  end

  def update

  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params['inquiry_id'])
  end

  def set_supplier_rfq
    @supllier_rfq = SupllierRfq.find(params[:id])
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
end
