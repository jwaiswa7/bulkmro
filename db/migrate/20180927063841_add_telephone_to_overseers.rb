class AddTelephoneToOverseers < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :telephone, :string
  end
end
