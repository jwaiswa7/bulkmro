class ChangePayloadToText < ActiveRecord::Migration[5.2]
  def self.up
    change_column :api_requests, :payload, :text
  end

  def self.down
    change_column :api_requests, :payload, :string
  end
end
