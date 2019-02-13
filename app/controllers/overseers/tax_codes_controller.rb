

class Overseers::TaxCodesController < Overseers::BaseController
  before_action :set_tax_code, only: [:edit, :update, :show]

  def autocomplete
    @tax_codes = ApplyParams.to(TaxCode.active.where("is_service = ?", params[:is_service]), params)
    authorize :tax_code
  end

  def autocomplete_for_product
    @product = Product.find(params[:product_id])
    @is_service = @product.try(:is_service) || false
    @tax_codes = ApplyParams.to(TaxCode.active.where("is_service = ?", @is_service), params)
    authorize @tax_codes
    respond_to do |format|
      format.html { }
      format.json do
        render "autocomplete"
      end
    end
  end

  def index
    @tax_codes = ApplyDatatableParams.to(TaxCode.all, params)
    # service = Services::Overseers::Finders::TaxCodes.new(params)
    # service.call
    # @indexed_taxcodes = service.indexed_records
    # @tax_codes = service.records
    authorize @tax_codes
  end

  def show
    redirect_to edit_overseers_tax_code_path(@tax_code)
    authorize @tax_code
  end

  def edit
    authorize @tax_code
  end

  def update
    @tax_code.assign_attributes(tax_code_params)
    authorize @tax_code

    if @tax_code.save
      redirect_to overseers_tax_codes_path, notice: flash_message(@tax_code, action_name)
    else
      render "edit"
    end
  end

  def new
    @tax_code = TaxCode.new
    authorize @tax_code
  end

  def create
    @tax_code = TaxCode.new(tax_code_params)

    authorize @tax_code

    if @tax_code.save
      redirect_to overseers_tax_codes_path, notice: flash_message(@tax_code, action_name)
    else
      render "new"
    end
  end

  private

    def set_tax_code
      @tax_code ||= TaxCode.find(params[:id])
    end

    def tax_code_params
      params.require(:tax_code).permit(
        :remote_uid,
          :code,
          :chapter,
          :description,
          :tax_percentage,
          :is_service,
          :is_active,
          :is_pre_gst
      )
    end
end
