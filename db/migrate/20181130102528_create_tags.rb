class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :slug

      t.timestamps
      t.userstamps
    end
  end
end
