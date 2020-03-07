class AddColumnSupplierRfqInquiryProductSupplier < ActiveRecord::Migration[5.2]
  def change
    add_reference :inquiry_product_suppliers,:supplier_rfq, foreign_key: true unless column_exists? :inquiry_product_suppliers,:supplier_rfq_id
  end
end
