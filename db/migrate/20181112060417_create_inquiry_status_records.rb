class CreateInquiryStatusRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :inquiry_status_records do |t|
      t.integer :status
      t.integer :remote_uid

      t.references :inquiry, foreign_key: true
      t.references :subject, polymorphic: true

      t.timestamps
    end
  end
end
