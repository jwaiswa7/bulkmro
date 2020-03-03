class AddSupplierQuoteSubmittedToSupplierRfq < ActiveRecord::Migration[5.2]
  def change
  	add_column :supplier_rfqs, :supplier_quote_submitted, :boolean, default: false
  end
end
