class AddColumnPreviousRecordToInquiryStatusRecord < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_status_records, :previous_status_record_id, :integer, foreign_key: true
  end
end
