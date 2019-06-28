# SO totals mismatch --> sap_sales_order_totals_mismatch
#
# Missing SI --> missing_sap_invoices
#
# SI totals mismatch --> sap_sales_invoice_totals_mismatch
#
# missing POs --> missing_sap_purchase_orders
#
# PO totals mismatch --> purchase_order_totals_mismatch
#
# Create Bible orders --> create_bible_orders
#
# Check bible total --> check_bible_total
#
# flex/companies dump --> flex_dump

service = Services::Shared::Migrations::CreditNoteEntries.new(%w(create_credit_note_entries), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(complete_mismatch_sheet), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(update_non_kit_non_ae_except_zero_tsp), folder: 'seed_files_3')
service.call

service = Services::Shared::Migrations::AddTaxTypeInSalesOrderRow.new(%w(add_tax_type_in_sales_order_row), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::MultipleSalesQuotesWithSameProduct.new(%w(merge_sales_quote_duplicate_product_rows), folder: 'seed_files')
service.call

service = Services::Shared::Migrations::MigrationsV2.new(%w(oct_to_march_mismatch), folder: 'seed_files')
service.call