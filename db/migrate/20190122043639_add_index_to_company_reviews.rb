class AddIndexToCompanyReviews < ActiveRecord::Migration[5.2]
  def change
    add_index :company_reviews, [:company_id, :survey_type, :created_by_id], unique: true, name: 'index_on_company_review'
  end
end
