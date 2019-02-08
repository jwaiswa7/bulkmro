# frozen_string_literal: true

class Overseers::FreightRequests::BaseController < Overseers::BaseController
  before_action :set_freight_request

  private
    def set_freight_request
      @freight_request = FreightRequest.find(params[:freight_request_id])
    end
end
