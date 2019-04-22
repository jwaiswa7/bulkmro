class AddParentIdToInquiryStatusRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_status_records, :parent_id, :integer, foreign_key: true
  end
end
