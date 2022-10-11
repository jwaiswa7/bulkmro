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
    @customer_rfq = CustomerRfq.new(customer_rfq_params.merge(inquiry_id: Inquiry.first.id)) # [To do] Set the right inquiry id
    
    if @customer_rfq.save 
      redirect_to customers_rfq_path(@customer_rfq)
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
