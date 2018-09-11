class CreateInquiries < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiries do |t|
      t.references :contact, foreign_key: true
      t.references :company, foreign_key: true

      t.string :project_uid, index: { unique: true }
      t.string :quotation_uid, index: { unique: true }
      t.string :opportunity_uid, index: { unique: true }


      t.integer :billing_address_id, index: true
      t.integer :shipping_address_id, index: true

      t.text :comments

      t.timestamps
      t.userstamps
    end
  end
end
