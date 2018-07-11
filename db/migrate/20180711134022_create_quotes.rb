class CreateQuotes < ActiveRecord::Migration[5.2]
  def change
    create_table :quotes do |t|
      t.references :inquiry, foreign_key: true

      t.timestamps
    end
  end
end
