service = Services::Shared::Migrations::Migrations.new(%w(sales_shipments))
service.call
