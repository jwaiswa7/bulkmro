class Overseers::Companies::CompanyReviewsController < Overseers::Companies::BaseController
  def index
    # 8082
    @company_reviews = ApplyDatatableParams.to(CompanyReview.where(company_id: @company.id), params.reject! { |k, v| k == 'company_id' })
    render 'overseers/company_reviews/index'
    authorize :company_review
  end
end
