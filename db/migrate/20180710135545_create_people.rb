class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.references :account, foreign_key: true
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
