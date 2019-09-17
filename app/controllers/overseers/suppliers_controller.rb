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
    authorize_acl @companies

    render 'index'
  end

  def customized_index
    base_filter = {
        base_filter_key: 'is_supplier',
        base_filter_value: true
    }
    service = Services::Overseers::Finders::Companies.new(params.merge(base_filter))
    service.call
    @indexed_companies = service.indexed_records
    @companies = service.records
    authorize_acl @companies

    render 'customized_index'
  end

  def autocomplete
    @suppliers = ApplyParams.to(Company.acts_as_supplier, params)
    authorize_acl @suppliers
  end

  def export_all
    authorize_acl :supplier
    service = Services::Overseers::Exporters::SuppliersExporter.new(params[:q], current_overseer, [])
    service.call

    redirect_to url_for(Export.suppliers.not_filtered.last.report)
  end

  def export_filtered_records
    authorize_acl :supplier

    service = Services::Overseers::Finders::Companies.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::SuppliersExporter.new(nil, current_overseer, service.indexed_records)
    export_service.call
  end
end
