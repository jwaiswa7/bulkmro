class Overseers::Warehouses::ProductStocksController < Overseers::Warehouses::BaseController
  def index
    @warehouse_products = ApplyDatatableParams.to(WarehouseProductStock.all, params)
    authorize_acl @warehouse_products
  end
end
