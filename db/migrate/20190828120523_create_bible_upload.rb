class CreateBibleUpload < ActiveRecord::Migration[5.2]
  def change
    create_table :bible_uploads do |t|
      t.string :file
      t.integer :import_type
      t.userstamps
      t.integer :status
      t.timestamps
    end
  end
end
