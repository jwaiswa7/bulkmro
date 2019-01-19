class Services::Overseers::PaymentRequests::Create < Services::Shared::BaseService

  def initialize(po_request)
    @po_request = po_request
  end

  def call
    if po_request.purchase_order.present? && po_request.status != 'Cancelled'
      PaymentRequest.where(:po_request => po_request, :purchase_order => po_request.purchase_order, :inquiry => po_request.inquiry).first_or_create! do |payment_request|
        payment_request.update_attributes(:overseer => po_request.inquiry.inside_sales_owner, :status => 11, :request_owner => 'Logistics')
        @payment_request_comment = PaymentRequestComment.new(:message => "Payment Request submitted.", :payment_request => payment_request, :overseer => po_request.inquiry.inside_sales_owner)
        @payment_request_comment.save!
      end
    end
  end

  private

  attr_accessor :po_request
end
