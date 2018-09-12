class Callbacks::SalesOrdersController < Callbacks::BaseController
  protect_from_forgery with: :null_session
  before_action :authenticate_callback
  def update
    # @sales_order = SalesOrder.find_by_remote_id(params[:increment_id])
    puts 'Something magical happens here!'

    render json: params, status: :ok
  end
  def create
    # @sales_order = SalesOrder.find_by_remote_id(params[:increment_id])
    puts 'Something magical happens here!'

    render json: params, status: :ok
  end
end