class Customers::RevisionRequestsController < Customers::BaseController
    before_action :set_sales_quote
   
    def new 
      @revision_request = RevisionRequest.new
      authorize @revision_request
    end

    def create
      @revision_request = RevisionRequest.new(revision_request_params.merge(sales_quote: @sales_quote, contact: current_customers_contact))
      authorize @revision_request
      
      if @revision_request.save 
        redirect_to customers_quote_path(@sales_quote), notice: "Request submitted"
      else
        render :new
      end
    end

    private 

    def revision_request_params 
        params.require(:revision_request).permit(:reason, :required_changes, files: [])
    end

    def set_sales_quote
        @sales_quote = SalesQuote.find(params[:id])
    end
end