class AddMetadataToCreditNote < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :metadata, :jsonb
  end
end
