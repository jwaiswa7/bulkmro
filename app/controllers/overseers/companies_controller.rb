class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    @companies = ApplyDatatableParams.to(Company.all.includes(:contacts, :account, :addresses, :inquiries), params)
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
    service = Services::Overseers::Exporters::CompaniesExporter.new

    respond_to do |format|
      format.html
      format.csv {send_data service.call, filename: service.filename}
    end
  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
