class AddArStatusToInwardDispatches < ActiveRecord::Migration[5.2]
  def change
    add_column :inward_dispatches, :ar_invoice_request_status, :integer
  end
end
