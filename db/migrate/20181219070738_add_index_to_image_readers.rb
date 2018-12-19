class AddIndexToImageReaders < ActiveRecord::Migration[5.2]
  def change
    add_index :image_readers, :status
    add_index :image_readers, :created_at
  end
end
