class AddResyncResponseInResyncRemoteRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :resync_remote_requests, :resync_request, :jsonb
    add_column :resync_remote_requests, :resync_response,:jsonb
    add_column :resync_remote_requests, :resync_url,:text
  end
end
