class AddCallbackResponseToImageReader < ActiveRecord::Migration[5.2]
  def change
    add_column :image_readers, :callback_request, :jsonb
  end
end
