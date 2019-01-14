class AddInternalStatusToPo < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :internal_status, :integer
  end
end
