class Overseers::SalesReceiptsController < Overseers::BaseController
  def index
    service = Services::Overseers::Finders::SalesReceipts.new(params)
    service.call
    @indexed_sales_receipts = service.indexed_records
    @sales_receipts = service.records

    authorize @sales_receipts
  end
end
