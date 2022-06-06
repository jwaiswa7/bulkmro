class AddCancellationMessageToInquiryComments < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiry_comments, :cancellation_message, :text
  end
end
