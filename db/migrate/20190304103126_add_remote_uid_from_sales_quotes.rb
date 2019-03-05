class AddRemoteUidFromSalesQuotes < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :remote_uid, :integer, index: { unique: true }
  end
end
