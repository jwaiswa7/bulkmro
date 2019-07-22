class AddMigrationForPoRequestRow < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_order_rows,:po_request_row, foreign_key: true
  end
end
