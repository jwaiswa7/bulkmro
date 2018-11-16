class Overseers::CustomerProductsController < Overseers::BaseController

  before_action :set_customer_product, only: [:show, :edit, :update]

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

  # def new
  #   @address = @company.addresses.build(overseer: current_overseer)
  #   authorize @address
  # end

  # def index
  #   redirect_to overseers_company_path(@company)
  #   authorize @company
  # end

  # def create
  #   @address = @company.addresses.build(address_params.merge(overseer: current_overseer))
  #   authorize @address
  #
  #   if @address.save_and_sync
  #     @company.update_attributes(:default_billing_address => @address) if @company.default_billing_address.blank?
  #     @company.update_attributes(:default_shipping_address => @address) if @company.default_shipping_address.blank?
  #
  #     redirect_to overseers_company_path(@company), notice: flash_message(@address, action_name)
  #   else
  #     render 'new'
  #   end
  # end

  def edit
    authorize @customer_product
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

  def set_customer_product
    @customer_product ||= CustomerProduct.find(params[:id])
  end

  def customer_product_params
    params.require(:customer_product).permit(
        :name,
        :unit_selling_price,
        :sku,
        :brand_id,
        :category_id,
        :moq
    )
  end

end