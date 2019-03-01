class AddColumnActiveToPaymentOptions < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_options, :active, :boolean
  end
end
