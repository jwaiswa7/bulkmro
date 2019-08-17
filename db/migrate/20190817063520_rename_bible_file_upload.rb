class RenameBibleFileUpload < ActiveRecord::Migration[5.2]
  def change
    rename_table :bible_file_uploads, :bible_uploads
  end
end