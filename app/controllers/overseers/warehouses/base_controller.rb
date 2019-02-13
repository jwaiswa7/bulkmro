

class Overseers::Warehouses::BaseController < Overseers::BaseController
  before_action :set_warehouse

  private
    def set_warehouse
      @warehouse = Warehouse.find(params[:warehouse_id])
    end
end
