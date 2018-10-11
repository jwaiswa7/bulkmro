class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @pending_sales_orders = ApplyDatatableParams.to(get_sales_orders_by_owners.not_legacy.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)), params, do_not_search: true)
    authorize @pending_sales_orders
  end

  def index
    @sales_orders = ApplyDatatableParams.to(get_sales_orders_by_owners, params)
    authorize @sales_orders
  end

  private

  def get_sales_orders_by_owners
    owners = current_overseer.self_and_descendant_ids
    SalesOrder.all.where("sales_orders.created_by_id in (?)", owners)
  end

end
