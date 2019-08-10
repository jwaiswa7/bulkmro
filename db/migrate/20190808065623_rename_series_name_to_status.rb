class RenameSeriesNameToStatus < ActiveRecord::Migration[5.2]
  def change
    rename_column :bible_file_uploads, :series_name, :status
  end
end
