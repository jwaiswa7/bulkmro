class Services::Shared::Migrations::SetPoRequestStatus < Services::Shared::Migrations::Migrations
  def call
    PoRequest.where(purchase_order: PurchaseOrder.supplier_email_sent, status: 'Supplier PO: Created Not Sent').update_all(status: 'Supplier PO Sent')
  end
end
