service = Services::Shared::Migrations::Migrations.new(%w(sales_order_drafts sales_order_items), folder: 'seed_files_2')
service.call




