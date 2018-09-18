class Overseers::BrandsController < Overseers::BaseController
  before_action :set_brand, only: [:edit, :update, :show]

  def index
    @brands = ApplyDatatableParams.to(Brand.all, params)
    authorize @brands
  end

  def show
    redirect_to edit_overseers_brand_path(@brand)
    authorize @brand
  end

  def new
    @brand = Brand.new(overseer: current_overseer)
    authorize @brand
  end

  def create
    @brand = Brand.new(brand_params.merge(overseer: current_overseer))
    authorize @brand

    if @brand.save
      redirect_to overseers_brands_path, notice: flash_message(@brand, action_name)
    else
      render :new
    end
  end

  def edit
    authorize @brand
  end

  def update
    @brand.assign_attributes(brand_params.merge(overseer: current_overseer))
    authorize @brand

    if @brand.save
      redirect_to overseers_brands_path, notice: flash_message(@brand, action_name)
    else
      render :new
    end
  end

  private
  def set_brand
    @brand ||= Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(
        :name,
        :company_ids => []
    )
  end
end
