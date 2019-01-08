class Services::Overseers::PaymentRequests::Update < Services::Shared::BaseService

  def initialize(payment_request, current_overseer)
    @payment_request = payment_request
    @current_overseer = current_overseer
  end

  def call
    if payment_request.status_changed?
      payment_request_comment = PaymentRequestComment.new(:message => "Status Changed: #{payment_request.status}", :payment_request => payment_request, :overseer => current_overseer)
      payment_request.save!
      payment_request_comment.save!
    elsif payment_request.request_owner_changed?
      payment_request_comment = PaymentRequestComment.new(:message => "Ownership transferred to: #{payment_request.request_owner}", :payment_request => payment_request, :overseer => current_overseer)
      payment_request.save!
      payment_request_comment.save!
    else
      payment_request.save!
    end
  end

  private

  attr_accessor :payment_request, :current_overseer
end
