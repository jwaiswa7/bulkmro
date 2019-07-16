class Overseers::BibleSalesOrdersController < Overseers::BaseController
  before_action :set_bible_sales_order, only: [:show]

  def index
    @sales_orders = ApplyDatatableParams.to(BibleSalesOrder.all, params)
    authorize_acl :bible_sales_order, 'index'
  end

  def show
    authorize_acl :bible_sales_order, 'show'

    respond_to do |format|
      format.html {}
      format.pdf do
        render_pdf_for @sales_order
      end
    end
  end

  private

  def set_bible_sales_order
    @sales_order = BibleSalesOrder.find(params[:id])
  end

end
