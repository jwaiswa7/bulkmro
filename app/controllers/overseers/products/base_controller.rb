class Overseers::Products::BaseController < Overseers::BaseController
  before_action :set_product

  private
  def set_product
    @product = Product.unscoped.find(params[:product_id])
  end
end
