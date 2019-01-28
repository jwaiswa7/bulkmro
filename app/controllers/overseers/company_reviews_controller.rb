class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update, :show, :render_form]

  def index
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where.not(:rating => nil), params)
    authorize @company_reviews
  end

  def update
    authorize @company_review
    company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
    company_ratings_attributes.each do |index, company_rating_attribute|
      if !@company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).first.update({rating: company_rating_attribute['rating'].to_f})
        redirect_to_path_genaration("Please give star ratings for all the Questions.", 500)
        return
      end
    end

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)

    overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
    company = Company.find(@company_review.company_id)
    company.assign_attributes({rating: overall_rating})
    company.save(validate: false)

    redirect_to_path_genaration("Feedback captured successfully.", 200)
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

  def redirect_to_path_genaration(message, status)
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
