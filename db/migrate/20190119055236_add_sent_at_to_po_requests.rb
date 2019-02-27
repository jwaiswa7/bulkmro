class AddSentAtToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :sent_at, :datetime
  end
end
