class Overseers::Accounts::CompaniesController < Overseers::Accounts::BaseController
  before_action :set_company, only: [:show, :edit, :update]

  def show
    redirect_to edit_overseers_account_company_path(@account, @company)
    authorize @account
  end

  def new
    @company = @account.companies.build(overseer: current_overseer)
    authorize @company
  end

  def index
    base_filter = {
        base_filter_key: 'account_id',
        base_filter_value: params[:account_id]
    }
    authorize @account
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::Companies.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_companies = service.indexed_records
        @companies = service.records.try(:reverse)
      end
    end
  end

  def create
    @company = @account.companies.build(company_params.merge(overseer: current_overseer))
    authorize @company

    if @company.save_and_sync
      redirect_to overseers_company_path(@company), notice: flash_message(@company, action_name)
    else
      render 'new'
    end
  end

  def edit
    authorize @company
  end

  def update
    @company.assign_attributes(company_params.merge(overseer: current_overseer))
    authorize @company

    options = @company.name_changed? ? { name: @company.name_change[0] } : false

    if @company.save_and_sync(options)
      redirect_to overseers_company_path(@company), notice: flash_message(@company, action_name)
    else
      render 'edit'
    end
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
          :credit_limit,
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
          :is_international,
          :rating,
          contact_ids: [],
          brand_ids: [],
          product_ids: [],
      )
    end
end
