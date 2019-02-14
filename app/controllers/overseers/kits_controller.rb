# frozen_string_literal: true

class Overseers::KitsController < Overseers::BaseController
  before_action :set_kit, only: [:show, :edit, :update]

  def index
    @kits = ApplyDatatableParams.to(Kit.all, params)
    authorize @kits
  end

  def show
    authorize @kit
  end

  def new
    @kit = Kit.new(overseer: current_overseer, inquiry_id: inquiry)
    @kit.build_product

    authorize @kit
  end

  def create
    @kit = Kit.new(kit_params.merge(overseer: current_overseer))

    authorize @kit
    if @kit.save

      if @kit.inquiry.present?
        @kit_products = @kit.inquiry.try(:final_sales_quote).try(:sales_quote_rows) || @kit.inquiry.inquiry_products
        @kit_products.each do |kit_product|
          @kit.kit_product_rows.where(product_id: kit_product.product.id).first_or_create! do |row|
            row.quantity = kit_product.quantity
            row.tax_code = kit_product.try(:tax_code) || kit_product.product.tax_code
            row.tax_rate = kit_product.try(:tax_rate) || kit_product.product.tax_rate
          end
        end
        @kit.save
      end

      redirect_to overseers_kit_path(@kit), notice: flash_message(@kit, action_name)
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
    if @kit.product.approved? ? @kit.save_and_sync : @kit.save
      redirect_to overseers_kit_path(@kit), notice: flash_message(@kit, action_name)
    else
      render 'edit'
    end
  end

  private

    def inquiry
      params[:inquiry_id].present? ? params[:inquiry_id] : nil
    end

    def kit_params
      params.require(:kit).permit(
        :inquiry_id,
          product_attributes: [:id, :name, :sku, :mpn, :is_service, :brand_id, :category_id, :tax_code_id, :measurement_unit_id, :overseer],
          kit_product_rows_attributes: [:id, :product_id, :quantity, :tax_code_id, :tax_rate_id, :_destroy]
      )
    end

    def set_kit
      @kit = Kit.find(params[:id])
    end
end
