class CreateMaterialDispatches < ActiveRecord::Migration[5.2]
  def change
    create_table :material_dispatches do |t|
      t.integer :status
      t.belongs_to :ar_invoice_request
      t.belongs_to :sales_order


      t.timestamps
      t.userstamps

    end
  end
end
