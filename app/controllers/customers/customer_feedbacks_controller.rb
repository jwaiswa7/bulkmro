# frozen_string_literal: true

class Customers::CustomerFeedbacksController < ApplicationController

    layout 'customers/layouts/feedback'

    def new 
        @email = params[:email]
        @customer_feedback = CustomerFeedback.new
    end

    def thank_you 

    end

    def create
      @customer_feedback = CustomerFeedback.new(customer_feedback_params) 
      if @customer_feedback.save 
        redirect_to thank_you_customers_customer_feedbacks_path
      else
        render :new
      end
    end

    private 

    def customer_feedback_params 
        params.require(:customer_feedback).permit(:customer_email, :experience, :most_liked, :to_improve, :comments)
    end
end