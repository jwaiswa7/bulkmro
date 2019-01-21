class Overseers::CompaniesController < Overseers::BaseController
  before_action :set_company, only: [:show,:render_rating_form,:update_rating]

  def index
    service = Services::Overseers::Finders::Companies.new(params)
    service.call
    @indexed_companies = service.indexed_records
    @companies = service.records
    authorize @companies
  end

  def render_rating_form
    authorize @company
    type = ""
    review_questions = ReviewQuestion.logistics
    if current_overseer.inside? || current_overseer.outside? || current_overseer.manager?
      type = "Sales"
      review_questions =ReviewQuestion.sales
    elsif current_overseer.logistics?
      type = "Logistics"
      review_questions = ReviewQuestion.logistics
    end

    company_review = CompanyReview.where(created_by: current_overseer, survey_type: type, company: @company).first_or_create!
    review_questions.each do |question|
      CompanyRating.where({company_review_id: company_review.id, review_question_id: question.id, created_by: current_overseer}).first_or_create!
    end
    respond_to do |format|
      format.html {render :partial => "rating_modal",  locals: {company_review: company_review,:supplier => @company}}
    end
  end


  def update_rating
    authorize @company
    company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
    @company_review = CompanyReview.find(params[:company_review][:id])
    if @company_review.present?
      company_ratings_attributes.each do |index,company_rating_attribute|
        @company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).update({rating: company_rating_attribute['rating'].to_i})
      end
      average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
      @company_review.update!(rating: average_company_rating)
      overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
      @company.update!({rating: overall_rating})
    end
    redirect_to overseers_companies_path
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

  private
  def set_company
    @company ||= Company.find(params[:id])
  end
end
