class CreateWarehouses < ActiveRecord::Migration[5.2]
  def change
    create_table :warehouses do |t|
      t.string :name
      t.references :address, foreign_key: true
      t.string :code
      t.boolean :is_hidden
      t.string :location
      t.string :remote_uid
      t.string :remote_branch_code
      t.string :remote_branch_name

      t.timestamps
    end
  end
end
