class AddStockRelatedFieldsToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :po_request_type, :integer
    add_column :po_requests, :reason_to_stock, :string
    add_column :po_requests, :stock_status, :integer
    add_column :po_requests, :estimated_date_to_unstock, :date
    add_reference :po_requests, :company, foreign_key: true

    add_column :po_requests, :requested_by_id, :integer, index: true
    add_column :po_requests, :approved_by_id, :integer, index: true

    add_foreign_key :po_requests, :overseers, column: :requested_by_id
    add_foreign_key :po_requests, :overseers, column: :approved_by_id
  end
end
