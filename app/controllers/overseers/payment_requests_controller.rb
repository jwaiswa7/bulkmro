class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show, :edit, :update]

  def requests_created
    @payment_requests = ApplyDatatableParams.to(PaymentRequest.all.created.order(id: :desc), params)
    authorize @payment_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def completed
    @payment_requests = ApplyDatatableParams.to(PaymentRequest.all.completed.order(id: :desc), params)
    authorize @payment_requests

    respond_to do |format|
      format.json {render 'index'}
      format.html {render 'index'}
    end
  end

  def index
    @payment_requests = ApplyDatatableParams.to(PaymentRequest.all.order(id: :desc), params)
    authorize @payment_requests
  end

  def show
    authorize @payment_request
  end

  def new
    if params[:po_request_id].present?
      @po_request = PoRequest.find(params[:po_request_id])
      @payment_request = PaymentRequest.new(:overseer => current_overseer, :po_request => @po_request, :inquiry => @po_request.inquiry)
      authorize @payment_request
    else
      redirect_to overseers_payment_requests_path
    end
  end

  def create
    @payment_request = PaymentRequest.new(payment_request_params.merge(overseer: current_overseer))
    authorize @payment_request

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
    authorize @payment_request
  end

  def update
    @payment_request.assign_attributes(payment_request_params.merge(overseer: current_overseer))
    authorize @payment_request

    if @payment_request.valid?
      @payment_request.auto_update_status
      ActiveRecord::Base.transaction do
        if @payment_request.status_changed?
          @payment_request_comment = PaymentRequestComment.new(:message => "Status Changed: #{@payment_request.status}", :payment_request => @payment_request, :overseer => current_overseer)
          @payment_request.save!
          @payment_request_comment.save!
        else
          @payment_request.save!
        end
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
        :due_date,
        :status,
        :payment_terms,
        :comments_attributes => [:id, :message, :created_by_id],
        :attachments => []
    )
  end

  def set_payment_request
    @payment_request = PaymentRequest.find(params[:id])
  end
end
