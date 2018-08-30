class AddInquiryImportRowRefToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :inquiry_import_row, foreign_key: true
  end
end
