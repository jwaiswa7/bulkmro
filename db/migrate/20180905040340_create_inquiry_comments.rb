class CreateInquiryComments < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_comments do |t|
      t.references :inquiry, foreign_key: true
      t.references :sales_order, foreign_key: true
      t.text :message

      t.userstamps
      t.timestamps
    end
  end
end
