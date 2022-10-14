class Customers::RfqsController < Customers::BaseController
  before_action :set_customer_rfq, only: :show
	def index
    authorize :rfq
		
    service = Services::Customers::Finders::CustomerRfqs.new(params, current_customers_contact, current_company)
    service.call
    @indexed_rfqs = service.indexed_records
    @rfqs = service.records
  end

  def new 
    authorize :rfq
    @customer_rfq = current_customers_contact.account.customer_rfqs.new
  end

  def create 
    authorize :rfq
    @inquiry = Inquiry.new(company_id: current_customers_contact.company.id, potential_amount: 1.0, subject: customer_rfq_params[:subject], opportunity_source: 'Online_order' , quote_category: 'bmro', is_sez: true, product_type: 'MRO',price_type: 'Door delivery' , contact_id:  current_customers_contact.id , shipping_contact_id: current_customers_contact.id)
    if @inquiry.save
      @customer_rfq = CustomerRfq.new(customer_rfq_params.merge(inquiry_id: @inquiry.id)) 
      if @customer_rfq.save 
        @email_message = @customer_rfq.email_messages.build(contact: current_customers_contact, inquiry: @customer_rfq.inquiry, company: current_customers_contact.company)
        subject = "You have received a new Inquiry #{@inquiry.subject}"
        @email_message.assign_attributes(
          subject: subject,
          body: CustomerRfqMailer.rfq_submitted_email(@email_message, @customer_rfq).body.raw_source,
          from: "noreply@bulmro.com",
          to: [@customer_rfq.inquiry.inside_sales_owner.email, @customer_rfq.inquiry.outside_sales_owner.email, @customer_rfq.inquiry.sales_manager.email]
        )
        # @email_message.files.attach(io: File.open(RenderPdfToFile.for(@customer_rfq, locals: { is_revision_visible: true })), filename: @customer_rfq.filename(include_extension: true))
        if @email_message.save
          CustomerRfqMailer.send_rfq_submitted_email(@email_message).deliver_now
        end
        redirect_to customers_rfq_path(@customer_rfq) , notice: "Your Inquiry # #{ @customer_rfq.inquiry.inquiry_number } has been submitted. You will receive a quotation shortly"
      else 
        render :new
      end
    else 
      render :new
    end
  end

  def show 
    authorize :rfq
  end

  private 

  def set_customer_rfq 
    @customer_rfq = CustomerRfq.find(params[:id])
  end

  def customer_rfq_params 
    params.require(:customer_rfq).permit(:account_id, :subject, :requirement_details, :file)
  end

end
