class AddInstructionsFieldToCart < ActiveRecord::Migration[5.2]
  def change
    add_column :carts, :special_instructions, :text, default: nil
  end
end
