class CompanyRating < ApplicationRecord
  belongs_to :company_review
  belongs_to :review_question

  def calculate_rating
    self.rating * self.review_question.weightage / 100
  end
end
