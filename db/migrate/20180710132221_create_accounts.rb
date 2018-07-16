class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :name, index: { :unique => true }

      t.timestamps
    end
  end
end
