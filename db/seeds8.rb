service = Services::Shared::Migrations::Migrations.new(%w(update_sales_orders_for_legacy_inquiries))
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sales_invoice_callback_data))
service.call