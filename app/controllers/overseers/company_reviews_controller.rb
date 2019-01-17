class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update_rating]

  def update_rating
    company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
    company_ratings_attributes.each do |index,company_rating_attribute|
      @company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).update({rating: company_rating_attribute['rating'].to_i})
    end

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum / @company_review.company_ratings.count
    @company_review.update!(rating: average_company_rating)

    authorize @company_review
    redirect_to new_overseers_po_request_path(:sales_order_id=>params[:sales_order_id])
  end

  private

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
