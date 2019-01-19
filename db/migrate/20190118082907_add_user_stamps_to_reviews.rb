class AddUserStampsToReviews < ActiveRecord::Migration[5.2]
  def change

    add_column :company_reviews, :created_by_id, :integer, index: true
    add_column :company_reviews, :updated_by_id, :integer, index: true

    add_foreign_key :company_reviews, :overseers, column: 'created_by_id'
    add_foreign_key :company_reviews, :overseers, column: 'updated_by_id'

    add_column :company_ratings, :created_by_id, :integer, index: true
    add_column :company_ratings, :updated_by_id, :integer, index: true

    add_foreign_key :company_ratings, :overseers, column: 'created_by_id'
    add_foreign_key :company_ratings, :overseers, column: 'updated_by_id'

    add_column :review_questions, :created_by_id, :integer, index: true
    add_column :review_questions, :updated_by_id, :integer, index: true

    add_foreign_key :review_questions, :overseers, column: 'created_by_id'
    add_foreign_key :review_questions, :overseers, column: 'updated_by_id'

  end
end
