class AddNewFieldInContactCreation < ActiveRecord::Migration[5.2]
  def change
    add_column :contact_creation_requests, :designation, :string
  end
end
