class AddContactRefToCarts < ActiveRecord::Migration[5.2]
  def change
    add_reference :carts, :contact, foreign_key: true
  end
end
