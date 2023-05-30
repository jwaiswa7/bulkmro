# frozen_string_literal: true

class RequestCustomerFeedbackJob < ActiveJob::Base
  queue_as :default

  def perform(company_id)
    Services::Customers::Feedback.new(company_id).call
  end
end
