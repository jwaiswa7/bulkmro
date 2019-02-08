# frozen_string_literal: true

class Overseers::BrandsController < Overseers::BaseController
  before_action :set_brand, only: [:edit, :update, :show]

  def autocomplete
    @brands = ApplyParams.to(Brand.active, params).order(:name)
    authorize @brands
  end

  def index
    @brands = ApplyDatatableParams.to(Brand.all, params)
    authorize @brands
  end

  def show
    @brand_products = Product.where(brand_id: @brand.id)
    @brand_suppliers = (@brand_products.map{ |p| p.suppliers.map{ |ps| ps }.compact.flatten.uniq }.compact.flatten.uniq)

    authorize @brand
  end

  def new
    @brand = Brand.new(overseer: current_overseer)
    authorize @brand
  end

  def create
    @brand = Brand.new(brand_params.merge(overseer: current_overseer))
    authorize @brand

    if @brand.save_and_sync
      redirect_to overseers_brands_path, notice: flash_message(@brand, action_name)
    else
      render "new"
    end
  end

  def edit
    authorize @brand
  end

  def update
    @brand.assign_attributes(brand_params.merge(overseer: current_overseer))
    authorize @brand

    if @brand.save_and_sync
      redirect_to overseers_brands_path, notice: flash_message(@brand, action_name)
    else
      render "edit"
    end
  end

  private
    def set_brand
      @brand ||= Brand.find(params[:id])
    end

    def brand_params
      params.require(:brand).permit(
        :name,
          :is_active,
          company_ids: []
      )
    end
end
