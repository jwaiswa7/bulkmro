class AddPasswordToOverseer < ActiveRecord::Migration[5.2]
  def change
    add_column :overseers, :changed_by, :string
    add_column :overseers, :changed_at, :datetime
  end
end
