class Callbacks::ProductsController < Callbacks::BaseController
  def update
    service = Services::Overseers::Callbacks::Products::Update.new(params)
    service.call

    render_successful
  end
end
