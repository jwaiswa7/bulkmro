class CreateFreightRequestComments < ActiveRecord::Migration[5.2]
  def change
    create_table :freight_request_comments do |t|
      t.references :freight_request, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
