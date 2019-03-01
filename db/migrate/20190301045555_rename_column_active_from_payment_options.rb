class RenameColumnActiveFromPaymentOptions < ActiveRecord::Migration[5.2]
  def change
    rename_column :payment_options, :active, :is_active
    change_column :payment_options, :is_active, :boolean, default: true
  end
end
