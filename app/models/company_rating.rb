class CompanyRating < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company_review
  belongs_to :review_question

  validates_numericality_of :rating, :greater_than => 0.0, on: :update
  ratyrate_rateable

  def calculate_rating
    if self.rates.present?
      self.rates.last.stars * self.review_question.weightage / 100
    else
      0.0
    end
  end
end
