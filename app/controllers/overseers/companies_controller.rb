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
    @companies = ApplyParams.to(Company.active, params)
    authorize @companies
  end

  def show
    authorize @company
  end

  def export_all
    authorize :inquiry
    service = Services::Overseers::Exporters::CompaniesExporter.new(headers)
    self.response_body = service.call
    # Set the status to success
    response.status = 200
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
