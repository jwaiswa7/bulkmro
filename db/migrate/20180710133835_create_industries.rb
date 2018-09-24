class CreateIndustries < ActiveRecord::Migration[5.2]
  def change
    create_table :industries do |t|
      t.integer :remote_uid, index: { unique: true }

      t.string :name, index: { unique: true }
      t.text :description
      t.integer :legacy_id, index:true, required: true

      t.timestamps
    end
  end
end
