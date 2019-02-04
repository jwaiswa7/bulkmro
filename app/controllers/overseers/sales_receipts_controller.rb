class Overseers::SalesReceiptsController  < Overseers::BaseController
  before_action :set_sales_receipts, only: [:show]

  def index

  end




  def show
    authorize @sales_receipt
  end

  private

  def set_sales_receipts
    @sales_receipt ||= SalesReceipt.find(params[:id])
  end
end
