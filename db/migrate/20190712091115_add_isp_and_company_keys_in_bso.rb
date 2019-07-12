class AddIspAndCompanyKeysInBso < ActiveRecord::Migration[5.2]
  def change
    add_reference :bible_sales_orders, :company, foreign_key: true
    add_reference :bible_sales_orders, :account, foreign_key: true
    add_reference :bible_sales_orders, :sales_order, foreign_key: true
    add_reference :bible_sales_orders, :sales_invoice, foreign_key: true
    add_column :bible_sales_orders, :inside_sales_owner_id, :integer
    add_column :bible_sales_orders, :outside_sales_owner_id, :integer

    add_foreign_key :bible_sales_orders, :overseers, column: :outside_sales_owner_id
    add_foreign_key :bible_sales_orders, :overseers, column: :inside_sales_owner_id

    remove_column :bible_sales_orders, :company_name
    remove_column :bible_sales_orders, :account_name
    remove_column :bible_sales_orders, :inside_sales_owner
  end
end
