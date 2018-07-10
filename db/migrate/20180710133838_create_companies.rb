class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.references :account, foreign_key: true
      t.references :default_payment_term, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
