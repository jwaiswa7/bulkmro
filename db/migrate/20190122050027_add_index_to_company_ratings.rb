class AddIndexToCompanyRatings < ActiveRecord::Migration[5.2]
  def change
    add_index :company_ratings, [:company_review_id, :review_question_id, :created_by_id], unique: true, name: 'index_on_company_rating'
  end
end
