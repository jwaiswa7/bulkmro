class CompanyRating < ApplicationRecord
  belongs_to :company_survey
  belongs_to :survey_question
end
