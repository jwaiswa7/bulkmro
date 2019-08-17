class RenameTypeColumnToBibleUpload < ActiveRecord::Migration[5.2]
  def change
    rename_column :bible_uploads, :type, :sheet_type
  end
end
