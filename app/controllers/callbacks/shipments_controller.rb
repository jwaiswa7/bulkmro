class Callbacks::ShipmentsController < Callbacks::BaseController
  def create
    service = Services::Overseers::Callbacks::NewShipments.new(params)
    service.call

    render_successful
  end

  def update
    service = Services::Overseers::Callbacks::UpdateShipmentStatus.new(params)
    service.call

    #request params:
    # In update increment_id and DocNum are same

    render_successful
  end
end