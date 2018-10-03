class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.all.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)).group(:id), params)
    authorize @sales_orders
  end

end
