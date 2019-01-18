class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update_rating]

  def update_rating
    authorize @company_review
    company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
    company_ratings_attributes.each do |index,company_rating_attribute|
      if !@company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).first.update({rating: company_rating_attribute['rating'].to_f})
        redirect_to new_overseers_po_request_path(:sales_order_id=>params[:sales_order_id]), :flash => { :error => "Please Enter Feedback" }
        return
      end
    end

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update!(rating: average_company_rating)

    overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
    company = Company.find(@company_review.company_id)
    company.assign_attributes({rating: overall_rating})
    company.save(validate: false)

    if params[:sales_order_id].present?
      if @company_review.Sales?
        redirect_to new_overseers_po_request_path(:sales_order_id=>params[:sales_order_id])
      else
        redirect_to new_overseers_invoice_request_path(:sales_order_id=>params[:sales_order_id])
      end
    else
      redirect_to new_overseers_invoice_request_path(:purchase_order_id=>params[:purchase_order_id])
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
