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
    company_review = CompanyReview.where(created_by: current_overseer, survey_type: type, rateable: @company).first_or_create!

    review_questions.each do |question|
      CompanyRating.where({company_review_id: company_review.id, review_question_id: question.id, created_by: current_overseer}).first_or_create!
    end
    respond_to do |format|
      format.html {render :partial => "rating_modal",  locals: {company_review: company_review,:supplier => @company}}
    end
  end


  def update_rating
    authorize @company

    @company_review = CompanyReview.find(params[:company_review][:id])
    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)
    Rate.create({rater: current_overseer, rateable_type: "CompanyReview", rateable_id: @company_review.id, stars: @company_review.company_ratings.map(&:calculate_rating).sum})
    # average_company_rating = @company_review.rating_for(@company_review,'CompanyRating')
    overall_rating = CompanyReview.where(rateable_id: @company_review.rateable_id).average(:rating)
    Rate.create({rater: current_overseer, rateable_type: @company_review.rateable_type, rateable_id: @company_review.rateable_id, stars: overall_rating})
    @company_review.rateable.update({rating: overall_rating})

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
