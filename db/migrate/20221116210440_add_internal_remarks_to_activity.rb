class AddInternalRemarksToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :internal_remarks, :text
  end
end
