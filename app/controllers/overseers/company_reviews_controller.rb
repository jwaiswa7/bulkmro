class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update, :show, :render_form]

  def index
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where.not(:rating => nil), params)
    authorize @company_reviews
  end

  def update
    authorize @company_review

    if @company_review.company_ratings.map(&:rating).include? nil
      redirect_to_path_generation("Please rate all questions before submitting.", 500)
      return
    end

    # Average of all company ratings updated in respective company review
    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)

    # Rate is model provided by raty_rate gem
    # Rates for company review and its associated rateable document are created explicitly
    # as ratyrate gem does not provide multilevel average calculations
    @company_review.rate(average_company_rating, current_overseer, "CompanyRating")
    create_rates("CompanyReview", @company_review.id, average_company_rating)
    @company_review.rateable.rate(average_company_rating, current_overseer, "CompanyReview")
    create_rates(@company_review.rateable_type, @company_review.rateable.id, average_company_rating)

    # Overall rating is always calculated against a Company(is_supplier)
    # updated in respective company and ratyrate gem's rates model explicitly
    overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
    create_rates("Company", @company_review.company.id, overall_rating)
    @company_review.company.update({rating: overall_rating})

    redirect_to_path_generation("Feedback captured successfully.", 200)
  end

  def show
    authorize @company_review
  end

  def render_form
    authorize @company_review
    if @company_review.survey_type == 'Sales'
      @review_type = "Sales"
      review_questions = ReviewQuestion.sales
    elsif @company_review.survey_type == 'Logistics'
        @review_type = "Logistics"
      review_questions = ReviewQuestion.logistics
    end
    review_questions.each do |question|
      @company_review.company_ratings.where({company_review_id: @company_review.id, review_question_id: question.id, created_by: current_overseer}).first_or_create!
    end
    respond_to do |format|
      format.html {render :partial => "form", locals: {company_review: @company_review}}
    end
  end

  private

  def create_rates(rateable_type, rateable_id, score)
    rate = Rate.where({rater: current_overseer, rateable_type: rateable_type, rateable_id: rateable_id})
    if rate.present?
      Rate.create({rater: current_overseer, rateable_type: rateable_type, rateable_id: rateable_id, stars: score})
    else
      rate.update({stars: score})
    end
  end

  def redirect_to_path_generation(message, status)
    if params[:company_review_redirect]
      redirect_to overseers_company_review_path(@company_review), :flash => {:error => message}
    else
      render :json => {:error => message}, :status => status
    end
  end


  def set_company_review
    @company_review ||= CompanyReview.find(params[:id])
  end

  def company_review_params
    params.require(:company_review).permit(
        :company_review_id,
        :rating,
        :company_ratings_attributes => [:rating, :id]
    )
  end

end
