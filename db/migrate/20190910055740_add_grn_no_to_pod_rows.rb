class AddGrnNoToPodRows < ActiveRecord::Migration[5.2]
  def change
    add_column :pod_rows, :grn_no, :integer
  end
end
