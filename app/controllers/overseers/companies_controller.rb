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

  # For rendering rating form modal
  # def render_rating_form
  #   authorize @company
  #   type = ""
  #   review_questions = ReviewQuestion.logistics
  #   if current_overseer.inside? || current_overseer.outside? || current_overseer.manager?
  #     type = "Sales"
  #     review_questions =ReviewQuestion.sales
  #   elsif current_overseer.logistics?
  #     type = "Logistics"
  #     review_questions = ReviewQuestion.logistics
  #   end
  #
  #   company_review = CompanyReview.where(created_by: current_overseer, survey_type: type, company: @company).first_or_create!
  #   review_questions.each do |question|
  #     company_review.company_ratings.where({review_question_id: question.id, created_by: current_overseer}).first_or_create!
  #   end
  #
  #   respond_to do |format|
  #     format.html {render :partial => "rating_modal",  locals: {company_review: company_review,:supplier => @company}}
  #   end
  # end

  # For updaring rating form popup
  # def update_rating
  #   authorize @company
  #   company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
  #   @company_review = CompanyReview.find(params[:company_review][:id])
  #   if @company_review.present?
  #     company_ratings_attributes.each do |index,company_rating_attribute|
  #       @company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).update({rating: company_rating_attribute['rating'].to_i})
  #     end
  #     average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
  #     @company_review.update!(rating: average_company_rating)
  #     overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
  #     @company.update!({rating: overall_rating})
  #   end
  #   redirect_to overseers_companies_path
  # end

  def autocomplete
    @companies = ApplyParams.to(Company.active, params)
    authorize @companies
  end

  def new
    if params[:ccr_id].present?
      requested_comp = CompanyCreationRequest.where(id: params[:ccr_id]).last
      if !requested_comp.nil?
        @company = Company.new({ 'name': requested_comp.name, 'company_creation_request_id': params[:ccr_id] }.merge(overseer: current_overseer))
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
          contact_ids: [],
          brand_ids: [],
          product_ids: [],
          )
    end
end
