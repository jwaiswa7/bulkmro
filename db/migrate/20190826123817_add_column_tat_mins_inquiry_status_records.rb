class AddColumnTatMinsInquiryStatusRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_status_records, :tat_minutes, :integer
  end
end
