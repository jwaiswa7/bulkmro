class Services::Overseers::CompanyReviews::CreateCompanyReview < Services::Shared::BaseService
  def initialize(order, current_overseer, request, review_type)
    @order = order
    @current_overseer = current_overseer
    @request = request
    @review_type = review_type
  end

  def call
    if @order.class.name == 'SalesOrder'
      suppliers = order.inquiry.suppliers.uniq
    else
      suppliers = order.suppliers.uniq
    end
    company_reviews = []
    suppliers.each do |supplier|
      company_review = request.company_reviews.where(created_by: current_overseer, survey_type: review_type, company: supplier).first_or_create
      company_reviews << company_review
    end
    company_reviews
  end

  attr_accessor :order, :current_overseer, :request, :review_type
end
