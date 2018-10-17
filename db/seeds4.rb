service = Services::Shared::Migrations::Migrations.new(%w(sales_order_drafts))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_order_items))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_invoices))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_shipments))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(purchase_orders))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_receipts))
service.call

