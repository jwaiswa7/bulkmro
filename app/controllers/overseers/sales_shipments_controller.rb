class Overseers::SalesShipmentsController < Overseers::BaseController

  def index
    authorize :sales_shipment

    respond_to do |format|
      format.html {}
      format.json do
        service = Services::Overseers::Finders::SalesShipments.new(params, current_overseer)
        service.call

        @indexed_sales_shipments = service.indexed_records
        @sales_shipments = service.records.try(:reverse)

        statuses = {}
        indexed_buckets = service.indexed_records.aggs["statuses"]["buckets"]
        indexed_buckets.map{|bucket| statuses[bucket["key"]] = bucket["doc_count"]}
        @statuses = statuses
      end
    end
  end
end