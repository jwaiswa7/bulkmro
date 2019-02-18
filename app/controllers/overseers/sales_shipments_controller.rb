# frozen_string_literal: true

class Overseers::SalesShipmentsController < Overseers::BaseController
  def index
    authorize :sales_shipment

    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::SalesShipments.new(params, current_overseer, paginate: false)
        service.call

        per = (params[:per] || params[:length] || 20).to_i
        page = params[:page] || ((params[:start] || 20).to_i / per + 1)

        @indexed_sales_shipments = service.indexed_records.per(per).page(page)
        @sales_shipments = service.records.page(page).per(per).try(:reverse)

        if SalesShipment.count != @indexed_sales_shipments.total_count
          status_records = service.records.try(:reverse)
          @statuses = status_records.pluck(:status)
        else
          @statuses = SalesShipment.all.pluck(:status)
        end
      end
    end
  end
end
