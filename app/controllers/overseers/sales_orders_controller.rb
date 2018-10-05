class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.all.not_legacy.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)), params, do_not_search: true)
    authorize @sales_orders
  end

end
