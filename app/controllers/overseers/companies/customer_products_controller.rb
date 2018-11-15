class Overseers::Companies::CustomerProductsController < Overseers::Companies::BaseController
  before_action :set_product, only: [:show, :edit, :update]

  def autocomplete
    @addresses = ApplyParams.to(@company.addresses, params)
    authorize @addresses
  end

  def show
    authorize @product
  end


  def index
    redirect_to overseers_company_path(@company)
    authorize @company
  end

  def edit
    authorize @product
  end

  def update
    @product.assign_attributes(address_params.merge(overseer: current_overseer))
    authorize @product

    if @product.save_and_sync
      @company.update_attributes(:default_billing_address => @product) if @company.default_billing_address.blank?
      @company.update_attributes(:default_shipping_address => @product) if @company.default_shipping_address.blank?
      redirect_to overseers_company_path(@company), notice: flash_message(@product, action_name)
    else
      render 'edit'
    end
  end

  private

  def set_product
    @product ||= CustomerProduct.find(params[:id])
  end

  def product_params
    params.require(:address).permit(
        :name,
        :country_code,
        :pincode,
        :city_name,
        :address_state_id,
        :state_name,
        :street1,
        :street2,
        :telephone,
        :mobile,
        :gst_proof,
        :cst_proof,
        :vat_proof,
        :excise_proof,
        :gst,
        :cst,
        :vat,
        :tan,
        :excise,
        :gst_type
    )
  end
end
