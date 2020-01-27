class AddDateAttachmentColumnsInquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :inquiries, :customer_po_delivery_date, :date
    add_column :inquiries, :customer_po_received_attachment, :string
    add_column :inquiries, :customer_po_delivery_attachment, :string
    add_column :inquiries, :committed_delivery_attachment, :string
  end
end
