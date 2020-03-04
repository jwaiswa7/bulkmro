class AddColumnSeriesCodeSupplierRfqs < ActiveRecord::Migration[5.2]
  def change
    add_column :supplier_rfqs, :rfq_number, :integer
  end
end
