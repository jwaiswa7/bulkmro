class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show]

  def index
    service = Services::Overseers::Finders::Companies.new(params)
    service.call

    @indexed_companies = service.indexed_records
    @companies = service.records
    authorize @companies
  end

  def new
    if params[:ccr_id].present?
      requested_comp = CompanyCreationRequest.where(:id => params[:ccr_id]).last
      if !requested_comp.nil?
        @company = Company.new({'name': requested_comp.name, 'company_creation_request_id': params[:ccr_id]}.merge(overseer: current_overseer))
      end
    else
      @account = Company.new(overseer: current_overseer)
    end
    authorize @company
  end

  def create
    @company = Company.new(company_params.merge(overseer: current_overseer))
    authorize @company
    if @company.save
      if @company.company_creation_request.present?
        @company.company_creation_request.update_attributes(:company_id => @company.id)
        @company.company_creation_request.activity.update_attributes(:company => @company)
      end
      if @company.save_and_sync
        redirect_to overseers_company_path(@company), notice: flash_message(@company, action_name)
      end
    else
      render 'new'
    end
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
    service.call

    redirect_to url_for(Export.companies.last.report)
  end

  def payment_collection_send_mail

  end

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
  def company_params
    params.require(:company).permit(
        :account_id,
        :name,
        :industry_id,
        :remote_uid,
        :default_company_contact_id,
        :default_payment_option_id,
        :default_billing_address_id,
        :default_shipping_address_id,
        :inside_sales_owner_id,
        :outside_sales_owner_id,
        :sales_manager_id,
        :company_type,
        :priority,
        :site,
        :company_creation_request_id,
        :nature_of_business,
        :creadit_limit,
        :tan_proof,
        :pan,
        :pan_proof,
        :cen_proof,
        :logo,
        :is_msme,
        :is_active,
        :is_unregistered_dealer,
        :contact_ids => [],
        :brand_ids => [],
        :product_ids => [],
        )
  end
end
