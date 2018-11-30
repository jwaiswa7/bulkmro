class Overseers::Companies::ProductsController < Overseers::Companies::BaseController

  def index
    service = Services::Overseers::Finders::Products.new(params)
    service.call

    @indexed_products = service.indexed_records
    @products = service.records
    authorize @products
    end
  end