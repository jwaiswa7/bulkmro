class AddGridViewToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :grid_view, :boolean, default: false
  end
end
