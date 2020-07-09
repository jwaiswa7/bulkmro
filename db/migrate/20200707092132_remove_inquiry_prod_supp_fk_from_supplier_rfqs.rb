class RemoveInquiryProdSuppFkFromSupplierRfqs < ActiveRecord::Migration[5.2]
  def change
    if foreign_key_exists?(:supplier_rfqs, :inquiry_product_suppliers)
      remove_foreign_key :supplier_rfqs, :inquiry_product_suppliers
    end
  end
end
