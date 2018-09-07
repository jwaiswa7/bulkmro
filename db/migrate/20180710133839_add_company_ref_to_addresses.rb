class AddCompanyRefToAddresses < ActiveRecord::Migration[5.2]
  def change
    add_reference :addresses, :company, foreign_key: true
  end
end
