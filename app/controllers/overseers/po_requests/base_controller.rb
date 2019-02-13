

class Overseers::PoRequests::BaseController < Overseers::BaseController
  before_action :set_po_request

  private
    def set_po_request
      @po_request = PoRequest.find(params[:po_request_id])
    end
end
