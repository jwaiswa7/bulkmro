class CreateEmailMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :email_messages do |t|
      t.references :overseer, foreign_key: true
      t.references :contact, foreign_key: true

      t.references :inquiry, foreign_key: true
      t.references :sales_quote, foreign_key: true

      t.string :from
      t.string :to
      t.string :subject
      t.text :body

      t.jsonb :metadata

      t.timestamps
    end
  end
end
