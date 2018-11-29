class Overseers::Companies::PurchaseOrdersController < Overseers::Companies::BaseController

  def index
    @base_filter = {}
  company = Company.find(params[:company_id])
    @base_filter[:base_filter_key] = "supplier_id"
    @base_filter[:base_filter_value] =  company.id


    authorize :purchase_order
    respond_to do |format|
      format.html {}
      format.json do

        service = Services::Overseers::Finders::PurchaseOrders.new(params.merge(@base_filter), current_overseer)
        service.call
        @indexed_purchase_orders = service.indexed_records
        @purchase_orders = service.records.try(:reverse)
      end
    end
  end
end
