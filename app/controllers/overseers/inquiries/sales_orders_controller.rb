class Overseers::Inquiries::SalesOrdersController < Overseers::Inquiries::BaseController
  def index
    authorize :sales_quote
  end

  private
end