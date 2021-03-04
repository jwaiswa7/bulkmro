class AddMetadataToSalesQuote < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :metadata, :jsonb
  end
end
