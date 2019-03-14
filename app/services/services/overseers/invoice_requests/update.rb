class Services::Overseers::InvoiceRequests::Update < Services::Shared::BaseService
  def initialize(invoice_request, current_overseer)
    @invoice_request = invoice_request
    @current_overseer = current_overseer
  end

  def call
    @invoice_request.status = 'Pending AP Invoice' if @invoice_request.grpo_number.present? && @invoice_request.grpo_number_valid?
    @invoice_request.update_status(@invoice_request.status)

    ActiveRecord::Base.transaction do
      if @invoice_request.status_changed?

        if @invoice_request.grpo_number_changed?
          @invoice_request_comment = InvoiceRequestComment.new(message: "GRPO Number Changed: #{@invoice_request.grpo_number}; Status changed: #{@invoice_request.status}", invoice_request: @invoice_request, overseer: current_overseer)
        end

        status_changed(@invoice_request)

        @invoice_request.save!
        @invoice_request_comment.save!
      elsif @invoice_request.grpo_rejection_reason_changed? && @invoice_request.grpo_rejection_reason != 'Others'
        @invoice_request.grpo_other_rejection_reason = nil
        @invoice_request.save!
      elsif @invoice_request.grpo_number_changed?
        @invoice_request_comment = InvoiceRequestComment.new(message: "GRPO Number Changed: #{@invoice_request.grpo_number}", invoice_request: @invoice_request, overseer: current_overseer)
        @invoice_request_comment.save!
      else
        @invoice_request.save!
      end
    end
  end

  def status_changed(invoice_request)
    case invoice_request.status.to_sym
    when :'GRPO Request Rejected'
      @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{invoice_request.status}.<br/> GRPO Request Rejection Reason: #{invoice_request.grpo_rejection_reason} ", invoice_request: invoice_request, overseer: current_overseer)
      material_pickup_requests = invoice_request.material_pickup_requests
      material_pickup_requests.each do |material_pickup_request|
        material_pickup_request.update_attributes(status: invoice_request.status)
      end
    when :'AP Request Rejected'
      @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{invoice_request.status}.<br/> AP Request Rejection Reason: #{invoice_request.ap_rejection_reason} ", invoice_request: invoice_request, overseer: current_overseer)
      material_pickup_requests = invoice_request.material_pickup_requests
      material_pickup_requests.each do |material_pickup_request|
        material_pickup_request.update_attributes(status: invoice_request.status)
      end
    when :'Cancelled GRPO'
      @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{invoice_request.status}.<br/> GRPO Request Cancellation Reason: #{invoice_request.grpo_cancellation_reason} ", invoice_request: invoice_request, overseer: current_overseer)
    when :'Cancelled AP Invoice'
      @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{invoice_request.status}.<br/> AP Request Cancellation Reason: #{invoice_request.ap_cancellation_reason} ", invoice_request: invoice_request, overseer: current_overseer)
    else
      @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{invoice_request.status}", invoice_request: invoice_request, overseer: current_overseer)
    end
  end

  private
    attr_accessor :invoice_request, :current_overseer
end
