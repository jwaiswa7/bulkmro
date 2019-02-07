service = Services::Shared::Migrations::Migrations.new(%w(product_images), folder: 'seed_files')
service.call


service = Services::Shared::Migrations::Migrations.new(%w(update_products_description), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(purchase_order_callback_data), folder: 'seed_files')
service.call
# service = Services::Shared::Migrations::Migrations.new(%w(generate_customer_products_from_existing_products), folder: 'seed_files')

service = Services::Shared::Migrations::Migrations.new(%w(add_products_and_customer_products_to_company), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(update_inquiries_status), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(missing_inquiries), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(missing_bible_sales_orders), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(bible_sales_orders_totals_mismatch), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(missing_sap_orders), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sap_sales_orders_totals_mismatch), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(missing_sap_invoices), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(sap_sales_invoices_totals_mismatch), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(update_images_for_reliance_products), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_company_banks), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_banks), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_missing_orders), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_image_readers), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(update_invoice_statuses update_cancelled_po_statuses update_po_status), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(update_created_po_requests_with_no_po_order update_existing_po_requests_with_purchase_order create_po_request_for_purchase_orders))
service.call