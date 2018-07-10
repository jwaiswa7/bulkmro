class CreateCompanyPeople < ActiveRecord::Migration[5.2]
  def change
    create_table :company_people do |t|
      t.references :company, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
