class CreateCompanySoTotalAmounts < ActiveRecord::Migration[5.2]
  def change
    create_table :company_so_total_amounts do |t|
      t.references :company, foreign_key: true
      t.string :financial_year, default: Company.current_financial_year
      t.decimal :so_total_amount, default: 0.0
      t.datetime :amount_reached_to_date

      t.index [:company_id, :financial_year], unique: true
    end
  end
end
