class Overseers::KitsController < Overseers::BaseController
  before_action :set_kit, only: [:edit, :update]

  # def index
  #   service = Services::Overseers::Finders::Products.new(params)
  #   service.call
  #
  #   @indexed_products = service.indexed_records
  #   @products = service.records
  #   authorize @products
  # end

  def index
    @kits = ApplyDatatableParams.to(Kit.all, params)
    authorize @kits
  end

  # def autocomplete
  #   service = Services::Overseers::Finders::Products.new(params.merge(page: 1))
  #   service.call
  #
  #   @indexed_products = service.indexed_records
  #   @products = service.records
  #
  #   authorize @products
  # end

  def new
    @kit = Kit.new(:overseer => current_overseer)
    @kit.build_product

    authorize @kit
  end

  def create
    @kit = Kit.new(kit_params.merge(overseer: current_overseer))

    authorize @kit
    if @kit.save
      redirect_to overseers_kits_path, notice: flash_message(@kit, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @kit
  end

  def update
    @kit.assign_attributes(kit_params.merge(overseer: current_overseer))
    authorize @kit
    if @kit.save_and_sync #@kit.product.approved? ? @kit.save_and_sync : @kit.save
      redirect_to overseers_kits_path, notice: flash_message(@kit, action_name)
    else
      render 'edit'
    end
  end

  private

  def kit_params
    params.require(:kit).permit(
        :inquiry_id,
        :product_attributes => [:id, :name, :sku, :mpn, :is_service, :brand_id, :category_id, :tax_code_id, :measurement_unit_id, :overseer],
        :kit_product_rows_attributes => [:id, :product_id, :quantity]
    )
  end

  def set_kit
    @kit = Kit.find(params[:id])
  end
end
