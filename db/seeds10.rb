service = Services::Shared::Migrations::Migrations.new(%w(product_images), folder: 'seed_files')
service.call