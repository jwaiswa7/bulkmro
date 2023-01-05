class CreateRevisionRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :revision_requests do |t|
      t.string :reason
      t.text :required_changes
      t.references :sales_quote, foreign_key: true
      t.references :contact, foreign_key: true

      t.timestamps
    end
  end
end
