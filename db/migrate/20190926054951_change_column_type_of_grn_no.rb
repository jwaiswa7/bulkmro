class ChangeColumnTypeOfGrnNo < ActiveRecord::Migration[5.2]
  def change
    change_column :pod_rows, :grn_no, :bigint
  end
end
