class AddSupplierCommittedDateToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :supplier_committed_date, :date
  end
end
