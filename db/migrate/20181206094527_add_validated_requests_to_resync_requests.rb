class AddValidatedRequestsToResyncRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :resync_requests, :validated_requests, :text,  array: true, default: []
  end
end
