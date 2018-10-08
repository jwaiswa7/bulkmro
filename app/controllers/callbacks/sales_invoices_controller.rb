class Callbacks::SalesInvoicesController < Callbacks::BaseController
  def create
    service = Services::Overseers::Callbacks::SalesInvoices::Create.new(params)
    service.call

    render_successful
  end

  def update
    service = Services::Overseers::Callbacks::SalesInvoices::Update.new(params)
    service.call

    render_successful
  end
end