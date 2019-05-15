class AddCcrColumnToContact < ActiveRecord::Migration[5.2]
  def change
    add_column :contacts, :contact_creation_request_id, :integer
  end
end
