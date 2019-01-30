class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update, :show, :render_form]

  def index
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where.not(:rating => nil), params)
    authorize @company_reviews
  end

  def update
    authorize @company_review

    if @company_review.company_ratings.map(&:rating).include?nil
      redirect_to_path_generation("Please rate all questions before submitting.", 500)
      return
    end

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    puts average_company_rating
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)
    @company_review.rate(average_company_rating, current_overseer, "CompanyRating")
    Rate.create({rater: current_overseer, rateable_type: "CompanyReview", rateable_id: @company_review.id, stars: @company_review.company_ratings.map(&:calculate_rating).sum})
    # average_company_rating = @company_review.rating_for(@company_review,'CompanyRating')
    overall_rating = CompanyReview.where(rateable_id: @company_review.rateable_id).average(:rating)
    @company_review.rateable.rate(overall_rating, current_overseer, "CompanyReview")
    Rate.create({rater: current_overseer, rateable_type: "Company", rateable_id: @company_review.rateable.id, stars: overall_rating})
    @company_review.rateable.update({rating: overall_rating})

    redirect_to_path_generation("Feedback captured successfully.", 200)
  end

  def show
    authorize @company_review
  end

  def render_form
    authorize @company_review
    if @current_overseer.inside? || @current_overseer.outside? || @current_overseer.manager?
      @review_type = "Sales"
      review_questions = ReviewQuestion.sales
    elsif @current_overseer.logistics?
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
