class AddColumnLastSyncedQuoteToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :last_synced_quote_id, :integer
  end
end
