class AddOfflineCheckToInquiry < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :is_inquiry_offline, :boolean
  end
end
