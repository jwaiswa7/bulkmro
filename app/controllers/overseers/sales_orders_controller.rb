class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @pending_sales_orders = ApplyDatatableParams.to(policy_scope(SalesOrder.all).not_legacy.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)), params, do_not_search: true)
    authorize @pending_sales_orders
  end

  def index
    @sales_orders = ApplyDatatableParams.to(policy_scope(SalesOrder.all), params)
    authorize @sales_orders
  end
end
