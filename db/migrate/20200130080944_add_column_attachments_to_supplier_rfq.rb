class AddColumnAttachmentsToSupplierRfq < ActiveRecord::Migration[5.2]
  def change
    add_column :supplier_rfqs, :attachments, :string
  end
end
