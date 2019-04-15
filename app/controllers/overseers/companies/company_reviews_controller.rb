class Overseers::Companies::CompanyReviewsController < Overseers::Companies::BaseController
  def index
    # 8082
    base_filter = {
        base_filter_key: 'company_id',
        base_filter_value: params[:company_id]
    }
    authorize :company_review
    respond_to do |format|
      format.html { }
      format.json do
        service = Services::Overseers::Finders::CompanyReviews.new(params.merge(base_filter), current_overseer)
        service.call
        @indexed_company_reviews = service.indexed_records
        @company_reviews = service.records
      end
    end
  end

end
