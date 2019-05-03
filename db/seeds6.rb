service = Services::Shared::Migrations::Migrations.new(%w(sales_invoices sales_shipments purchase_orders), folder: 'seed_files')
service.call