class Overseers::CustomerProductsController < Overseers::BaseController

  before_action :set_customer_product, only: [:show, :edit, :update]
  before_action :set_company, only: [:new, :generate_products, :remove_products]

  def index
    @products = ApplyDatatableParams.to(CustomerProduct.all, params)
    authorize @products
  end

  def autocomplete
    account = Account.find(params[:account_id]) if params[:account_id].present?
    company = Company.find(params[:company_id]) if params[:company_id].present?
    customer_products = (account || company).customer_products

    @products = ApplyParams.to(customer_products, params)
    authorize @products
  end

  def show
    authorize @customer_product
  end

  def new
    @customer_product = @company.customer_products.new(:overseer => current_overseer)
    authorize @customer_product
  end

  def edit
    authorize @customer_product
  end

  def create
    @customer_product = CustomerProduct.new(customer_product_params)
    authorize @customer_product

    if @customer_product.save
      redirect_to overseers_customer_product_path(@customer_product, @customer_product.company), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  def generate_products
    authorize :customer_product
    @company.generate_products(current_overseer)

    redirect_to overseers_company_path(@company)
  end

  def remove_products
    authorize :customer_product
    @company.remove_products

    redirect_to overseers_company_path(@company)
  end

  def update
    @customer_product.assign_attributes(customer_product_params)
    authorize @customer_product

    if @customer_product.save
      redirect_to overseers_customer_product_path(@customer_product, @customer_product.company), notice: flash_message(@customer_product, action_name)
    else
      render 'edit'
    end
  end

  private

  def set_company
    @company ||= Company.find(params[:company_id])
  end

  def set_customer_product
    @customer_product ||= CustomerProduct.find(params[:id])
  end

  def customer_product_params
    params.require(:customer_product).permit(
        :name,
        :company_id,
        :product_id,
        :tax_code_id,
        :tax_rate_id,
        :measurement_unit_id,
        :customer_price,
        :sku,
        :brand_id,
        :category_id,
        :moq
    )
  end

end