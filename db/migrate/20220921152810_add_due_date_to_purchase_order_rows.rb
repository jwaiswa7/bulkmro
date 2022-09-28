class AddDueDateToPurchaseOrderRows < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_rows, :due_date, :date    
  end
end
