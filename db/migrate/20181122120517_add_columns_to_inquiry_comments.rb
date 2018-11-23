class AddColumnsToInquiryComments < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_comments, :show_to_customer, :boolean
    add_reference :inquiry_comments, :contact, foreign_key: true
  end
end
