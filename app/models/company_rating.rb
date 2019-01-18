class CompanyRating < ApplicationRecord
  include Mixins::CanBeStamped

  belongs_to :company_review
  belongs_to :review_question

  validates_numericality_of :rating, :greater_than => 0.0, on: :update

  def calculate_rating
    self.rating * self.review_question.weightage / 100
  end
end
