class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    service = Services::Overseers::Finders::Companies.new(params)
    service.call

    @indexed_companies = service.indexed_records
    @companies = service.records
    authorize @companies
  end

  def autocomplete
    @companies = ApplyParams.to(Company.all.where(:is_active => true), params)
    authorize @companies
  end

  def show
    authorize @company
  end

  def export_all
    authorize :inquiry
    service = Services::Overseers::Exporters::CompaniesExporter.new
    service.call

    redirect_to url_for(Export.companies.last.report)
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
