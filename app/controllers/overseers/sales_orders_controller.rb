class Overseers::SalesOrdersController < Overseers::BaseController

  def pending
    @sales_orders = ApplyDatatableParams.to(SalesOrder.all.not_rejected.left_joins(:approval).merge(SalesOrderApproval.where(sales_order_id: nil)).group(:id), params)
    authorize @sales_orders
  end

  def show_pdf

    @sales_order = SalesOrder.find(params[:id])
    authorize @sales_order
    #render pdf: 'show', template: 'overseers/sales_orders/show.pdf.erb'
    #  <%= link_to "Test PDF", booking_path(current_user.bookings.last, format: :pdf) %>
    respond_to do |format|
      format.pdf { render pdf: 'show', template: 'overseers/sales_orders/show.pdf.erb' }
    end
  end

end
