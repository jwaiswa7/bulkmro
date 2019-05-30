class AddCreditNoteFlagToQuoteAndOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :is_credit_note_entry, :boolean, default: false
    add_column :sales_quotes, :metadata, :json, default: nil

    add_column :sales_orders, :is_credit_note_entry, :boolean, default: false
    add_column :sales_orders, :metadata, :json, default: nil
  end
end
