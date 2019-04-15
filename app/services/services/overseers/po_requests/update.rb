class Services::Overseers::PoRequests::Update < Services::Shared::BaseService
  def initialize(po_request, current_overseer, action_name)
    @po_request = po_request
    @current_overseer = current_overseer
    @action_name = action_name
  end

  def call
    ActiveRecord::Base.transaction do
      if @po_request.status_changed?
        if @po_request.status == 'Cancelled'
          @po_request_comment = PoRequestComment.new(message: "Status Changed: #{@po_request.status} PO Request for Purchase Order number #{@po_request.purchase_order.po_number} \r\n Cancellation Reason: #{@po_request.cancellation_reason}", po_request: @po_request, overseer: current_overseer)
          @po_request.purchase_order = nil

          if @po_request.payment_request.present?
            @po_request.payment_request.update_attributes(status: :'Cancelled')
            @po_request.payment_request.comments.create!(message: "Status Changed: #{@po_request.payment_request.status}; Po Request #{@po_request.id}: Cancelled", payment_request: @po_request.payment_request, overseer: current_overseer)
          end
        elsif @po_request.status == 'Supplier PO Request Rejected'
          @po_request_comment = PoRequestComment.new(message: "Status Changed: #{@po_request.status} \r\n Rejection Reason: #{@po_request.rejection_reason}", po_request: @po_request, overseer: current_overseer)
        else
          @po_request_comment = PoRequestComment.new(message: "Status Changed: #{@po_request.status}", po_request: @po_request, overseer: current_overseer)
        end
        @po_request_comment.save!
        @po_request.save!
      else
        @po_request.save!
      end
    end
  end

  attr_accessor :current_overseer, :action_name
end
