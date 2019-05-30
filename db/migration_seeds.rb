# Missing SO
service = Services::Shared::Migrations::MigrationsV2.new(%w(missing_bible_orders), folder: 'seed_files_3')
service.call

# SO totals mismatch
service = Services::Shared::Migrations::MigrationsV2.new(%w(sap_sales_order_totals_mismatch), folder: 'seed_files_3')
service.call

# is kit flag
service = Services::Shared::Migrations::MigrationsV2.new(%w(set_is_kit_flag_in_mismatch_file), folder: 'seed_files_3')
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

service = Services::Shared::Migrations::MigrationsV2.new(%w(complete_bible_orders_mismatch_with_dates), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(update_mismatching_non_kit_orders), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(update_vat_entries), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(create_bible_orders), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(check_bible_total), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(flex_dump), folder: 'seed_files_3')
service.call