class AddUserstampToPaymentOption < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_options, :created_by_id, :integer, index: true
    add_column :payment_options, :updated_by_id, :integer, index: true

    add_foreign_key :payment_options, :overseers, column: 'created_by_id'
    add_foreign_key :payment_options, :overseers, column: 'updated_by_id'
  end
end
