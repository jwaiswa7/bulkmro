class Callbacks::SalesOrdersController < Callbacks::BaseController
  def update
    @sales_order = SalesOrder.find_by_remote_id(params[:increment_id])
    puts 'Something magical happens here!'

    render json: {}, status: :ok
  end
end