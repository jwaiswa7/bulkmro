class Overseers::CustomerFeedbacksController < Overseers::BaseController
    def index 
        @customer_feedbacks = ApplyDatatableParams.to(CustomerFeedback.all.order(id: :desc),params)
    end

    def request_feedback
        RequestCustomerFeedbackJob.perform_later(params[:company_id])
        render json: {success: true, message: "Feedback request sent successfully"}
    end
end