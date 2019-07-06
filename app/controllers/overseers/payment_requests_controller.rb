class Overseers::PaymentRequestsController < Overseers::BaseController
  before_action :set_payment_request, only: [:show, :render_modal_form, :add_comment]

  def index
    service = Services::Overseers::Finders::PaymentRequests.new(params, current_overseer)
    service.call

    @indexed_payment_requests = service.indexed_records
    @payment_requests = service.records


    authorize_acl :payment_request
    status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_payment_requests, PaymentRequest)
    status_service.call

    @total_values = status_service.indexed_total_values
    @statuses = status_service.indexed_statuses
  end

  def update_payment_status
    @payment_requests = PaymentRequest.where(id: params[:payment_requests])
    authorize_acl @payment_requests
    @payment_requests.update_all(status: params[:status_id].to_i)
    @payment_requests.each do |payment_request|
      payment_comment = PaymentRequestComment.new(message: "Status Changed:#{PaymentRequest.statuses.invert[params[:status_id].to_i]}", payment_request: payment_request, overseer: current_overseer)
      payment_comment.save
    end
  end

  def show
    authorize_acl @payment_request
  end

  def render_modal_form
    authorize @payment_request
    respond_to do |format|
      if params[:title] == 'Comment'
        format.html {render partial: 'shared/layouts/add_comment', locals: {obj: @payment_request, url: add_comment_overseers_payment_request_path(@payment_request), view_more: overseers_payment_request_path(@payment_request)}}
      end
    end
  end

  def add_comment
    @payment_request.assign_attributes(payment_request_params.merge(overseer: current_overseer))
    authorize @payment_request
    @payment_request.skip_validation = true
    @payment_request.skip_due_date_validation = true
    if @payment_request.valid?
      if params['payment_request']['comments_attributes']['0']['message'].present?
        ActiveRecord::Base.transaction do
          @payment_request.save!
          @payment_request_comment = PaymentRequestComment.new(message: '', payment_request: @payment_request, overseer: current_overseer)
        end
        render json: {success: 1, message: 'Successfully updated '}, status: 200
      else
        render json: {error: {base: 'Field cannot be blank!'}}, status: 500
      end
    else
      render json: {error: @payment_request.errors}, status: 500
    end
  end

  private

    def payment_request_params
      params.require(:payment_request).permit(
          :id,
          comments_attributes: [:id, :message, :created_by_id, :updated_by_id],
      )
    end

    def set_payment_request
      @payment_request = PaymentRequest.find(params[:id])
    end
end
