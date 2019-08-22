class Overseers::OutwardDispatches::BaseController < Overseers::BaseController
  before_action :set_outward_dispatch

  private
    def set_outward_dispatch
      @outward_dispatch = OutwardDispatch.find(params[:outward_dispatch_id])
    end
end
