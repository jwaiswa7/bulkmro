service = Services::Shared::Migrations::Migrations.new(%w(product_images), folder: 'seed_files')
service.call


service = Services::Shared::Migrations::Migrations.new(%w(update_products_description), folder: 'seed_files')
service.call
