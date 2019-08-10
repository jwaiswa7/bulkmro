class CreateBibleFileUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :bible_file_uploads do |t|
      t.string :file_name
      t.userstamps
      t.string :series_name
      t.timestamps
    end
  end
end
