class AddIfscToBanks < ActiveRecord::Migration[5.2]
  def change
    add_column :banks, :ifsc_code, :string
  end
end
