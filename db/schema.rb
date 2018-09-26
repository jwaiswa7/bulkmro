# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_09_26_094907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.integer "remote_uid"
    t.integer "legacy_id"
    t.string "name"
    t.string "alias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_accounts_on_created_by_id"
    t.index ["legacy_id"], name: "index_accounts_on_legacy_id"
    t.index ["name"], name: "index_accounts_on_name", unique: true
    t.index ["remote_uid"], name: "index_accounts_on_remote_uid"
    t.index ["updated_by_id"], name: "index_accounts_on_updated_by_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "address_states", force: :cascade do |t|
    t.integer "legacy_id"
    t.integer "remote_uid"
    t.string "region_code_uid"
    t.string "name"
    t.string "country_code"
    t.string "region_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_address_states_on_legacy_id"
    t.index ["name"], name: "index_address_states_on_name", unique: true
    t.index ["region_code_uid"], name: "index_address_states_on_region_code_uid"
    t.index ["remote_uid"], name: "index_address_states_on_remote_uid", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "address_state_id"
    t.bigint "company_id"
    t.integer "legacy_id"
    t.integer "billing_address_uid"
    t.integer "shipping_address_uid"
    t.string "country_code"
    t.string "name"
    t.string "state_name"
    t.string "city_name"
    t.string "pincode"
    t.string "street1"
    t.string "street2"
    t.string "gst"
    t.string "cst"
    t.string "vat"
    t.string "tan"
    t.string "excise"
    t.string "telephone"
    t.string "mobile"
    t.integer "gst_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["address_state_id"], name: "index_addresses_on_address_state_id"
    t.index ["billing_address_uid"], name: "index_addresses_on_billing_address_uid"
    t.index ["company_id"], name: "index_addresses_on_company_id"
    t.index ["created_by_id"], name: "index_addresses_on_created_by_id"
    t.index ["legacy_id"], name: "index_addresses_on_legacy_id"
    t.index ["shipping_address_uid"], name: "index_addresses_on_shipping_address_uid"
    t.index ["updated_by_id"], name: "index_addresses_on_updated_by_id"
  end

  create_table "brand_suppliers", force: :cascade do |t|
    t.bigint "brand_id"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["brand_id"], name: "index_brand_suppliers_on_brand_id"
    t.index ["created_by_id"], name: "index_brand_suppliers_on_created_by_id"
    t.index ["supplier_id", "brand_id"], name: "index_brand_suppliers_on_supplier_id_and_brand_id", unique: true
    t.index ["supplier_id"], name: "index_brand_suppliers_on_supplier_id"
    t.index ["updated_by_id"], name: "index_brand_suppliers_on_updated_by_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.integer "legacy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_brands_on_created_by_id"
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.index ["updated_by_id"], name: "index_brands_on_updated_by_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "tax_code_id"
    t.integer "legacy_id"
    t.integer "parent_id"
    t.integer "remote_uid"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_categories_on_created_by_id"
    t.index ["legacy_id"], name: "index_categories_on_legacy_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["remote_uid"], name: "index_categories_on_remote_uid"
    t.index ["tax_code_id"], name: "index_categories_on_tax_code_id"
    t.index ["updated_by_id"], name: "index_categories_on_updated_by_id"
  end

  create_table "category_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "category_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "category_desc_idx"
  end

  create_table "category_suppliers", force: :cascade do |t|
    t.bigint "category_id"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["category_id"], name: "index_category_suppliers_on_category_id"
    t.index ["created_by_id"], name: "index_category_suppliers_on_created_by_id"
    t.index ["supplier_id", "category_id"], name: "index_category_suppliers_on_supplier_id_and_category_id", unique: true
    t.index ["supplier_id"], name: "index_category_suppliers_on_supplier_id"
    t.index ["updated_by_id"], name: "index_category_suppliers_on_updated_by_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.string "to"
    t.string "from"
    t.text "message"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "industry_id"
    t.string "remote_uid"
    t.integer "legacy_id"
    t.integer "attachment_uid"
    t.integer "default_company_contact_id"
    t.integer "default_payment_option_id"
    t.integer "default_billing_address_id"
    t.integer "default_shipping_address_id"
    t.integer "inside_sales_owner_id"
    t.integer "outside_sales_owner_id"
    t.integer "sales_manager_id"
    t.string "name"
    t.string "site"
    t.string "phone"
    t.string "mobile"
    t.integer "company_type"
    t.integer "priority"
    t.integer "nature_of_business"
    t.decimal "credit_limit"
    t.boolean "is_msme", default: false
    t.boolean "is_unregistered_dealer", default: false
    t.boolean "is_supplier", default: false
    t.boolean "is_customer", default: true
    t.string "tax_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "pan"
    t.string "tan"
    t.index ["account_id"], name: "index_companies_on_account_id"
    t.index ["attachment_uid"], name: "index_companies_on_attachment_uid"
    t.index ["created_by_id"], name: "index_companies_on_created_by_id"
    t.index ["default_billing_address_id"], name: "index_companies_on_default_billing_address_id"
    t.index ["default_company_contact_id"], name: "index_companies_on_default_company_contact_id"
    t.index ["default_payment_option_id"], name: "index_companies_on_default_payment_option_id"
    t.index ["default_shipping_address_id"], name: "index_companies_on_default_shipping_address_id"
    t.index ["industry_id"], name: "index_companies_on_industry_id"
    t.index ["inside_sales_owner_id"], name: "index_companies_on_inside_sales_owner_id"
    t.index ["legacy_id"], name: "index_companies_on_legacy_id"
    t.index ["name"], name: "index_companies_on_name"
    t.index ["outside_sales_owner_id"], name: "index_companies_on_outside_sales_owner_id"
    t.index ["remote_uid"], name: "index_companies_on_remote_uid", unique: true
    t.index ["sales_manager_id"], name: "index_companies_on_sales_manager_id"
    t.index ["tax_identifier"], name: "index_companies_on_tax_identifier", unique: true
    t.index ["updated_by_id"], name: "index_companies_on_updated_by_id"
  end

  create_table "company_banks", force: :cascade do |t|
    t.bigint "company_id"
    t.string "country_code"
    t.string "account_number"
    t.string "ifsc"
    t.string "street_address"
    t.string "email"
    t.string "phone"
    t.string "swift"
    t.string "routing_number"
    t.string "iban"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_company_banks_on_account_number", unique: true
    t.index ["company_id"], name: "index_company_banks_on_company_id"
  end

  create_table "company_contacts", force: :cascade do |t|
    t.bigint "contact_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["company_id", "contact_id"], name: "index_company_contacts_on_company_id_and_contact_id", unique: true
    t.index ["company_id"], name: "index_company_contacts_on_company_id"
    t.index ["contact_id"], name: "index_company_contacts_on_contact_id"
    t.index ["created_by_id"], name: "index_company_contacts_on_created_by_id"
    t.index ["updated_by_id"], name: "index_company_contacts_on_updated_by_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "remote_uid"
    t.integer "legacy_id"
    t.string "first_name"
    t.string "last_name"
    t.string "prefix"
    t.string "designation"
    t.string "telephone"
    t.string "mobile"
    t.integer "role"
    t.integer "status"
    t.integer "contact_group"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["contact_group"], name: "index_contacts_on_contact_group"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["email"], name: "index_contacts_on_email", unique: true
    t.index ["legacy_id"], name: "index_contacts_on_legacy_id"
    t.index ["remote_uid"], name: "index_contacts_on_remote_uid", unique: true
    t.index ["reset_password_token"], name: "index_contacts_on_reset_password_token", unique: true
    t.index ["role"], name: "index_contacts_on_role"
    t.index ["status"], name: "index_contacts_on_status"
    t.index ["unlock_token"], name: "index_contacts_on_unlock_token", unique: true
    t.index ["updated_by_id"], name: "index_contacts_on_updated_by_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.integer "legacy_id"
    t.string "name"
    t.decimal "conversion_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_currencies_on_legacy_id"
  end

  create_table "industries", force: :cascade do |t|
    t.integer "remote_uid"
    t.integer "legacy_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_industries_on_legacy_id"
    t.index ["name"], name: "index_industries_on_name", unique: true
    t.index ["remote_uid"], name: "index_industries_on_remote_uid", unique: true
  end

  create_table "inquiries", force: :cascade do |t|
    t.bigint "contact_id"
    t.bigint "company_id"
    t.bigint "payment_option_id"
    t.bigint "inquiry_currency_id"
    t.integer "legacy_id"
    t.string "project_uid"
    t.string "inquiry_number"
    t.string "opportunity_uid"
    t.string "subject"
    t.string "customer_po_number"
    t.string "customer_po_sheet"
    t.string "calculation_sheet"
    t.string "email_attachment"
    t.string "supplier_quote_attachment"
    t.string "supplier_quote_attachment_additional"
    t.integer "shipping_company_id"
    t.integer "bill_from_warehouse"
    t.integer "ship_from_warehouse"
    t.integer "bill_to_name"
    t.integer "billing_address_id"
    t.integer "shipping_address_id"
    t.integer "inside_sales_owner_id"
    t.integer "outside_sales_owner_id"
    t.integer "sales_manager_id"
    t.integer "opportunity_source"
    t.integer "opportunity_type"
    t.integer "status"
    t.integer "stage"
    t.integer "freight_option"
    t.integer "packing_and_forwarding_option"
    t.integer "quote_category"
    t.integer "price_type"
    t.integer "attachment_uid"
    t.decimal "potential_amount", default: "0.0"
    t.decimal "gross_profit_percentage", default: "0.0"
    t.decimal "weight_in_kgs", default: "0.0"
    t.decimal "priority", default: "0.0"
    t.date "expected_closing_date"
    t.date "quotation_date"
    t.date "quotation_expected_date"
    t.date "valid_end_time"
    t.date "quotation_followup_date"
    t.date "customer_order_date"
    t.date "customer_committed_date"
    t.date "procurement_date"
    t.text "commercial_terms_and_conditions"
    t.boolean "is_sez", default: false
    t.boolean "is_kit", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["billing_address_id"], name: "index_inquiries_on_billing_address_id"
    t.index ["company_id"], name: "index_inquiries_on_company_id"
    t.index ["contact_id"], name: "index_inquiries_on_contact_id"
    t.index ["created_by_id"], name: "index_inquiries_on_created_by_id"
    t.index ["inquiry_currency_id"], name: "index_inquiries_on_inquiry_currency_id", unique: true
    t.index ["inquiry_number"], name: "index_inquiries_on_inquiry_number", unique: true
    t.index ["inside_sales_owner_id"], name: "index_inquiries_on_inside_sales_owner_id"
    t.index ["legacy_id"], name: "index_inquiries_on_legacy_id"
    t.index ["opportunity_uid"], name: "index_inquiries_on_opportunity_uid", unique: true
    t.index ["outside_sales_owner_id"], name: "index_inquiries_on_outside_sales_owner_id"
    t.index ["payment_option_id"], name: "index_inquiries_on_payment_option_id"
    t.index ["project_uid"], name: "index_inquiries_on_project_uid", unique: true
    t.index ["sales_manager_id"], name: "index_inquiries_on_sales_manager_id"
    t.index ["shipping_address_id"], name: "index_inquiries_on_shipping_address_id"
    t.index ["updated_by_id"], name: "index_inquiries_on_updated_by_id"
  end

  create_table "inquiry_comments", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.bigint "sales_order_id"
    t.text "message"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_inquiry_comments_on_created_by_id"
    t.index ["inquiry_id"], name: "index_inquiry_comments_on_inquiry_id"
    t.index ["sales_order_id"], name: "index_inquiry_comments_on_sales_order_id"
    t.index ["updated_by_id"], name: "index_inquiry_comments_on_updated_by_id"
  end

  create_table "inquiry_currencies", force: :cascade do |t|
    t.bigint "currency_id"
    t.decimal "conversion_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_inquiry_currencies_on_currency_id"
  end

  create_table "inquiry_import_rows", force: :cascade do |t|
    t.bigint "inquiry_import_id"
    t.bigint "inquiry_product_id"
    t.string "sku"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inquiry_import_id"], name: "index_inquiry_import_rows_on_inquiry_import_id"
    t.index ["inquiry_product_id"], name: "index_inquiry_import_rows_on_inquiry_product_id"
  end

  create_table "inquiry_imports", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.integer "import_type"
    t.text "import_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_inquiry_imports_on_created_by_id"
    t.index ["inquiry_id"], name: "index_inquiry_imports_on_inquiry_id"
    t.index ["updated_by_id"], name: "index_inquiry_imports_on_updated_by_id"
  end

  create_table "inquiry_product_suppliers", force: :cascade do |t|
    t.bigint "inquiry_product_id"
    t.integer "legacy_id"
    t.integer "supplier_id"
    t.decimal "unit_cost_price"
    t.string "bp_catalog_name"
    t.string "bp_catalog_sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["bp_catalog_name"], name: "index_inquiry_product_suppliers_on_bp_catalog_name"
    t.index ["bp_catalog_sku"], name: "index_inquiry_product_suppliers_on_bp_catalog_sku"
    t.index ["created_by_id"], name: "index_inquiry_product_suppliers_on_created_by_id"
    t.index ["inquiry_product_id", "supplier_id"], name: "index_ips_on_inquiry_product_id_and_supplier_id", unique: true
    t.index ["inquiry_product_id"], name: "index_inquiry_product_suppliers_on_inquiry_product_id"
    t.index ["legacy_id"], name: "index_inquiry_product_suppliers_on_legacy_id"
    t.index ["supplier_id"], name: "index_inquiry_product_suppliers_on_supplier_id"
    t.index ["updated_by_id"], name: "index_inquiry_product_suppliers_on_updated_by_id"
  end

  create_table "inquiry_products", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.bigint "product_id"
    t.bigint "inquiry_import_id"
    t.integer "legacy_id"
    t.integer "sr_no"
    t.integer "quantity"
    t.string "bp_catalog_name"
    t.string "bp_catalog_sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["bp_catalog_name"], name: "index_inquiry_products_on_bp_catalog_name"
    t.index ["bp_catalog_sku"], name: "index_inquiry_products_on_bp_catalog_sku"
    t.index ["created_by_id"], name: "index_inquiry_products_on_created_by_id"
    t.index ["inquiry_id", "product_id"], name: "index_inquiry_products_on_inquiry_id_and_product_id", unique: true
    t.index ["inquiry_id"], name: "index_inquiry_products_on_inquiry_id"
    t.index ["inquiry_import_id"], name: "index_inquiry_products_on_inquiry_import_id"
    t.index ["legacy_id"], name: "index_inquiry_products_on_legacy_id"
    t.index ["product_id"], name: "index_inquiry_products_on_product_id"
    t.index ["updated_by_id"], name: "index_inquiry_products_on_updated_by_id"
  end

  create_table "lead_time_options", force: :cascade do |t|
    t.integer "legacy_id"
    t.integer "min_days"
    t.integer "max_days"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_lead_time_options_on_legacy_id"
  end

  create_table "measurement_units", force: :cascade do |t|
    t.integer "legacy_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_measurement_units_on_legacy_id"
  end

  create_table "overseer_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "overseer_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "overseer_desc_idx"
  end

  create_table "overseers", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "legacy_id"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "mobile"
    t.string "designation"
    t.string "identifier"
    t.string "department"
    t.string "geography"
    t.integer "role"
    t.integer "salesperson_uid"
    t.integer "employee_uid"
    t.integer "center_code_uid"
    t.string "google_oauth2_uid"
    t.jsonb "google_oauth2_metadata"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_overseers_on_created_by_id"
    t.index ["email"], name: "index_overseers_on_email", unique: true
    t.index ["employee_uid"], name: "index_overseers_on_employee_uid", unique: true
    t.index ["legacy_id"], name: "index_overseers_on_legacy_id"
    t.index ["parent_id"], name: "index_overseers_on_parent_id"
    t.index ["reset_password_token"], name: "index_overseers_on_reset_password_token", unique: true
    t.index ["role"], name: "index_overseers_on_role"
    t.index ["salesperson_uid"], name: "index_overseers_on_salesperson_uid", unique: true
    t.index ["unlock_token"], name: "index_overseers_on_unlock_token", unique: true
    t.index ["updated_by_id"], name: "index_overseers_on_updated_by_id"
  end

  create_table "payment_options", force: :cascade do |t|
    t.integer "remote_uid"
    t.integer "legacy_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legacy_id"], name: "index_payment_options_on_legacy_id"
    t.index ["remote_uid"], name: "index_payment_options_on_remote_uid", unique: true
  end

  create_table "product_approvals", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "product_comment_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_product_approvals_on_created_by_id"
    t.index ["product_comment_id"], name: "index_product_approvals_on_product_comment_id"
    t.index ["product_id"], name: "index_product_approvals_on_product_id"
    t.index ["updated_by_id"], name: "index_product_approvals_on_updated_by_id"
  end

  create_table "product_comments", force: :cascade do |t|
    t.bigint "product_id"
    t.string "merged_product_name"
    t.string "merged_product_sku"
    t.jsonb "merged_product_metadata"
    t.text "message"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_product_comments_on_created_by_id"
    t.index ["product_id"], name: "index_product_comments_on_product_id"
    t.index ["updated_by_id"], name: "index_product_comments_on_updated_by_id"
  end

  create_table "product_rejections", force: :cascade do |t|
    t.bigint "product_id"
    t.bigint "product_comment_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_product_rejections_on_created_by_id"
    t.index ["product_comment_id"], name: "index_product_rejections_on_product_comment_id"
    t.index ["product_id"], name: "index_product_rejections_on_product_id"
    t.index ["updated_by_id"], name: "index_product_rejections_on_updated_by_id"
  end

  create_table "product_suppliers", force: :cascade do |t|
    t.bigint "product_id"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_product_suppliers_on_created_by_id"
    t.index ["product_id"], name: "index_product_suppliers_on_product_id"
    t.index ["supplier_id", "product_id"], name: "index_product_suppliers_on_supplier_id_and_product_id", unique: true
    t.index ["supplier_id"], name: "index_product_suppliers_on_supplier_id"
    t.index ["updated_by_id"], name: "index_product_suppliers_on_updated_by_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id"
    t.bigint "category_id"
    t.bigint "tax_code_id"
    t.bigint "measurement_unit_id"
    t.integer "legacy_id"
    t.integer "product_type"
    t.boolean "is_verified", default: false
    t.string "name"
    t.string "sku"
    t.string "description"
    t.string "meta_description"
    t.string "meta_keyword"
    t.string "meta_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.bigint "inquiry_import_row_id"
    t.string "trashed_sku"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["created_by_id"], name: "index_products_on_created_by_id"
    t.index ["inquiry_import_row_id"], name: "index_products_on_inquiry_import_row_id"
    t.index ["legacy_id"], name: "index_products_on_legacy_id"
    t.index ["measurement_unit_id"], name: "index_products_on_measurement_unit_id"
    t.index ["product_type"], name: "index_products_on_product_type"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["tax_code_id"], name: "index_products_on_tax_code_id"
    t.index ["updated_by_id"], name: "index_products_on_updated_by_id"
  end

  create_table "sales_order_approvals", force: :cascade do |t|
    t.bigint "sales_order_id"
    t.bigint "inquiry_comment_id"
    t.jsonb "metadata"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_sales_order_approvals_on_created_by_id"
    t.index ["inquiry_comment_id"], name: "index_sales_order_approvals_on_inquiry_comment_id"
    t.index ["sales_order_id"], name: "index_sales_order_approvals_on_sales_order_id"
    t.index ["updated_by_id"], name: "index_sales_order_approvals_on_updated_by_id"
  end

  create_table "sales_order_comments", force: :cascade do |t|
    t.bigint "sales_order_id"
    t.text "message"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_sales_order_comments_on_created_by_id"
    t.index ["sales_order_id"], name: "index_sales_order_comments_on_sales_order_id"
    t.index ["updated_by_id"], name: "index_sales_order_comments_on_updated_by_id"
  end

  create_table "sales_order_confirmations", force: :cascade do |t|
    t.bigint "sales_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_sales_order_confirmations_on_created_by_id"
    t.index ["sales_order_id"], name: "index_sales_order_confirmations_on_sales_order_id"
    t.index ["updated_by_id"], name: "index_sales_order_confirmations_on_updated_by_id"
  end

  create_table "sales_order_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "sales_order_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "sales_order_desc_idx"
  end

  create_table "sales_order_rejections", force: :cascade do |t|
    t.bigint "sales_order_id"
    t.bigint "inquiry_comment_id"
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_sales_order_rejections_on_created_by_id"
    t.index ["inquiry_comment_id"], name: "index_sales_order_rejections_on_inquiry_comment_id"
    t.index ["sales_order_id"], name: "index_sales_order_rejections_on_sales_order_id"
    t.index ["updated_by_id"], name: "index_sales_order_rejections_on_updated_by_id"
  end

  create_table "sales_order_rows", force: :cascade do |t|
    t.bigint "sales_order_id"
    t.bigint "sales_quote_row_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_sales_order_rows_on_created_by_id"
    t.index ["sales_order_id", "sales_quote_row_id"], name: "index_sales_order_rows_on_sales_order_id_and_sales_quote_row_id", unique: true
    t.index ["sales_order_id"], name: "index_sales_order_rows_on_sales_order_id"
    t.index ["sales_quote_row_id"], name: "index_sales_order_rows_on_sales_quote_row_id"
    t.index ["updated_by_id"], name: "index_sales_order_rows_on_updated_by_id"
  end

  create_table "sales_orders", force: :cascade do |t|
    t.bigint "sales_quote_id"
    t.integer "parent_id"
    t.integer "legacy_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "order_number"
    t.string "sap_series"
    t.string "remote_uid"
    t.string "doc_number"
    t.integer "legacy_request_status"
    t.index ["created_by_id"], name: "index_sales_orders_on_created_by_id"
    t.index ["legacy_id"], name: "index_sales_orders_on_legacy_id"
    t.index ["parent_id"], name: "index_sales_orders_on_parent_id"
    t.index ["sales_quote_id"], name: "index_sales_orders_on_sales_quote_id"
    t.index ["updated_by_id"], name: "index_sales_orders_on_updated_by_id"
  end

  create_table "sales_quote_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "sales_quote_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "sales_quote_desc_idx"
  end

  create_table "sales_quote_rows", force: :cascade do |t|
    t.bigint "sales_quote_id"
    t.bigint "inquiry_product_supplier_id"
    t.bigint "tax_code_id"
    t.bigint "lead_time_option_id"
    t.integer "quantity"
    t.decimal "margin_percentage"
    t.decimal "unit_selling_price"
    t.decimal "converted_unit_selling_price"
    t.decimal "freight_cost_subtotal"
    t.decimal "unit_freight_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.string "legacy_applicable_tax"
    t.integer "legacy_applicable_tax_class"
    t.index ["created_by_id"], name: "index_sales_quote_rows_on_created_by_id"
    t.index ["inquiry_product_supplier_id"], name: "index_sales_quote_rows_on_inquiry_product_supplier_id"
    t.index ["lead_time_option_id"], name: "index_sales_quote_rows_on_lead_time_option_id"
    t.index ["sales_quote_id", "inquiry_product_supplier_id"], name: "index_sqr_on_sales_quote_id_and_inquiry_product_supplier_id", unique: true
    t.index ["sales_quote_id"], name: "index_sales_quote_rows_on_sales_quote_id"
    t.index ["tax_code_id"], name: "index_sales_quote_rows_on_tax_code_id"
    t.index ["updated_by_id"], name: "index_sales_quote_rows_on_updated_by_id"
  end

  create_table "sales_quotes", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.integer "parent_id"
    t.string "quotation_uid"
    t.integer "legacy_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_sales_quotes_on_created_by_id"
    t.index ["inquiry_id"], name: "index_sales_quotes_on_inquiry_id"
    t.index ["legacy_id"], name: "index_sales_quotes_on_legacy_id"
    t.index ["parent_id"], name: "index_sales_quotes_on_parent_id"
    t.index ["quotation_uid"], name: "index_sales_quotes_on_quotation_uid", unique: true
    t.index ["updated_by_id"], name: "index_sales_quotes_on_updated_by_id"
  end

  create_table "tax_codes", force: :cascade do |t|
    t.integer "remote_uid"
    t.integer "legacy_id"
    t.string "code"
    t.integer "chapter"
    t.string "description"
    t.boolean "is_service", default: false
    t.decimal "tax_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_tax_codes_on_code"
    t.index ["description"], name: "index_tax_codes_on_description"
    t.index ["legacy_id"], name: "index_tax_codes_on_legacy_id"
    t.index ["remote_uid"], name: "index_tax_codes_on_remote_uid"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "accounts", "overseers", column: "created_by_id"
  add_foreign_key "accounts", "overseers", column: "updated_by_id"
  add_foreign_key "addresses", "address_states"
  add_foreign_key "addresses", "companies"
  add_foreign_key "addresses", "overseers", column: "created_by_id"
  add_foreign_key "addresses", "overseers", column: "updated_by_id"
  add_foreign_key "brand_suppliers", "brands"
  add_foreign_key "brand_suppliers", "companies", column: "supplier_id"
  add_foreign_key "brand_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "brand_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "brands", "overseers", column: "created_by_id"
  add_foreign_key "brands", "overseers", column: "updated_by_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "categories", "overseers", column: "created_by_id"
  add_foreign_key "categories", "overseers", column: "updated_by_id"
  add_foreign_key "categories", "tax_codes"
  add_foreign_key "category_hierarchies", "categories", column: "ancestor_id"
  add_foreign_key "category_hierarchies", "categories", column: "descendant_id"
  add_foreign_key "category_suppliers", "categories"
  add_foreign_key "category_suppliers", "companies", column: "supplier_id"
  add_foreign_key "category_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "category_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "companies", "accounts"
  add_foreign_key "companies", "addresses", column: "default_billing_address_id"
  add_foreign_key "companies", "addresses", column: "default_shipping_address_id"
  add_foreign_key "companies", "company_contacts", column: "default_company_contact_id"
  add_foreign_key "companies", "industries"
  add_foreign_key "companies", "overseers", column: "created_by_id"
  add_foreign_key "companies", "overseers", column: "inside_sales_owner_id"
  add_foreign_key "companies", "overseers", column: "outside_sales_owner_id"
  add_foreign_key "companies", "overseers", column: "sales_manager_id"
  add_foreign_key "companies", "overseers", column: "updated_by_id"
  add_foreign_key "companies", "payment_options", column: "default_payment_option_id"
  add_foreign_key "company_banks", "companies"
  add_foreign_key "company_contacts", "companies"
  add_foreign_key "company_contacts", "contacts"
  add_foreign_key "company_contacts", "overseers", column: "created_by_id"
  add_foreign_key "company_contacts", "overseers", column: "updated_by_id"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "contacts", "overseers", column: "created_by_id"
  add_foreign_key "contacts", "overseers", column: "updated_by_id"
  add_foreign_key "inquiries", "companies"
  add_foreign_key "inquiries", "contacts"
  add_foreign_key "inquiries", "inquiry_currencies"
  add_foreign_key "inquiries", "overseers", column: "created_by_id"
  add_foreign_key "inquiries", "overseers", column: "inside_sales_owner_id"
  add_foreign_key "inquiries", "overseers", column: "outside_sales_owner_id"
  add_foreign_key "inquiries", "overseers", column: "sales_manager_id"
  add_foreign_key "inquiries", "overseers", column: "updated_by_id"
  add_foreign_key "inquiries", "payment_options"
  add_foreign_key "inquiry_comments", "inquiries"
  add_foreign_key "inquiry_comments", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_comments", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_comments", "sales_orders"
  add_foreign_key "inquiry_currencies", "currencies"
  add_foreign_key "inquiry_import_rows", "inquiry_imports"
  add_foreign_key "inquiry_import_rows", "inquiry_products"
  add_foreign_key "inquiry_imports", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_imports", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_product_suppliers", "companies", column: "supplier_id"
  add_foreign_key "inquiry_product_suppliers", "inquiry_products"
  add_foreign_key "inquiry_product_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_product_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_products", "inquiries"
  add_foreign_key "inquiry_products", "inquiry_imports"
  add_foreign_key "inquiry_products", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_products", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_products", "products"
  add_foreign_key "overseer_hierarchies", "overseers", column: "ancestor_id"
  add_foreign_key "overseer_hierarchies", "overseers", column: "descendant_id"
  add_foreign_key "overseers", "overseers", column: "created_by_id"
  add_foreign_key "overseers", "overseers", column: "parent_id"
  add_foreign_key "overseers", "overseers", column: "updated_by_id"
  add_foreign_key "product_approvals", "overseers", column: "created_by_id"
  add_foreign_key "product_approvals", "overseers", column: "updated_by_id"
  add_foreign_key "product_approvals", "product_comments"
  add_foreign_key "product_approvals", "products"
  add_foreign_key "product_comments", "overseers", column: "created_by_id"
  add_foreign_key "product_comments", "overseers", column: "updated_by_id"
  add_foreign_key "product_comments", "products"
  add_foreign_key "product_rejections", "overseers", column: "created_by_id"
  add_foreign_key "product_rejections", "overseers", column: "updated_by_id"
  add_foreign_key "product_rejections", "product_comments"
  add_foreign_key "product_rejections", "products"
  add_foreign_key "product_suppliers", "companies", column: "supplier_id"
  add_foreign_key "product_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "product_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "product_suppliers", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "inquiry_import_rows"
  add_foreign_key "products", "measurement_units"
  add_foreign_key "products", "overseers", column: "created_by_id"
  add_foreign_key "products", "overseers", column: "updated_by_id"
  add_foreign_key "products", "tax_codes"
  add_foreign_key "sales_order_approvals", "inquiry_comments"
  add_foreign_key "sales_order_approvals", "overseers", column: "created_by_id"
  add_foreign_key "sales_order_approvals", "overseers", column: "updated_by_id"
  add_foreign_key "sales_order_approvals", "sales_orders"
  add_foreign_key "sales_order_comments", "overseers", column: "created_by_id"
  add_foreign_key "sales_order_comments", "overseers", column: "updated_by_id"
  add_foreign_key "sales_order_comments", "sales_orders"
  add_foreign_key "sales_order_confirmations", "overseers", column: "created_by_id"
  add_foreign_key "sales_order_confirmations", "overseers", column: "updated_by_id"
  add_foreign_key "sales_order_confirmations", "sales_orders"
  add_foreign_key "sales_order_rejections", "inquiry_comments"
  add_foreign_key "sales_order_rejections", "overseers", column: "created_by_id"
  add_foreign_key "sales_order_rejections", "overseers", column: "updated_by_id"
  add_foreign_key "sales_order_rejections", "sales_orders"
  add_foreign_key "sales_order_rows", "overseers", column: "created_by_id"
  add_foreign_key "sales_order_rows", "overseers", column: "updated_by_id"
  add_foreign_key "sales_order_rows", "sales_orders"
  add_foreign_key "sales_order_rows", "sales_quote_rows"
  add_foreign_key "sales_orders", "overseers", column: "created_by_id"
  add_foreign_key "sales_orders", "overseers", column: "updated_by_id"
  add_foreign_key "sales_orders", "sales_orders", column: "parent_id"
  add_foreign_key "sales_orders", "sales_quotes"
  add_foreign_key "sales_quote_rows", "inquiry_product_suppliers"
  add_foreign_key "sales_quote_rows", "lead_time_options"
  add_foreign_key "sales_quote_rows", "overseers", column: "created_by_id"
  add_foreign_key "sales_quote_rows", "overseers", column: "updated_by_id"
  add_foreign_key "sales_quote_rows", "sales_quotes"
  add_foreign_key "sales_quote_rows", "tax_codes"
  add_foreign_key "sales_quotes", "inquiries"
  add_foreign_key "sales_quotes", "overseers", column: "created_by_id"
  add_foreign_key "sales_quotes", "overseers", column: "updated_by_id"
  add_foreign_key "sales_quotes", "sales_quotes", column: "parent_id"
end
