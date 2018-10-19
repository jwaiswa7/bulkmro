service = Services::Shared::Migrations::Migrations.new(%w(accounts contacts companies_acting_as_customers company_contacts addresses companies_acting_as_suppliers supplier_addresses products inquiries inquiry_terms inquiry_details sales_order_drafts sales_order_items activities inquiry_attachments product_categories), folder: 'seed_files_2')
service.call

