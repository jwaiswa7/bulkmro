class AddStockRelatedFieldsToPoRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :po_requests, :po_request_type, :integer unless column_exists? :po_requests, :po_request_type
    add_column :po_requests, :reason_to_stock, :string unless column_exists? :po_requests, :reason_to_stock
    add_column :po_requests, :stock_status, :integer unless column_exists? :po_requests, :stock_status
    add_column :po_requests, :estimated_date_to_unstock, :date unless column_exists? :po_requests, :estimated_date_to_unstock
    add_reference :po_requests, :company, foreign_key: true unless column_exists? :po_requests, :company_id

    add_column :po_requests, :requested_by_id, :integer, index: true unless column_exists? :po_requests, :requested_by_id
    add_column :po_requests, :approved_by_id, :integer, index: true unless column_exists? :po_requests, :approved_by_id

    add_foreign_key :po_requests, :overseers, column: :requested_by_id unless column_exists? :po_requests, :requested_by_id
    add_foreign_key :po_requests, :overseers, column: :approved_by_id unless column_exists? :po_requests, :approved_by_id
  end
end
