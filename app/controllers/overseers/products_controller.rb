class Overseers::ProductsController < Overseers::BaseController
  before_action :set_product, only: [:show, :edit, :update]

  def index
    @products = Product.all
    authorize @products
  end

  def new
    @product = Product.new(:overseer => current_overseer)
    authorize @product
  end
  
  def create
    @product = Product.new(product_params.merge(overseer: current_overseer))
    authorize @product
    if @product.save
      redirect_to overseers_products_path, notice: flash_message(@product, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @product
  end

  def update
    @product.assign_attributes(product_params.merge(overseer: current_overseer))
    authorize @product
    if @product.save
      redirect_to overseers_products_path, notice: flash_message(@product, action_name)
    end
  end

  private
  def product_params
    params.require(:product).permit(
        :name,
        :sku,
        :brand_id,
    )
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
