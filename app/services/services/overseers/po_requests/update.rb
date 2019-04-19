class Services::Overseers::PoRequests::Update < Services::Shared::BaseService
  def initialize(po_request, current_overseer)
    @po_request = po_request
    @current_overseer = current_overseer
  end

  def call
    ActiveRecord::Base.transaction do
      if @po_request.status == 'Cancelled'
        @po_request_comment = PoRequestComment.new(message: @po_request&.purchase_order&.po_number.present? ? "Status Changed: #{@po_request.status} PO Request for Purchase Order number #{@po_request.purchase_order.po_number} \r\n Cancellation Reason: #{@po_request.cancellation_reason}" : "Status Changed: #{@po_request.status} \r\n Cancellation Reason: #{@po_request.cancellation_reason}", po_request: @po_request, overseer: current_overseer)
        @po_request.purchase_order = nil

        if @po_request.payment_request.present?
          @po_request.payment_request.update!(status: :'Cancelled')
          @po_request.payment_request.comments.create!(message: "Status Changed: #{@po_request.payment_request.status}; Po Request #{@po_request.id}: Cancelled", payment_request: @po_request.payment_request, overseer: current_overseer)
        end
      elsif @po_request.status == 'Supplier PO Request Rejected'
        @po_request_comment = PoRequestComment.new(message: "Status Changed: #{@po_request.status} \r\n Rejection Reason: #{@po_request.rejection_reason}", po_request: @po_request, overseer: current_overseer)
      else
        @po_request_comment = PoRequestComment.new(message: "Status Changed: #{@po_request.status}", po_request: @po_request, overseer: current_overseer)
        @po_request.rejection_reason = nil
        @po_request.other_rejection_reason = nil
      end
      if @po_request.stock_status_changed?
        if @po_request.stock_status == 'Stock Rejected'
          @po_request_comment = PoRequestComment.new(message: "Stock Status Changed: #{@po_request.stock_status} \r\n Rejection Reason: #{@po_request.rejection_reason}", po_request: @po_request, overseer: current_overseer)
        else
          @po_request_comment = PoRequestComment.new(message: "Stock Status Changed: #{@po_request.stock_status}", po_request: @po_request, overseer: current_overseer)
        end
      end
      @po_request.save!
      @po_request_comment.save!
    end
    @po_request_comment
  end

  attr_accessor :current_overseer
end
