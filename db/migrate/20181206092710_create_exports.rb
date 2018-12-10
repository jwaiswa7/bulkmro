class CreateExports < ActiveRecord::Migration[5.2]
  def change
    create_table :exports do |t|
      t.integer :export_type
      t.timestamps
    end
  end
end
