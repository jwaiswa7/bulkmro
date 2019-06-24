class Services::Overseers::ArInvoiceRequests::Update < Services::Shared::BaseService
  def initialize(ar_invoice, current_overseer)
    @ar_invoice = ar_invoice
    @current_overseer = current_overseer
  end

  def call
    if @ar_invoice.status_changed?
      status_changed(@ar_invoice)
      @ar_invoice.save
      @ar_invoice_comment.save
    elsif @ar_invoice.rejection_reason_changed? && @ar_invoice.rejection_reason != 'Rejected: Others'
      @ar_invoice.other_rejection_reason = nil
      @ar_invoice.save
    elsif @ar_invoice.cancellation_reason_changed? && @ar_invoice.cancellation_reason != 'Others'
      @ar_invoice.other_cancellation_reason = nil
      @ar_invoice.save
    elsif @ar_invoice.sales_invoice_id_changed?
      @ar_invoice_comment = ArInvoiceRequestComment.new(message: "AR invoice Number Changed: #{@ar_invoice.ar_invoice_number}", ar_invoice_request: @ar_invoice, overseer: current_overseer)
      @ar_invoice_comment.save
    else
      @ar_invoice.save
    end

    messages = FieldModifiedMessage.for(@ar_invoice, message_fields(@ar_invoice))
    if messages.present?
      @ar_invoice.comments.create(message: messages, overseer: current_overseer)
    end
  end

  def status_changed(ar_invoice)
    case ar_invoice.status.to_sym
    when :'AR Invoice Request Rejected'
      @ar_invoice_comment = ArInvoiceRequestComment.new(message: "Status Changed: #{ar_invoice.status}.<br/> AR Invoice Request Rejection Reason: #{ar_invoice.reason_text('rejection')} ", ar_invoice_request: ar_invoice, overseer: current_overseer)
    when :'Cancelled AR Invoice'
      @ar_invoice_comment = ArInvoiceRequestComment.new(message: "Status Changed: #{ar_invoice.status}.<br/> AR Invoice Request Cancellation Reason: #{ar_invoice.reason_text('cancellation')} ", ar_invoice_request: ar_invoice, overseer: current_overseer)
    else
      @ar_invoice_comment = ArInvoiceRequestComment.new(message: "Status Changed: #{ar_invoice.status}", ar_invoice_request: ar_invoice, overseer: current_overseer)
    end
  end

  private
    attr_accessor :ar_invoice, :current_overseer

    def message_fields(object)
      object.attributes.keys - %w(id sales_order_id inquiry_id created_by_id updated_by_id created_at updated_at rejection_reason other_rejection_reason cancellation_reason other_cancellation_reason status)
    end
end
