class AddTcsApplicableToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :tcs_applicable, :boolean, default: true
  end
end
