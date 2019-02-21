class ChangeDataTypeOfRatings < ActiveRecord::Migration[5.2]
  def change
    change_column :company_reviews, :rating ,:float
    change_column :review_questions, :weightage, :float
    change_column :review_questions, :rating, :float
    change_column :company_ratings, :rating, :float
  end
end
