class AddInquiryImportRefToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :inquiry_import, foreign_key: true
  end
end
