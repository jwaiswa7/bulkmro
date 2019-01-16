class CompanyRating < ApplicationRecord
  belongs_to :company_review
  # belongs_to :review_question
end
