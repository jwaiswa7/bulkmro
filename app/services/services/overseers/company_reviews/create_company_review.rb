class Services::Overseers::CompanyReviews::CreateCompanyReview < Services::Shared::BaseService
  def initialize(order, current_overseer)
    @order = order
    @current_overseer = current_overseer
  end

  def call
    suppliers = order.inquiry.suppliers.uniq
    review_type = 'Logistics'
    if current_overseer.inside? || current_overseer.outside? || current_overseer.manager?
      review_type = 'Sales'
    elsif current_overseer.logistics?
      review_type = 'Logistics'
    end
    company_reviews = []
    suppliers.each do |supplier|
      company_review = supplier.company_reviews.where(created_by: current_overseer, survey_type: review_type).first_or_create!
      company_reviews << company_review
    end
    company_reviews
  end

  attr_accessor :order, :current_overseer
end
