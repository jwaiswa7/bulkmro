class AddPurposeForOthers < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :purpose_for_others , :string
  end
end
