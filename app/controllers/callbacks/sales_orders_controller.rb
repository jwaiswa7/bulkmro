class Callbacks::SalesOrdersController < Callbacks::BaseController
  def create
    service = Services::Overseers::Callbacks::SalesOrders::Create.new(params)
    service.call

    render_successful
  end

  def update
    service = Services::Overseers::Callbacks::SalesOrders::Update.new(params)
    service.call

    render_successful
  end
end