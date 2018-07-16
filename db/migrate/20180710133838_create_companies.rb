class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :account, foreign_key: true
      t.integer :default_payment_option_id, index: true
      t.string :name

      t.timestamps
    end
    add_foreign_key :companies, :payment_options, column: :default_payment_option_id
  end
end
