class AddCreatedByToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :created_by, :string
  end
end
