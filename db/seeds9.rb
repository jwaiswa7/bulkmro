service = Services::Shared::Migrations::Migrations.new(%w(brand_remote_uids), folder: 'seed_files')
service.call