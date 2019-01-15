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

service = Services::Shared::Migrations::Migrations.new(%w(update_images_for_reliance_products), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_company_banks), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(create_banks), folder: 'seed_files')
service.call