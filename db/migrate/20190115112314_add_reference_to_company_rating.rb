class AddReferenceToCompanyRating < ActiveRecord::Migration[5.2]
  def change
    add_reference :company_ratings ,:review_question, foreign_key: true
  end
end
