service = Services::Shared::Migrations::Migrations.new(%w(target_reports), folder: 'seed_files')
service.call