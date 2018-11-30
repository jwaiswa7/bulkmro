service = Services::Shared::Migrations::Migrations.new(%w(product_images), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(purchase_order_callback_data), folder: 'seed_files')
service.call