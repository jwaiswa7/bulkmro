class AddColumnUserstampToExports < ActiveRecord::Migration[5.2]
  def change
    add_column :exports, :created_by_id, :integer, index: true
    add_column :exports, :updated_by_id, :integer, index: true
    add_column :exports, :filtered, :boolean, default: false

    add_foreign_key :exports, :overseers, column: 'created_by_id'
    add_foreign_key :exports, :overseers, column: 'updated_by_id'
  end
end
