class ChangeColumnDatatypeIsp < ActiveRecord::Migration[5.2]
  def change
    change_column :inquiry_product_suppliers, :lead_time,'date USING CAST(lead_time AS date)'
  end
end
