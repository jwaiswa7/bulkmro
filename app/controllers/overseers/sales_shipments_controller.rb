

class Overseers::SalesShipmentsController < Overseers::BaseController
  def index
    authorize :sales_shipment

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesShipments.new(params, current_overseer)
        service.call

        @indexed_sales_shipments = service.indexed_records
        @sales_shipments = service.records.try(:reverse)

        status_service = Services::Overseers::Statuses::GetSummaryStatusBuckets.new(@indexed_sales_shipments, SalesShipment)
        status_service.call

        @statuses = status_service.indexed_statuses
      end
    end
  end
end
