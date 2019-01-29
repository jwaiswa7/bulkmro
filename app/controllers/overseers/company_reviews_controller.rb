class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update_rating,:show]

  def index
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where.not(:rating => nil), params)
    authorize @company_reviews
  end

  def update_rating
    authorize @company_review

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)
    @company_review.rate(average_company_rating, current_overseer, "CompanyRating")
    Rate.create({rater: current_overseer, rateable_type: "CompanyReview", rateable_id: @company_review.id, stars: @company_review.company_ratings.map(&:calculate_rating).sum})
    # average_company_rating = @company_review.rating_for(@company_review,'CompanyRating')
    overall_rating = CompanyReview.where(rateable_id: @company_review.rateable_id).average(:rating)
    @company_review.rateable.rate(overall_rating, current_overseer, "CompanyReview")
    Rate.create({rater: current_overseer, rateable_type: "Company", rateable_id: @company_review.rateable.id, stars: overall_rating})
    @company_review.rateable.update({rating: overall_rating})

    redirect_to_path_generation("Feedback captured successfully.")
  end
  def show
    authorize @company_review
  end

  private

  def redirect_to_path_generation(message)
    if params[:sales_order_id].present?
      if @company_review.Sales?
        redirect_to new_overseers_po_request_path(:sales_order_id=>params[:sales_order_id]), :flash => { :error => message }
      else
        redirect_to new_overseers_invoice_request_path(:sales_order_id=>params[:sales_order_id]), :flash => { :error => message }
      end
    elsif params[:purchase_order_id].present?
      redirect_to new_overseers_invoice_request_path(:purchase_order_id=>params[:purchase_order_id]), :flash => { :error => message }
    else
      redirect_to overseers_company_review_path(@company_review), :flash => { :error => message }
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
