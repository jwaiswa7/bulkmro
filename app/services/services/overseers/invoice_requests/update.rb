class Services::Overseers::InvoiceRequests::Update < Services::Shared::BaseService
  def initialize(invoice_request, current_overseer)
    @invoice_request = invoice_request
    @current_overseer = current_overseer
  end

  def call
    @invoice_request.status = "Pending AP Invoice" if @invoice_request.grpo_number.present? && @invoice_request.grpo_number_valid?
    @invoice_request.update_status(@invoice_request.status)

    ActiveRecord::Base.transaction do
      if @invoice_request.status_changed?

        if @invoice_request.grpo_number_changed?
          @invoice_request_comment = InvoiceRequestComment.new(message: "GRPO Number Changed: #{@invoice_request.grpo_number}; Status changed: #{@invoice_request.status}", invoice_request: @invoice_request, overseer: current_overseer)
        else
          @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{@invoice_request.status}", invoice_request: @invoice_request, overseer: current_overseer)
        end

        if ['GRPO Request Rejected', 'AP Invoice Request Rejected'].include?(@invoice_request.status)
          @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{@invoice_request.status}.<br/> Rejection Reason: #{@invoice_request.rejection_reason} ", invoice_request: @invoice_request, overseer: current_overseer)
          material_pickup_requests = @invoice_request.material_pickup_requests
          @invoice_request.cancellation_reason = nil # ( Can canceled Invoice again open? )
          material_pickup_requests.each do |material_pickup_request|
            material_pickup_request.update_attributes(:status => @invoice_request.status)
          end
        elsif ['Cancelled','Cancelled AR Invoice'].include?(@invoice_request.status)
          @invoice_request.rejection_reason = nil
          @invoice_request.other_rejection_reason = nil
        else
          @invoice_request_comment = InvoiceRequestComment.new(message: "Status Changed: #{@invoice_request.status}.<br/> Cancellation Reason: #{@invoice_request.cancellation_reason} ", invoice_request: @invoice_request, overseer: current_overseer)
          @invoice_request.rejection_reason = nil
          @invoice_request.other_rejection_reason = nil
          @invoice_request.cancellation_reason = nil # ( Can canceled Invoice again open? )
        end

        @invoice_request.save!
        @invoice_request_comment.save!
      elsif @invoice_request.rejection_reason_changed? && @invoice_request.rejection_reason != 'Others'
        @invoice_request.other_rejection_reason = nil
        @invoice_request.save!
      elsif @invoice_request.grpo_number_changed?
        @invoice_request_comment = InvoiceRequestComment.new(message: "GRPO Number Changed: #{@invoice_request.grpo_number}", invoice_request: @invoice_request, overseer: current_overseer)
        @invoice_request_comment.save!
      else
        @invoice_request.save!
      end
    end
  end

  private
    attr_accessor :invoice_request, :current_overseer
end
