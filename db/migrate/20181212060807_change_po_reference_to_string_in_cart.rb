class ChangePoReferenceToStringInCart < ActiveRecord::Migration[5.2]
  def change
    change_column :carts, :po_reference, :string
  end
end
