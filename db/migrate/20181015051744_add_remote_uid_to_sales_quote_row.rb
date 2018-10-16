class AddRemoteUidToSalesQuoteRow < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quote_rows, :remote_uid, :integer, index: true
  end
end
