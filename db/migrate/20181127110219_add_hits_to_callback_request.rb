class AddHitsToCallbackRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :callback_requests, :hits, :decimal
  end
end
