class ReindexTables < ActiveRecord::Migration[5.2]
  def up
    # add_index :overseers, :email,                unique: true
    # add_index :overseers, :reset_password_token, unique: true
    # add_index :overseers, :unlock_token,         unique: true
    # add_index :overseer_hierarchies, [:ancestor_id, :descendant_id, :generations],
    #   unique: true,
    #   name: "overseer_anc_desc_idx"

    # add_index :overseer_hierarchies, [:descendant_id],
    #   name: "overseer_desc_idx"
    # add_index :contacts, :email, unique: true
    # add_index :contacts, :reset_password_token, unique: true
    # add_index :contacts, :unlock_token, unique: true
    # add_index :company_contacts, [:company_id, :contact_id], unique: true
    # add_index :category_hierarchies, [:ancestor_id, :descendant_id, :generations],
    #   unique: true,
    #   name: "category_anc_desc_idx"

    # add_index :category_hierarchies, [:descendant_id],
    #   name: "category_desc_idx"
    # add_index :category_suppliers, [:supplier_id, :category_id], unique: true
    # add_index :product_suppliers, [:supplier_id, :product_id], unique: true
    # add_index :inquiry_product_suppliers, [:inquiry_product_id, :supplier_id], unique: true, name: 'index_ips_on_inquiry_product_id_and_supplier_id'
    # add_index :sales_quote_hierarchies, [:ancestor_id, :descendant_id, :generations],
    #   unique: true,
    #   name: "sales_quote_anc_desc_idx"

    # add_index :sales_quote_hierarchies, [:descendant_id],
    #   name: "sales_quote_desc_idx"
    # add_index :sales_quote_rows, [:sales_quote_id, :inquiry_product_supplier_id], unique: true, name: 'index_sqr_on_sales_quote_id_and_inquiry_product_supplier_id'
    # add_index :sales_order_hierarchies, [:ancestor_id, :descendant_id, :generations],
    #   unique: true,
    #   name: "sales_order_anc_desc_idx"

    # add_index :sales_order_hierarchies, [:descendant_id],
    #   name: "sales_order_desc_idx"
    # add_index :sales_order_rows, [:sales_order_id, :sales_quote_row_id], unique: true
    # add_index :activity_overseers, [:overseer_id, :activity_id], unique: true
    # add_index :customer_order_rows, [:customer_order_id, :product_id], unique: true
  
    # add_index :image_readers, :status
    # add_index :image_readers, :created_at
    # add_index :rating_caches, [:cacheable_id, :cacheable_type]
    # add_index :rates, [:rateable_id, :rateable_type]
    # add_index :company_ratings, [:company_review_id, :review_question_id, :created_by_id], unique: true, name: 'index_on_company_rating'
    # add_index :inward_dispatch_rows, [:inward_dispatch_id, :purchase_order_row_id], unique: true, name: 'index_idr_on_id_and_por'
    # add_index :acl_resources, [:resource_model_name, :resource_action_name], unique: true, name: 'resource_model_action_index'
    # add_index :annual_targets, [:resource_type, :resource_id]
    # add_index :sales_orders, :id
    # add_index :sales_orders, :created_at
    # add_index :sales_quote_rows, :id
    # add_index :accounts, :id 
    # add_index :products, :id 
    # add_index :task_overseers, [:overseer_id, :task_id], unique: true
    # ###### Indexes for remote_uid #######
    # add_index :address_states, :remote_uid, unique: true
    # add_index :tax_codes, :remote_uid
    # add_index :accounts, :remote_uid
    # add_index :industries, :remote_uid, unique: true
    # add_index :payment_options, :remote_uid, unique: true
    # add_index :companies, :remote_uid, unique: true
    # add_index :addresses, :remote_uid
    # add_index :company_contacts, :remote_uid, unique: true
    # add_index :warehouses, :remote_uid
    # add_index :brands, :remote_uid
    # add_index :categories, :remote_uid
    # add_index :products, :remote_uid, unique: true
    # #add_index :company_banks, :remote_uid
    # add_index :sales_orders, :remote_uid
    # #add_index :sales_quote_rows, :remote_uid
    # #add_index :kits, :remote_uid
    # #add_index :inquiry_status_records, :remote_uid
    # #add_index :sales_quotes, :remote_uid, unique: false
    # #add_index :purchase_orders, :remote_uid, unique: false
  end

  def down 
    remove_index :overseers, :email
    remove_index :overseers, :reset_password_token
    remove_index :overseers, :unlock_token
    remove_index :overseer_hierarchies, [:ancestor_id, :descendant_id, :generations]
    remove_index :overseer_hierarchies, [:descendant_id]
    remove_index :contacts, :email
    remove_index :contacts, :reset_password_token
    remove_index :contacts, :unlock_token
    remove_index :company_contacts, [:company_id, :contact_id]
    remove_index :category_hierarchies, [:ancestor_id, :descendant_id, :generations]
    remove_index :category_hierarchies, [:descendant_id]
    remove_index :category_suppliers, [:supplier_id, :category_id]
    remove_index :product_suppliers, [:supplier_id, :product_id]
    remove_index :inquiry_product_suppliers, [:inquiry_product_id, :supplier_id]
    remove_index :sales_quote_hierarchies, [:ancestor_id, :descendant_id, :generations]
    remove_index :sales_quote_hierarchies, [:descendant_id]
    remove_index :sales_quote_rows, [:sales_quote_id, :inquiry_product_supplier_id]
    remove_index :sales_order_hierarchies, [:ancestor_id, :descendant_id, :generations]
    remove_index :sales_order_hierarchies, [:descendant_id]
    remove_index :sales_order_rows, [:sales_order_id, :sales_quote_row_id]
    remove_index :activity_overseers, [:overseer_id, :activity_id]
    remove_index :customer_order_rows, [:customer_order_id, :product_id]
    remove_index :image_readers, :status
    remove_index :image_readers, :created_at
    remove_index :rating_caches, [:cacheable_id, :cacheable_type]
    remove_index :rates, [:rateable_id, :rateable_type]
    remove_index :company_ratings, [:company_review_id, :review_question_id, :created_by_id]
    remove_index :inward_dispatch_rows, [:inward_dispatch_id, :purchase_order_row_id]
    remove_index :acl_resources, [:resource_model_name, :resource_action_name]
    remove_index :annual_targets, [:resource_type, :resource_id]
    remove_index :sales_orders, :id
    remove_index :sales_orders, :created_at
    remove_index :sales_quote_rows, :id
    remove_index :accounts, :id 
    remove_index :products, :id 
    remove_index :task_overseers, [:overseer_id, :task_id]
    #remote_uid
    remove_index :address_states, :remote_uid
    remove_index :tax_codes, :remote_uid
    remove_index :accounts, :remote_uid
    remove_index :industries, :remote_uid
    remove_index :payment_options, :remote_uid
    remove_index :companies, :remote_uid
    remove_index :addresses, :remote_uid
    remove_index :company_contacts, :remote_uid
    remove_index :warehouses, :remote_uid
    remove_index :brands, :remote_uid
    remove_index :categories, :remote_uid
    remove_index :products, :remote_uid
    #remove_index :company_banks, :remote_uid
    remove_index :sales_orders, :remote_uid
    # remove_index :sales_quote_rows, :remote_uid
    # remove_index :kits, :remote_uid
    # remove_index :inquiry_status_records, :remote_uid
    # remove_index :sales_quotes, :remote_uid
    # remove_index :purchase_orders, :remote_uid
  end
end
