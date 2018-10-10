class AddQuotationUidToInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :quotation_uid, :integer, index: { unique: true }
    remove_column :sales_quotes, :quotation_uid, :integer, index: { unique: true }
  end
end
