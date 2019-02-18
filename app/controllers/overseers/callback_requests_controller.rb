# frozen_string_literal: true

class Overseers::CallbackRequestsController < Overseers::BaseController
  before_action :set_callback_request, only: [:show]

  def index
    @callback_requests = ApplyDatatableParams.to(CallbackRequest.all, params)
    authorize @callback_requests
  end

  def show
    authorize @callback_request
    render :show
  end

  private

    def set_callback_request
      @callback_request = CallbackRequest.find(params[:id])
    end
end
