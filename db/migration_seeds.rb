# Missing SO
service = Services::Shared::Migrations::MigrationsV2.new(%w(missing_sap_orders), folder: 'seed_files_3')
service.call

# SO totals mismatch
service = Services::Shared::Migrations::MigrationsV2.new(%w(sap_sales_order_totals_mismatch), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(bible_sales_order_totals_mismatch), folder: 'seed_files_3')
service.call

# Missing SI
service = Services::Shared::Migrations::MigrationsV2.new(%w(missing_sap_invoices), folder: 'seed_files_3')
service.call

# SI totals mismatch
service = Services::Shared::Migrations::MigrationsV2.new(%w(sap_sales_invoice_totals_mismatch), folder: 'seed_files_3')
service.call

# missing POs
service = Services::Shared::Migrations::MigrationsV2.new(%w(missing_sap_purchase_orders), folder: 'seed_files_3')
service.call

# PO totals mismatch
service = Services::Shared::Migrations::MigrationsV2.new(%w(purchase_order_totals_mismatch), folder: 'seed_files_3')
service.call