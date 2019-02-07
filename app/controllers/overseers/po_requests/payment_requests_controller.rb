class Overseers::PoRequests::PaymentRequestsController < Overseers::PoRequests::BaseController
  before_action :set_payment_request, only: [:edit, :update]

  def new
    authorize @po_request, :new_payment_request?
    @payment_request = @po_request.build_payment_request(:overseer => current_overseer, :inquiry => @po_request.inquiry, :purchase_order => @po_request.purchase_order)
  end

  def create
    authorize @po_request, :new_payment_request?
    @payment_request = PaymentRequest.new(payment_request_params.merge(overseer: current_overseer))

    @payment_request.update_status!

    if @payment_request.valid?
      ActiveRecord::Base.transaction do
        @payment_request.save!
        @payment_request_comment = PaymentRequestComment.new(:message => "Payment Request submitted.", :payment_request => @payment_request, :overseer => current_overseer)
        @payment_request_comment.save!
      end

      redirect_to overseers_payment_request_path(@payment_request), notice: flash_message(@payment_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @po_request, :edit_payment_request?
  end

  def update
    @payment_request.assign_attributes(payment_request_params.merge(overseer: current_overseer))
    authorize @po_request, :edit_payment_request?

    if @payment_request.valid?
      ActiveRecord::Base.transaction do
        update_payment_request = Services::Overseers::PaymentRequests::Update.new(@payment_request, current_overseer)
        update_payment_request.call
      end

      redirect_to overseers_payment_request_path(@payment_request), notice: flash_message(@payment_request, action_name)
    else
      render 'edit'
    end
  end

  private

  def payment_request_params
    params.require(:payment_request).permit(
        :id,
        :inquiry_id,
        :utr_number,
        :po_request_id,
        :purchase_order_id,
        :po_date,
        :due_date,
        :payment_type,
        :cheque_date,
        :request_owner,
        :status,
        :payment_terms,
        :purpose_of_payment,
        :description,
        :supplier_bank_details,
        :company_bank_id,
        :comments_attributes => [:id, :message, :created_by_id],
        :transactions_attributes => [:id, :payment_type, :utr_or_cheque_no, :cheque_date, :amount_paid, :_destroy],
        :attachments => []
    )
  end

  def set_payment_request
    @payment_request = PaymentRequest.find(params[:id])
  end
end
