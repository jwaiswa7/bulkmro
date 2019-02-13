class Overseers::FreightRequestsController < Overseers::BaseController
  before_action :set_freight_request, only: [:show, :edit, :update]

  def index
    freight_requests =
        if params[:status].present?
          @status = params[:status]
          FreightRequest.where(status: FreightRequest.statuses[params[:status]])
        else
          FreightRequest.all
        end

    @freight_requests = ApplyDatatableParams.to(freight_requests, params)
    authorize @freight_requests
  end

  def show
    authorize @freight_request
  end

  def new
    if params[:sales_order_id].present? || params[:sales_quote_id].present? || params[:inquiry_id].present?

      if params[:sales_order_id].present?
        @sales_order = SalesOrder.find(params[:sales_order_id])
        @sales_quote = @sales_order.sales_quote
        @inquiry = @sales_quote.inquiry
      elsif params[:sales_quote_id].present?
        @sales_quote = SalesQuote.find(params[:sales_quote_id])
        @inquiry = @sales_quote.inquiry
      elsif params[:inquiry_id].present?
        @inquiry = Inquiry.find(params[:inquiry_id])
        @sales_quote = @inquiry.final_sales_quote
      end

      freight_params = { overseer: current_overseer, inquiry: @inquiry, sales_quote: @sales_quote, company: @inquiry.shipping_company }
      freight_params[:sales_order] = @sales_order if @sales_order.present?

      @freight_request = FreightRequest.new(freight_params)
      authorize @freight_request
    else
      redirect_to overseers_freight_requests_path
    end
  end

  def create
    @freight_request = FreightRequest.new(freight_request_params.merge(overseer: current_overseer))
    authorize @freight_request
    if @freight_request.valid?
      ActiveRecord::Base.transaction do
        @freight_request.save!
        @freight_request_comment = FreightRequestComment.new(message: 'Freight Request submitted.', freight_request: @freight_request, overseer: current_overseer)
        @freight_request_comment.save!
      end

      redirect_to overseers_freight_request_path(@freight_request), notice: flash_message(@freight_request, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @freight_request
  end

  def update
    @freight_request.assign_attributes(freight_request_params.merge(overseer: current_overseer))
    authorize @freight_request
    if @freight_request.valid?
      ActiveRecord::Base.transaction do
        if @freight_request.status_changed?
          @freight_request_comment = FreightRequestComment.new(message: "Status Changed: #{@freight_request.status}", freight_request: @freight_request, overseer: current_overseer)
          @freight_request.save!
          @freight_request_comment.save!
        else
          @freight_request.save!
        end
      end
      redirect_to overseers_freight_request_path(@freight_request), notice: flash_message(@freight_request, action_name)
    else
      render 'edit'
    end
  end

  private

    def freight_request_params
      params.require(:freight_request).permit(
        :id,
          :request_type,
          :delivery_type,
          :inquiry_id,
          :sales_order_id,
          :company_id,
          :delivery_address_id,
          :supplier_id,
          :pick_up_address_id,
          :sales_quote_id,
          :status,
          :weight,
          :length,
          :width,
          :breadth,
          :volumetric_weight,
          :hazardous,
          :pickup_date,
          :material_type,
          :loading,
          :unloading,
          comments_attributes: [:id, :message, :created_by_id],
          attachments: []
      )
    end

    def set_freight_request
      @freight_request = FreightRequest.find(params[:id])
    end
end
