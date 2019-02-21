class AddRatingToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :rating, :float
  end
end
