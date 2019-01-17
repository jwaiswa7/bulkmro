service = Services::Shared::Migrations::Migrations.new(%w(generate_review_questions), folder: 'seed_files')
service.call