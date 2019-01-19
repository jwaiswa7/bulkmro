class Services::Overseers::CompanyReviews::CreateCompanyReview < Services::Shared::BaseService
  def initialize(order,current_overseer,review_type)
    @order = order
    @current_overseer = current_overseer
    @review_type = review_type
  end

  def call
    suppliers_not_reviewed = {}
    order.inquiry.suppliers.uniq.each do |supplier|
      if !supplier.company_reviews.reviewed(current_overseer,@review_type).present?
        suppliers_not_reviewed[supplier.id] = false
      end
    end

    if !suppliers_not_reviewed.empty?
      @supplier = Company.where(id: suppliers_not_reviewed.keys.first).first
      @can_review = !@supplier.company_reviews.present? || !@supplier.company_reviews.reviewed(current_overseer,@review_type).present?

      if @can_review
        @company_review = CompanyReview.where(created_by: current_overseer, survey_type: @review_type, company: @supplier).first_or_create!

        if @review_type == 'Sales'
          review_questions = ReviewQuestion.sales
        elsif @review_type == 'Logistics'
          review_questions = ReviewQuestion.logistics
        end

        review_questions.each do |question|
          CompanyRating.where({company_review_id: @company_review.id, review_question_id: question.id, created_by: current_overseer}).first_or_create!
        end
      else
        @company_review = CompanyReview.new
      end
    end
  end

  attr_accessor :order, :current_overseer, :review_type, :company_review, :can_review
end