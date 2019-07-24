class AddOutwardStatusToInwardDispatch < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_dispatches, :outward_status, :integer
  end
end
