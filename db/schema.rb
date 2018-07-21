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

ActiveRecord::Schema.define(version: 2018_07_20_123423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_accounts_on_created_by_id"
    t.index ["name"], name: "index_accounts_on_name", unique: true
    t.index ["updated_by_id"], name: "index_accounts_on_updated_by_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.string "street1"
    t.string "street2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["company_id"], name: "index_addresses_on_company_id"
    t.index ["created_by_id"], name: "index_addresses_on_created_by_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_brands_on_created_by_id"
    t.index ["updated_by_id"], name: "index_brands_on_updated_by_id"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_categories_on_created_by_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
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

  create_table "companies", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "default_payment_option_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["account_id"], name: "index_companies_on_account_id"
    t.index ["created_by_id"], name: "index_companies_on_created_by_id"
    t.index ["default_payment_option_id"], name: "index_companies_on_default_payment_option_id"
    t.index ["updated_by_id"], name: "index_companies_on_updated_by_id"
  end

  create_table "company_contacts", force: :cascade do |t|
    t.bigint "company_id"
    t.bigint "contact_id"
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
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["account_id"], name: "index_contacts_on_account_id"
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["updated_by_id"], name: "index_contacts_on_updated_by_id"
  end

  create_table "inquiries", force: :cascade do |t|
    t.bigint "contact_id"
    t.bigint "company_id"
    t.integer "billing_address_id"
    t.integer "shipping_address_id"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["billing_address_id"], name: "index_inquiries_on_billing_address_id"
    t.index ["company_id"], name: "index_inquiries_on_company_id"
    t.index ["contact_id"], name: "index_inquiries_on_contact_id"
    t.index ["created_by_id"], name: "index_inquiries_on_created_by_id"
    t.index ["shipping_address_id"], name: "index_inquiries_on_shipping_address_id"
    t.index ["updated_by_id"], name: "index_inquiries_on_updated_by_id"
  end

  create_table "inquiry_products", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.bigint "product_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_inquiry_products_on_created_by_id"
    t.index ["inquiry_id", "product_id"], name: "index_inquiry_products_on_inquiry_id_and_product_id", unique: true
    t.index ["inquiry_id"], name: "index_inquiry_products_on_inquiry_id"
    t.index ["product_id"], name: "index_inquiry_products_on_product_id"
    t.index ["updated_by_id"], name: "index_inquiry_products_on_updated_by_id"
  end

  create_table "inquiry_suppliers", force: :cascade do |t|
    t.bigint "inquiry_product_id"
    t.integer "supplier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_inquiry_suppliers_on_created_by_id"
    t.index ["inquiry_product_id", "supplier_id"], name: "index_inquiry_suppliers_on_inquiry_product_id_and_supplier_id", unique: true
    t.index ["inquiry_product_id"], name: "index_inquiry_suppliers_on_inquiry_product_id"
    t.index ["supplier_id"], name: "index_inquiry_suppliers_on_supplier_id"
    t.index ["updated_by_id"], name: "index_inquiry_suppliers_on_updated_by_id"
  end

  create_table "overseers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.integer "role"
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
    t.index ["email"], name: "index_overseers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_overseers_on_reset_password_token", unique: true
    t.index ["role"], name: "index_overseers_on_role"
    t.index ["unlock_token"], name: "index_overseers_on_unlock_token", unique: true
  end

  create_table "payment_options", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "name"
    t.string "sku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["created_by_id"], name: "index_products_on_created_by_id"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["updated_by_id"], name: "index_products_on_updated_by_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "inquiry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_quotes_on_created_by_id"
    t.index ["inquiry_id"], name: "index_quotes_on_inquiry_id"
    t.index ["updated_by_id"], name: "index_quotes_on_updated_by_id"
  end

  create_table "rfq_contacts", force: :cascade do |t|
    t.bigint "rfq_id"
    t.bigint "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["contact_id"], name: "index_rfq_contacts_on_contact_id"
    t.index ["created_by_id"], name: "index_rfq_contacts_on_created_by_id"
    t.index ["rfq_id", "contact_id"], name: "index_rfq_contacts_on_rfq_id_and_contact_id", unique: true
    t.index ["rfq_id"], name: "index_rfq_contacts_on_rfq_id"
    t.index ["updated_by_id"], name: "index_rfq_contacts_on_updated_by_id"
  end

  create_table "rfqs", force: :cascade do |t|
    t.integer "supplier_id"
    t.bigint "inquiry_id"
    t.text "subject"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["created_by_id"], name: "index_rfqs_on_created_by_id"
    t.index ["inquiry_id"], name: "index_rfqs_on_inquiry_id"
    t.index ["supplier_id"], name: "index_rfqs_on_supplier_id"
    t.index ["updated_by_id"], name: "index_rfqs_on_updated_by_id"
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
  add_foreign_key "category_hierarchies", "categories", column: "ancestor_id"
  add_foreign_key "category_hierarchies", "categories", column: "descendant_id"
  add_foreign_key "category_suppliers", "categories"
  add_foreign_key "category_suppliers", "companies", column: "supplier_id"
  add_foreign_key "category_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "category_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "companies", "accounts"
  add_foreign_key "companies", "overseers", column: "created_by_id"
  add_foreign_key "companies", "overseers", column: "updated_by_id"
  add_foreign_key "companies", "payment_options", column: "default_payment_option_id"
  add_foreign_key "company_contacts", "companies"
  add_foreign_key "company_contacts", "contacts"
  add_foreign_key "company_contacts", "overseers", column: "created_by_id"
  add_foreign_key "company_contacts", "overseers", column: "updated_by_id"
  add_foreign_key "contacts", "accounts"
  add_foreign_key "contacts", "overseers", column: "created_by_id"
  add_foreign_key "contacts", "overseers", column: "updated_by_id"
  add_foreign_key "inquiries", "companies"
  add_foreign_key "inquiries", "contacts"
  add_foreign_key "inquiries", "overseers", column: "created_by_id"
  add_foreign_key "inquiries", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_products", "inquiries"
  add_foreign_key "inquiry_products", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_products", "overseers", column: "updated_by_id"
  add_foreign_key "inquiry_products", "products"
  add_foreign_key "inquiry_suppliers", "companies", column: "supplier_id"
  add_foreign_key "inquiry_suppliers", "inquiry_products"
  add_foreign_key "inquiry_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "inquiry_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "product_suppliers", "companies", column: "supplier_id"
  add_foreign_key "product_suppliers", "overseers", column: "created_by_id"
  add_foreign_key "product_suppliers", "overseers", column: "updated_by_id"
  add_foreign_key "product_suppliers", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "overseers", column: "created_by_id"
  add_foreign_key "products", "overseers", column: "updated_by_id"
  add_foreign_key "quotes", "inquiries"
  add_foreign_key "quotes", "overseers", column: "created_by_id"
  add_foreign_key "quotes", "overseers", column: "updated_by_id"
  add_foreign_key "rfq_contacts", "contacts"
  add_foreign_key "rfq_contacts", "overseers", column: "created_by_id"
  add_foreign_key "rfq_contacts", "overseers", column: "updated_by_id"
  add_foreign_key "rfq_contacts", "rfqs"
  add_foreign_key "rfqs", "companies", column: "supplier_id"
  add_foreign_key "rfqs", "inquiries"
  add_foreign_key "rfqs", "overseers", column: "created_by_id"
  add_foreign_key "rfqs", "overseers", column: "updated_by_id"
end
