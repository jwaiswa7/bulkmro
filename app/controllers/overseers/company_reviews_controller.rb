class Overseers::CompanyReviewsController < Overseers::BaseController
  before_action :set_company_review, only: [:update_rating,:show]

  def index
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where.not(:rating => nil), params)
    authorize @company_reviews
  end

  def update_rating
    authorize @company_review
    company_ratings_attributes = params['company_review']['company_ratings_attributes'] if params['company_review'].present? && params['company_review']['company_ratings_attributes'].present?
    company_ratings_attributes.each do |index,company_rating_attribute|
      if !@company_review.company_ratings.where(id: company_rating_attribute['id'].to_i).first.update({rating: company_rating_attribute['rating'].to_f})
        redirect_to_path_genaration("Please enter Feedback to proceed.")
        return
      end
    end

    average_company_rating = @company_review.company_ratings.map(&:calculate_rating).sum
    @company_review.update_attributes!(rating: average_company_rating, overseer: current_overseer)

    overall_rating = CompanyReview.where(company_id: @company_review.company_id).average(:rating)
    company = Company.find(@company_review.company_id)
    company.assign_attributes({rating: overall_rating})
    company.save(validate: false)

    redirect_to_path_genaration("Feedback captured successfully.")
  end
  def show
    authorize @company_review
  end

  private

  def redirect_to_path_genaration(message)
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
