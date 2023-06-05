class Overseers::CustomerFeedbacksController < Overseers::BaseController
    def index 
        @customer_feedbacks = ApplyDatatableParams.to(CustomerFeedback.all.order(id: :desc),params)
    end

    def request_feedback
        RequestCustomerFeedbackJob.perform_later(params[:company_id])
        respond_to do |format|
            format.js
        end
    end
end