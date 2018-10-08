class Callbacks::SalesShipmentsController < Callbacks::BaseController
  def create
    service = Services::Overseers::Callbacks::Shipments::New.new(params)
    service.call

    render_successful
  end

  def update
    service = Services::Overseers::Callbacks::Shipments::UpdateStatus.new(params)
    service.call

    render_successful
  end
end