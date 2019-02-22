class Overseers::SalesReceiptsController  < Overseers::BaseController
  before_action :set_sales_receipts, only: [:show]

  def index
    service = Services::Overseers::Finders::SalesReceipts.new(params)
    service.call
    @indexed_sales_receipts = service.indexed_records
    @sales_receipts = service.records

    authorize @sales_receipts
  end

  def show
    authorize @sales_receipt
  end

  private

  def set_sales_receipts
    @sales_receipt ||= SalesReceipt.find(params[:id])
  end
end
