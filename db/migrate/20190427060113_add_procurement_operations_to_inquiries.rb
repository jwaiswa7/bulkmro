class AddProcurementOperationsToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :procurement_operations_id, :integer, index: true

    add_foreign_key :inquiries, :overseers, column: :procurement_operations_id
  end
end
