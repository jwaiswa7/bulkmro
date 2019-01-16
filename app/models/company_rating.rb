class CompanyRating < ApplicationRecord
  belongs_to :company_survey
  belongs_to :review_question
end
