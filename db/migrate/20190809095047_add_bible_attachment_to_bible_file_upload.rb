class AddBibleAttachmentToBibleFileUpload < ActiveRecord::Migration[5.2]
  def change
    add_column :bible_file_uploads, :bible_attachment, :string
  end
end
