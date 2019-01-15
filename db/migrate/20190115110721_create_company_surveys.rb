class CreateCompanySurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :company_surveys do |t|
      t.integer :survey_type
      t.integer :rating
      t.references :po_request, foreign_key: true
      t.references :invoice_request, foreign_key: true
      t.references :overseer, foreign_key: true
      t.references :company, foreign_key: true
      t.timestamps
    end
  end
end
