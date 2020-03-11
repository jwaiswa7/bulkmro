class AddInquiryIdsToSupplierProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :supplier_products, :inquiry_ids, :jsonb, array: true, default: []
  end
end
