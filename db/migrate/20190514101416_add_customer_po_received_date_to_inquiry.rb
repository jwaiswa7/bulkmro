class AddCustomerPoReceivedDateToInquiry < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :customer_po_received_date, :date
  end
end
