class AddLegacyFieldToPoRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :is_legacy, :boolean, default: false
  end
end
