class Customers::SalesOrdersController < Customers::BaseController

  def index
    account = current_contact.account
    @sales_orders = ApplyDatatableParams.to(account.sales_orders, params)
  end

  def show
    @sales_order = SalesOrder.find(params[:id])
    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

end
