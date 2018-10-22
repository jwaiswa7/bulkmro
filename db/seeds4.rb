service = Services::Shared::Migrations::Migrations.new(%w(sales_order_drafts))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_order_items))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_invoices))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_shipments))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(inquiry_attachments))
service.call

service = Services::Shared::Migrations::Migrations.new
service.perform_later

