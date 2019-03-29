class Overseers::SuppliersController < Overseers::BaseController
  def index
    base_filter = {
        base_filter_key: 'is_supplier',
        base_filter_value: true
    }
    service = Services::Overseers::Finders::Companies.new(params.merge(base_filter))
    service.call
    @indexed_companies = service.indexed_records
    @companies = service.records
    authorize @companies

    render 'index'
  end

  def autocomplete
    @suppliers = ApplyParams.to(Company.acts_as_supplier, params)
    authorize @suppliers
  end
end
