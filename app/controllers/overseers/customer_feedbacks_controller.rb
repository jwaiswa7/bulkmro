class Overseers::CustomerFeedbacksController < Overseers::BaseController
    def index 
        @customer_feedbacks = ApplyDatatableParams.to(CustomerFeedback.all.order(id: :desc),params)
        authorize_acl @customer_feedbacks
    end
end