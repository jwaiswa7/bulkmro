class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show, :render_rating_form, :update_rating]
  before_action :set_notification, only: [:create]

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

  def autocomplete_company_type
    @companies = ApplyParams.to(Company.active, params)
    authorize @companies
  end

  def new
    if params[:ccr_id].present?
      requested_comp = CompanyCreationRequest.where(id: params[:ccr_id]).last
      if !requested_comp.nil?
        @company = Company.new({'name': requested_comp.name, 'company_creation_request_id': params[:ccr_id]}.merge(overseer: current_overseer))
      end
    else
      @account = Account.new
      @company = Company.new(overseer: current_overseer)
    end
    authorize @company
  end

  def new_commpany
    @company = Company.new(overseer: current_overseer)
    authorize @company
  end

  def create
    @company = Company.new(company_params.merge(overseer: current_overseer))
    authorize @company
    if params[:ccr_id].present?
      if @company.save
        if @company.company_creation_request.present?
          @company.company_creation_request.update_attributes(company_id: @company.id)
          @company.company_creation_request.activity.update_attributes(company: @company)
          @notification.send_company_creation_confirmation(
              @company.company_creation_request,
              action_name.to_sym,
              @company,
              overseers_company_path(@company),
              @company.name.to_s
          )
        end
        if @company.save_and_sync
          redirect_to overseers_company_path(@company), notice: flash_message(@company, action_name)
        end
      else
        render 'new'
      end
    else
      if params[:company]['account_id'].present?
        @account = Account.find_by_id(params[:company]['account_id'])
      else
        account_params = {name: params[:company]['account_name'], account_type: params[:company]['acc_type']}
        @account = Account.new(account_params.merge(overseer: current_overseer))
        @account.save_and_sync
      end

      @company.account = @account
      @company.save_and_sync

      redirect_to overseers_company_path(@company), notice: flash_message(@company, action_name)
    end
  end

  def show
    authorize @company
  end

  def export_all
    authorize :company
    service = Services::Overseers::Exporters::CompaniesExporter.new(params[:q], current_overseer, [])
    service.call

    redirect_to url_for(Export.companies.not_filtered.last.report)
  end

  def export_filtered_records
    authorize :company

    service = Services::Overseers::Finders::Companies.new(params, current_overseer, paginate: false)
    service.call

    export_service = Services::Overseers::Exporters::CompaniesExporter.new(nil, current_overseer, service.indexed_records.pluck(:id))
    export_service.call
  end

  def company_report
    authorize :company

    respond_to do |format|
      format.html {
        if params['company_report'].present?
          @date_range = params['company_report']['date_range']
        end
      }
      format.json do
        service = Services::Overseers::Finders::CompanyReports.new(params, current_overseer)
        service.call

        if params['company_report'].present?
          @date_range = params['company_report']['date_range']
        end

        indexed_company_reports = service.indexed_records.aggregations['company_report_over_month']['buckets']['custom-range']['company_report']['buckets']
        @per = (params['per'] || params['length'] || 20).to_i
        @page = params['page'] || ((params['start'] || 20).to_i / @per + 1)
        @indexed_company_reports = Kaminari.paginate_array(indexed_company_reports).page(@page).per(@per)
      end
    end
  end

  def export_company_report
    authorize :company
    service = Services::Overseers::Finders::CompanyReports.new(params, current_overseer)
    service.call

    indexed_company_reports = service.indexed_records.aggregations['company_report_over_month']['buckets']['custom-range']['company_report']['buckets']

    if params['company_report'].present?
      date_range = params['company_report']['date_range']
    else
      date_range = 'Overall'
    end

    export_service = Services::Overseers::Exporters::CompanyReportsExporter.new([], current_overseer, indexed_company_reports, date_range)
    export_service.call

    redirect_to url_for(Export.company_report.not_filtered.last.report)
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
        contact_ids: [],
        brand_ids: [],
        product_ids: [],
    )
  end
end
