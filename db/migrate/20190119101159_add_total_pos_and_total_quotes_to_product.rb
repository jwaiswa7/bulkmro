class AddTotalPosAndTotalQuotesToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :total_pos, :integer, default: 0
    add_column :products, :total_quotes, :integer, default: 0
  end
end
