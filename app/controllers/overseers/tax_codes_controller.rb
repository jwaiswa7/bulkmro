class Overseers::TaxCodesController < Overseers::BaseController
  before_action :set_tax_code, only: [:edit, :update, :show]

  def autocomplete
    @tax_codes = ApplyParams.to(TaxCode.all, params).order(:code)
    authorize @tax_codes
  end

  def index
    @tax_codes = ApplyDatatableParams.to(TaxCode.all, params)
    authorize @tax_codes
  end

  def show
    redirect_to edit_overseers_tax_code_path(@tax_codes)
    authorize @tax_codes
  end

  def edit
    authorize @tax_codes
  end

  def update
    @tax_codes.assign_attributes(tax_code_params)
    authorize @tax_codes

    if @tax_codes.save
      redirect_to overseers_tax_codes_path, notice: flash_message(@tax_codes, action_name)
    else
      render 'edit'
    end
  end

  private
  def set_tax_code
    @tax_codes ||= TaxCode.find(params[:id])
  end

  def tax_code_params
    params.require(:tax_code).permit(
        :code,
        :tax_percentage
    )
  end

end
