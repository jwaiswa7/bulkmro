service = Services::Shared::Migrations::Migrations.new(%w(generate_review_questions), folder: 'seed_files')
service.call

# For Inward Queue

Services::Shared::Snippets.new.add_logistics_owner_to_all_po
service = Services::Shared::Migrations::Migrations.new(%w(update_created_po_requests_with_no_po_order  update_existing_po_requests_with_purchase_order create_po_request_for_purchase_orders ), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(add_logistics_owner_to_companies update_payment_requests_statuses add_logistics_owner_to_companies update_purchase_order_material_status sup_emails ), folder: 'seed_files')
service.call


# End For Inward Queue

service = Services::Shared::Migrations::Migrations.new(%w(add_completed_po_to_material_followup_queue), folder: 'seed_files')
service.call


# To add missing payment options
service = Services::Shared::Migrations::Migrations.new(%w(missing_payment_options), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(missing_sales_order_products), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::Migrations.new(%w(update_magento_po_order ), folder: 'seed_files')
service.call
service = Services::Shared::Migrations::Migrations.new(%w( update_purchase_orders), folder: 'seed_files')
service.call

#update logistics owner for all companies
service = Services::Shared::Migrations::Migrations.new(%w(update_logistics_owner_for_list_of_companies), folder: 'seed_files')
service.call

#update logistics owner for all pos and its inward dispatches
service = Services::Shared::Migrations::Migrations.new(%w(update_owner_for_pos_and_inward_dispatches), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::CreateNewProductsWithCustomerProducts.new(%w(products_creation_customer_products), folder: 'seed_files')
service.call
