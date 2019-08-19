class CreateBibleUploadLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :bible_upload_logs do |t|
      t.references :bible_upload, foreign_key: true
      t.string :sr_no
      t.boolean :status
      t.jsonb :bible_row_data
      t.string :error
    end
  end
end
