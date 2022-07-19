Rails.application.routes.draw do
  require 'sidekiq/web'
  post '/rate' => 'rater#create', :as => 'rate'
  get '/faq', to: 'static_pages#faq'
  mount Maily::Engine, at: '/maily' if Rails.env.development?
  mount ActionCable.server, at: '/cable'
  authenticate :overseer, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  root to: 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'
  get '/customers', to: redirect('/customers/dashboard'), as: 'customer_root'
  get '/suppliers', to: redirect('/suppliers/dashboard'), as: 'supplier_root'

  devise_for :overseers, controllers: {sessions: 'overseers/sessions', omniauth_callbacks: 'overseers/omniauth_callbacks'}
  # devise_for :contacts, controllers: {sessions: 'customers/sessions', passwords: 'customers/passwords'}, path: :customers

  namespace :suppliers, path: '/' do
    devise_for :contacts, controllers: {sessions: 'suppliers/sessions', passwords: 'suppliers/passwords'}, path: :suppliers
  end

  namespace :customers, path: '/' do
    devise_for :contacts, controllers: {sessions: 'customers/sessions', passwords: 'customers/passwords'}, path: :customers
  end

  namespace :api do
    namespace :v1 do
      resources :punchouts do
        collection do
          post 'auth'
        end
      end
    end
  end

  namespace 'callbacks' do
    resources :sales_orders do
      member do
        patch 'update'
      end
    end

    resources :sales_invoices do
      member do
        patch 'update'
      end
    end

    resources :sales_receipts

    resources :sales_shipments do
      member do
        patch 'update'
      end
    end

    resources :credit_notes do
      member do
        patch 'update'
      end
    end

    post '1de9b0a30075ae8c303eb420c103c320', to: 'image_readers#update'
    resources :purchase_orders
    resources :products

    get 'login' => '/callbacks/sessions#new'
  end

  namespace 'overseers' do
    get '/docs/*page' => 'docs#index'
    resources :delivery_challans do
      collection do
        get 'next_step'
      end

      member do
        get 'preview'
        get 'relationship_map'
        get 'get_relationship_map_json'
      end
    end
    resources :payment_collection_emails
    resources :attachments
    resources :review_questions
    resources :banks
    resources :ifsc_codes do
      collection do
        get 'suggestion'
      end
    end

    resource :dashboard, controller: :dashboard do
      get 'chewy'
      get 'reset_index'
      get 'serializer'
      get 'migrations'
      get 'console'
      get 'get_status_records'
      get 'show_email_message_modal'
      post 'update_inquiry'
      post 'update_invoice_request'
      post 'approve_reject_so'
      get 'get_filtered_inquiries'
      get 'get_inquiry_tasks'
      get 'follow_up_dashboard'
      get 'sales_manager'
      get 'accounts'
      get 'sales_executive'
      get 'my_team'
      get 'get_recent_inquiries'
      get 'get_account_executive_data'
    end

    resources :remote_requests do
      member do
        get 'show'
      end
      collection do
        get 'resend_failed_requests'
      end
    end

    resources :resync_remote_requests do
      member do
        get 'resend_failed_request'
      end
      collection do
        get 'all_requests'
      end
    end

    resources :callback_requests do
      member do
        get 'show'
      end
    end

    resources :document_creations

    resources :acl_resources do
      collection do
        get 'resource_json'
        get 'menu_resource_json'
      end
    end

    resources :notifications do
      collection do
        post 'mark_as_read'
        get 'queue'
      end
    end

    # resources :reports
    resources :reports do
      member do
        get 'export_report'
      end
    end
    resources :company_creation_requests do
      # member do
      #   post 'exchange_with_existing_company'
      # end
      collection do
        get 'requested'
        get 'created'
      end
    end

    resources :contact_creation_requests do
      # member do
      #   post 'exchange_with_existing_company'
      # end
      collection do
        get 'requested'
        get 'created'
      end
    end

    resources :activities, except: [:show] do
      collection do
        get 'pending'
        post 'approve_selected'
        post 'reject_selected'
        post 'add_to_inquiry'
        get 'export_all'
        get 'export_filtered_records'
      end
      member do
        get 'approve'
        get 'reject'
      end
    end

    resource :profile, controller: :profile, except: [:show, :index]
    resources :overseers do
      member do
        patch 'save_acl_resources'
        get 'get_resources'
        get 'get_menu_resources'
        get 'edit_acl'
        patch 'update_acl'
        get 'change_password'
        patch 'update_password'
      end

      collection do
        get 'get_resources'
        get 'isp_report'
        get 'export_isp_report'
      end
    end

    resources :acl_roles do
      member do
        get 'get_acl'
        get 'get_acl_menu'
        get 'get_role_resources'
        post 'save_role'
      end
      collection do
        get 'get_default_resources'
      end
    end

    resources :annual_targets

    resources :exports, except: [:show] do
      collection do
        get 'generate_export'
      end
    end

    resources :suppliers do
      collection do
        get 'customized_index'
        get 'autocomplete'
        get 'export_all'
        get 'export_filtered_records'
      end
    end

    resources :contacts do
      collection do
        get 'autocomplete'
        get 'fetch_company_account'
      end

      member do
        get 'become'
      end
    end

    resources :sales_quotes do
    end

    resources :brands do
      collection do
        get 'autocomplete'
      end
    end

    resources :measurement_units, except: [:show] do
      collection do
        get 'autocomplete'
      end
    end

    resources :tax_codes, except: [:show] do
      collection do
        get 'autocomplete'
        get 'autocomplete_for_product'
      end
    end

    resources :addresses do
      collection do
        get 'autocomplete'
        get 'warehouse_addresses'
        get 'is_sez_params'
        get 'get_gst_code'
      end
    end

    resources :categories do
      collection do
        get 'autocomplete'
        get 'autocomplete_closure_tree'
        get 'export_all'
        get 'autocomplete_active'
      end
    end

    resources :products do
      collection do
        get 'autocomplete'
        get 'non_kit_autocomplete'
        get 'service_autocomplete'
        get 'autocomplete_mpn'
        get 'suggestion'
      end
      member do
        get 'customer_bp_catalog'
        get 'best_prices_and_supplier_bp_catalog'
        get 'sku_purchase_history'
        get 'resync'
        get 'resync_inventory'
        get 'autocomplete_suppliers'
        get 'get_product_details'
      end

      collection do
        get 'autocomplete'
        get 'pending'
        get 'export_all'
        get 'export_filtered_records'
      end

      scope module: 'products' do
        resources :comments
      end
    end

    resources :kits do
      member do
      end

      collection do
        get 'autocomplete'
      end
    end

    resources :po_requests do
      member do
        get 'new_purchase_order'
        post 'create_purchase_order'
        get 'manager_amended'
      end
      collection do
        get 'product_resync_inventory'
      end
      scope module: 'po_requests' do
        resources :payment_requests
        resources :email_messages do
          collection do
            get 'sending_po_to_supplier'
            post 'sending_po_to_supplier_notification'
            get 'dispatch_from_supplier_delayed'
            post 'dispatch_from_supplier_delayed_notification'
            get 'material_received_in_bm_warehouse'
            post 'material_received_in_bm_warehouse_notification'
          end
        end
      end

      collection do
        get 'autocomplete'
        get 'pending_and_rejected'
        get 'cancelled'
        get 'under_amend'
        get 'amended'
        get 'pending_stock_approval'
        get 'stock_amend_requests'
        get 'stock'
        get 'completed_stock'
        get 'add_comment'
      end
      member do
        get 'render_modal_form'
        get 'render_cancellation_form'
        get 'reject_purchase_order_modal'
        patch 'rejected_purchase_order'
        patch 'cancel_porequest'
        get 'render_comment_form'
        patch 'add_comment'
      end
    end

    resources :invoice_requests do
      collection do
        get 'autocomplete'
        get 'pending'
        get 'completed'
        get 'cancelled'
      end
      member do
        get 'render_modal_form'
        patch 'cancel_invoice_request'
        patch 'add_comment'
      end
    end

    resources :ar_invoice_requests do
      collection do
        get 'pending'
        get 'completed'
        get 'cancelled'
      end
      member do
        get 'render_cancellation_form'
        get 'download_eway_bill_format'
        patch 'cancel_ar_invoice'
        get 'render_modal_form'
        patch 'add_comment'
      end
    end

    resources :outward_dispatches do
      collection do
        get 'create_with_packing_slip'
      end
      member do
        get 'make_packing_zip'
        get 'render_modal_form'
        patch 'add_comment'
      end
      scope module: 'outward_dispatches' do
        resources :packing_slips do
          collection do
            get 'add_packing'
            post 'submit_packing'
            get 'edit_outward_packing_slips'
          end
        end
        resources :email_messages do
          collection do
            get 'dispatch_mail_to_customer'
            post 'dispatch_mail_to_customer_notification'
          end
        end
      end
    end



    resources :sales_orders do
      member do
        get 'new_purchase_order'
        get 'new_purchase_orders_requests'
        post 'preview_purchase_orders_requests'
        post 'create_purchase_orders_requests'
        get 'debugging'
        get 'render_modal_form'
        patch 'add_comment'
      end

      collection do
        get 'resync_all_sales_orders'
        get 'pending'
        get 'account_approval_pending'
        get 'cancelled'
        get 'export_all'
        get 'so_sync_pending'
        get 'export_rows'
        get 'export_rows_in_bible_format'
        get 'export_for_logistics'
        get 'export_for_sap'
        get 'export_for_reco'
        get 'autocomplete'
        get 'not_invoiced'
        get 'export_filtered_records'
        get 'customer_order_status_report'
        get 'export_customer_order_status_report'
      end

      scope module: 'sales_orders' do
        resources :comments
        resources :purchase_orders_requests
        resources :email_messages do
          collection do
            get 'material_dispatched_to_customer'
            post 'material_dispatched_to_customer_notification'
            get 'material_delivered_to_customer'
            post 'material_delivered_to_customer_notification'
          end
        end
      end
    end

    resources :purchase_orders do
      member do
        get 'edit_material_followup'
        patch 'update_material_followup'
        get 'cancelled_purchase_modal'
        patch 'cancelled_purchase_order'
        get 'resync_po'
        get 'change_material_status'
        get 'render_modal_form'
        patch 'add_comment'
      end

      collection do
        get 'resync_all_purchase_orders'
        get 'export_material_readiness'
        get 'manually_closed'
        get 'pending_sap_sync'
        get 'export_all'
        get 'export_filtered_records'
        get 'autocomplete'
        get 'autocomplete_without_po_requests'
        get 'material_readiness_queue'
        get 'inward_dispatch_pickup_queue'
        get 'inward_dispatch_delivered_queue'
        get 'inward_completed_queue'
        get 'cancelled_inward_dispatches'
        post 'update_logistics_owner'
        post 'update_logistics_owner_for_inward_dispatches'
      end

      scope module: 'purchase_orders' do
        resources :inward_dispatches do
          member do
            get 'confirm_delivery'
            get 'delivered_material'
            get 'render_modal_form'
            patch 'add_comment'
          end
        end
      end
    end

    resources :sales_invoices do
      member do
        get 'edit_pod'
        patch 'update_pod'
        get 'delivery_mail_to_customer'
        post 'delivery_mail_to_customer_notification'
        get 'dispatch_mail_to_customer'
        post 'dispatch_mail_to_customer_notification'
        get 'resync_sap_status'
        get 'view_pod'
      end
      collection do
        get 'autocomplete'
        get 'export_all'
        get 'export_rows'
        get 'export_for_logistics'
        get 'export_filtered_records'
      end
    end

    resources :credit_notes, only: %w(index show) do
      collection do
        get 'resync_credit_note_from_sap'
        post 'search_or_create'
      end
    end

    resources :sales_shipments do
      collection do
        get 'export_all'
      end
    end

    resources :customer_orders do
      scope module: 'customer_orders' do
        resources :comments
        resources :inquiries do
        end
      end

      member do
        get 'order_data'
      end

      collection do
        get 'payments'
        get 'refresh_payment'
        get 'razorpay_orders'
      end
    end

    resources :inquiries do
      member do
        get 'edit_suppliers'
        post 'update_suppliers'
        post 'link_product_suppliers'
        post 'search_suppliers'
        post 'destroy_supplier'
        get 'draft_rfq'
        post 'request_for_quote'
        post 'send_email_request_for_quote'
        get 'resync_inquiry_products'
        get 'resync_unsync_inquiry_products'
        get 'calculation_sheet'
        get 'export'
        get 'stages'
        get 'relationship_map'
        get 'get_relationship_map_json'
        get 'render_followup_edit_form'
        patch 'update_followup_date'
        post 'duplicate'
        get 'render_modal_form'
        patch 'add_comment'
      end

      collection do
        get 'regret_request_action'
        get 'regret_inquiry_request_queue'
        get 'new_from_customer_order'
        get 'autocomplete'
        get 'autocomplete_without_so_confirmed'
        get 'index_pg'
        get 'smart_queue'
        get 'next_inquiry_step'
        get 'export_all'
        get 'export_filtered_records'
        get 'tat_report'
        get 'sales_owner_status_avg'
        get 'export_inquiries_tat'
        post 'create_purchase_orders_requests'
        post 'preview_stock_po_request'
        get 'kra_report'
        get 'kra_report_per_sales_owner'
        get 'export_kra_report'
        get 'bulk_update'
        get 'pipeline_report'
        get 'suggestion'
        get 'export_pipeline_report'
      end

      scope module: 'inquiries' do
        resources :comments
        resources :email_messages
        resources :supplier_rfqs do
          collection do
            post 'create_and_send_link'
            post 'add_supplier_rfqs'
            get 'edit_supplier_rfqs'
            get 'rfq_review'
            post 'rfq_review_submit'
            post 'update_all'
          end
          member do
            post 'send_email_request_for_quote'
          end
        end
        resources :sales_shipments do
          member do
            get 'relationship_map'
            get 'get_relationship_map_json'
          end
        end
        resources :purchase_orders do
          member do
            get 'relationship_map'
            get 'get_relationship_map_json'
            get 'render_modal_form'
            patch 'add_comment'
          end
        end

        resources :po_requests do
          collection do
            post 'preview_stock'
          end
        end

        resources :sales_invoices do
          member do
            get 'edit_mis_date'
            patch 'update_mis_date'

            get 'duplicate'
            get 'triplicate'
            get 'make_zip'
            get 'relationship_map'
            get 'get_relationship_map_json'
          end
        end

        resources :sales_orders do
          member do
            get 'edit_mis_date'
            patch 'update_mis_date'
            get 'debugging'
            get 'new_revision'
            get 'new_confirmation'
            get 'new_accounts_confirmation'
            get 'proforma'
            post 'create_confirmation'
            post 'create_account_confirmation'
            post 'create_account_rejection'
            post 'resync'
            get 'fetch_order_data'
            get 'relationship_map'
            get 'get_relationship_map_json'
            get 'order_cancellation_modal'
            get 'order_cancellation_modal_by_isp'
            patch 'cancellation'
            post 'isp_order_cancellation'
            get 'revise_committed_delivery_date'
            patch 'update_revised_committed_delivery_date'
            post 'isp_so_cancellation_email'
          end

          collection do
            get 'autocomplete'
          end
        end

        resources :sales_quotes do
          member do
            get 'new_revision'
            get 'preview'
            get 'reset_quote'
            get 'relationship_map'
            get 'get_relationship_map_json'
            get 'reset_quote_form'
            patch 'sales_quote_reset_by_manager'
          end

          collection do
            get 'rfq_review'
          end

          scope module: 'sales_quotes' do
            resources :email_messages
          end
        end

        resources :imports do
          member do
            get 'manage_failed_skus'
            patch 'create_failed_skus'
          end

          collection do
            get 'new_excel_import'
            post 'create_excel_import'

            get 'new_list_import'
            get 'excel_template'
            post 'create_list_import'
          end
        end
      end
    end
    namespace 'bible' do
      resources :imports do
        member do
          get 'bible_upload_log'
        end
        collection do
          get 'new_bible_import'
          post 'create_bible_records'
          get 'download_bible_order_template'
        end
      end
    end

    resources :companies do
      collection do
        get 'autocomplete'
        get 'export_all'
        get 'export_filtered_records'
        get 'company_report'
        get 'export_company_report'
        get 'get_contacts'
      end
      member do
        get 'render_rating_form'
        put 'update_rating'
        get 'get_account'
      end
      scope module: 'companies' do
        resources :customer_orders

        resources :customer_products do
          collection do
            post 'generate_catalog'
            post 'destroy_all'
            get 'export_customer_product'
            get 'autocomplete'
          end
        end

        resources :supplier_products do
          collection do
            get 'autocomplete'
          end
        end
        resources :company_reviews

        resources :tags do
          collection do
            get 'autocomplete'
            get 'autocomplete_closure_tree'
          end
        end

        resources :addresses do
          collection do
            get 'autocomplete'
          end
        end

        resources :contacts do
          collection do
            get 'autocomplete'
          end
        end

        resources :sales_quotes
        resources :sales_orders
        resources :sales_invoices do
          collection do
            get 'payment_collection'
            get 'ageing_report'
          end
        end
        resources :company_banks

        resources :imports do
          collection do
            get 'new_excel_customer_product_import'
            get 'download_customer_product_template'
            post 'customer_products', to: 'imports#create_customer_products'
          end
        end

        resources :purchase_orders do
        end

        resources :products do
        end
      end
    end

    resources :accounts do
      collection do
        get 'autocomplete'
        get 'payment_collections'
        get 'ageing_report'
        get 'autocomplete_supplier'
      end
      scope module: 'accounts' do
        resources :companies do
          collection do
            get 'payment_collections'
            get 'ageing_report'
          end
        end
        resources :sales_invoices, only: %i[show index]
      end
    end


    resources :warehouses do
      collection do
        get 'autocomplete'
        get 'series'
      end
      scope module: 'warehouses' do
        resources :product_stocks, only: %i[index]
      end
    end
    resources :payment_options do
      collection do
        get 'autocomplete'
      end
    end

    resources :payment_requests do
      collection do
        get 'completed'
        post 'update_payment_status'
      end
      member do
        get 'render_modal_form'
        patch 'add_comment'
      end
    end

    resources :freight_requests do
      scope module: 'freight_requests' do
        resources :freight_quotes
      end

      collection do
        get 'completed'
      end
    end

    resources :freight_quotes
    resources :company_reviews do
      collection do
        get 'export_all'
        get 'export_filtered_records'
      end
      member do
        get 'render_form'
      end
    end

    resources :sales_receipts
    resources :logistics_scorecards do
      collection do
        get 'add_delay_reason'
      end
    end

    # resources :bible_sales_orders
  end

  namespace 'customers' do
    resource 'sign_in_steps', controller: 'sign_in_steps' do
      post 'reset_current_company'
      get 'edit_current_company'
      patch 'update_current_company'
    end
    resource :profile, controller: :profile, except: [:show, :index]

    resources :reports, only: %i[index] do
      member do
      end

      collection do
        get 'quarterly_purchase_data'
        get 'revenue_trend'
        get 'unique_skus'
        get 'order_count'
        get 'categorywise_revenue'
        get 'stock_reports'
      end
    end

    resource :dashboard, controller: :dashboard do
      collection do
        get 'route'
        get 'export_for_amat_customer'
      end
    end
    resources :cart_items, only: %i[new create destroy update]
    resources :customer_orders, only: %i[index create show] do
      member do
        get 'order_confirmed'
        get 'approve_order'
      end

      collection do
        get 'pending'
        get 'approved'
        get 'generate_punchout_order'
      end

      scope module: 'customer_orders' do
        resources :comments
      end
    end
    resources :products, controller: :customer_products, only: %i[index create show] do
      collection do
        get 'generate_all'
        get 'most_ordered_products'
        get 'autocomplete'
      end
    end

    resources :quotes, controller: :sales_quotes, only: %i[index show] do
      member do
        post 'inquiry_comments'
      end

      scope module: 'sales_quotes' do
        resources :comments
      end

      collection do
        get 'export_all'
      end
    end

    resources :orders, controller: :sales_orders, only: %i[index show] do
      collection do
        get 'export_all'
      end
    end

    resources :invoices, controller: :sales_invoices, only: %i[index show] do
      member do
        get 'show_pods'
      end
      collection do
        get 'export_all'
      end
    end

    resource :checkout, controller: :checkout do
      collection do
        get 'final_checkout'
      end
    end
    # resources :products, only: %i[index show] do
    #   collection do
    #     get 'most_ordered_products'
    #     get 'autocomplete'
    #   end
    #
    #   member do
    #     get 'to_cart'
    #   end
    # end

    resource :cart, controller: :cart, except: [:index] do
      collection do
        get 'punchout'
        get 'punchout_cart'
        get 'manual_punchout'
        get 'checkout'
        post 'update_cart_details'
        post 'update_billing_address'
        patch 'update_payment_data'
        patch 'add_po_number'
        get 'empty_cart'
      end
    end

    resources :inquiries do
      scope module: 'inquiries' do
        resources :comments
      end
    end

    resources :image_readers do
      collection do
        get 'export_all'
        get 'export_by_date'
      end
    end

    resources :companies do
      collection do
        get 'choose_company'
        get 'contact_companies'
      end
    end
  end

  namespace 'suppliers' do
    resource :dashboard, controller: :dashboard, only: :show
    resources :purchase_orders, controller: :purchase_orders, only: %i[index show]
    resource :profile, controller: :profile, except: [:show, :index]
    resources :rfq, controller: :rfq do
      collection do
        get 'edit_supplier_rfqs'
        get 'edit_rfq'
        patch 'update_ips'
      end
    end

    resources :products, controller: :products do
      collection do
        get 'index'
      end
      member do
        get 'show'
        post 'update_price'
      end
    end

    resources :companies do
      collection do
        get 'choose_company'
        get 'contact_companies'
      end
    end

    resource 'sign_in_steps', controller: 'sign_in_steps' do
      post 'reset_current_company'
      get 'edit_current_company'
      patch 'update_current_company'
    end

    resource :session, controller: :sessions do
      get 'edit_current_company'
      get 'set_current_company'
    end
  end
end
