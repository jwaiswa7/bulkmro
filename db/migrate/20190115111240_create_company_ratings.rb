class CreateCompanyRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :company_ratings do |t|
      t.integer :rating
      t.references :company_review, foreign_key: true

      t.timestamps
    end
  end
end
