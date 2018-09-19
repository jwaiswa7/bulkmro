class Overseers::TaxCodesController < Overseers::BaseController

  def autocomplete
    @tax_codes = ApplyParams.to(TaxCode.all, params)
    authorize @tax_codes
  end

end
