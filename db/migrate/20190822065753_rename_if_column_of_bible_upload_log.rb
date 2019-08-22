class RenameIfColumnOfBibleUploadLog < ActiveRecord::Migration[5.2]
  def change
    rename_column :bible_upload_logs, :bible_file_upload_id, :bible_upload_id if ActiveRecord::Base.connection.column_exists?(:bible_upload_logs, :bible_file_upload_id)
  end
end
