class AddCreditNoteFlagToQuoteAndOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :sales_quotes, :is_credit_note_entry, :boolean, default: false

    add_column :sales_orders, :is_credit_note_entry, :boolean, default: false
  end
end
