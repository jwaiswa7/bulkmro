class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show, :edit, :update]

  def index
    payment_requests  =
        if params[:status].present?
          @title = params[:status]
          PaymentRequest.where(:status => params[:status])
        else
          PaymentRequest.all
        end.order(id: :desc)

    @payment_requests = ApplyDatatableParams.to(payment_requests, params)
    authorize @payment_requests
  end

  def show
    authorize @payment_request
  end

  def new
    if params[:po_request_id].present?
      @po_request = PoRequest.find(params[:po_request_id])
      @payment_request = PaymentRequest.new(:overseer => current_overseer, :po_request => @po_request, :inquiry => @po_request.inquiry, :purchase_order => @po_request.purchase_order)
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
    @payment_request.auto_update_status

    if @payment_request.valid?
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
        :payment_type,
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
