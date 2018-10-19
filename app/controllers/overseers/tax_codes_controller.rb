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
      render 'edit'
    end
  end

  private
  def set_tax_code
    @tax_code ||= TaxCode.find(params[:id])
  end

  def tax_code_params
    params.require(:tax_code).permit(
        :code,
        :tax_percentage
    )
  end

end
