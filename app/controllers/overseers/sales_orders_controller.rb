class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.all.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)).group(:id), params)
    authorize @sales_orders
  end

  def show_pdf

    @sales_order = SalesOrder.find(391)
    authorize @sales_order

    render pdf: 'show', template: 'overseers/sales_orders/show.pdf.erb'
    # respond_to do |format|
    #   format.html
    #   format.pdf do
    #      render pdf: 'show.pdf', template: 'overseers/sales_orders/show.html.erb'
    #   end
    # end
    # raise
    # render pdf: 'show.pdf', template: 'overseers/sales_orders/show'

    # respond_to do |format|
    #   format.pdf { render pdf: 'show.pdf' }
    # end
  end

end
