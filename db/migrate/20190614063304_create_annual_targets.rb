class CreateAnnualTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :annual_targets do |t|
      t.references :overseer, foreign_key: true, index: true
      t.integer :manager_id, index: true
      t.integer :business_head_id, index: true
      t.string :year
      t.decimal :inquiry_target, default: 0
      t.decimal :invoice_target, default: 0
      t.decimal :company_target, default: 0
      t.decimal :invoice_margin_target, default: 0
      t.decimal :order_target, default: 0
      t.decimal :order_margin_target, default: 0
      t.decimal :new_client_target, default: 0

      t.timestamps
      t.userstamps
    end

    add_foreign_key :annual_targets, :overseers, column: :manager_id
    add_foreign_key :annual_targets, :overseers, column: :business_head_id
  end
end
