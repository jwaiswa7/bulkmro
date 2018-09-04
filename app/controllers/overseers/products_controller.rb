class Overseers::ProductsController < Overseers::BaseController
  before_action :set_product, only: [:show, :edit, :update, :best_prices]

  def index
    @products = ApplyDatatableParams.to(Product.approved.includes(:brand), params)
    authorize @products
  end

  def autocomplete
    @products = ApplyParams.to(Product.approved.includes(:brand), params)
    authorize @products
  end

  def pending
    @products = ApplyDatatableParams.to(Product.not_rejected.left_joins(:inquiry_products, :approval).merge(ProductApproval.where(product_id: nil)).group(:id).order('count(inquiry_products.id) Desc'), params)
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

  def best_prices
    @supplier = Company.acts_as_supplier.find(params[:supplier_id])
    authorize @product
    render json: {
        lowest_unit_cost_price: @product.lowest_unit_cost_price_for(@supplier),
        latest_unit_cost_price: @product.latest_unit_cost_price_for(@supplier)
    }
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
