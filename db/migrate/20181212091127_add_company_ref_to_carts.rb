class AddCompanyRefToCarts < ActiveRecord::Migration[5.2]
  def change
    add_reference :carts, :company, foreign_key: true
  end
end
