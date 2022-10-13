class AddActivityNumberInActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :activity_number , :string
  end
end
