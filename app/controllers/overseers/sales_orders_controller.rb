class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.all.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)).group(:id), params)
    authorize @sales_orders
  end

  def show_pdf
    @sales_order = SalesOrder.find(params[:id])
    authorize @sales_order
    respond_to do |format|
      format.pdf do
        render pdf: 'show',
               template: 'overseers/sales_orders/show.pdf.erb',
               layout: 'overseers/layouts/pdf.html.erb',
               footer: {center: '[page] of [topage]'}
      end
    end
  end

end
