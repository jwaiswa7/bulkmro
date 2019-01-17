Rails.application.routes.draw do
  mount Maily::Engine, at: '/maily' if Rails.env.development?

  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'
  get '/customers', to: redirect('/customers/dashboard'), as: 'customer_root'

  devise_for :overseers, controllers: {sessions: 'overseers/sessions', omniauth_callbacks: 'overseers/omniauth_callbacks'}
  devise_for :contacts, controllers: {sessions: 'customers/sessions'}, path: 'customers'

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

    resources :purchase_orders
    resources :products

    get 'login' => '/callbacks/sessions#new'
  end

  namespace 'overseers' do
    resources :attachments
    resource :dashboard, :controller => :dashboard do
      get 'chewy'
      get 'reset_index'
      get 'serializer'
      get 'migrations'
      get 'console'
    end

    resources :remote_requests do
      member do
        get 'show'
      end
      collection do
        get 'resend_failed_requests'
      end
    end

    resources :callback_requests do
      member do
        get 'show'
      end
    end

    resources :reports
    resources :company_creation_requests do
      member do
        post 'exchange_with_existing_company'
      end
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
      end
      member do
        get 'approve'
        get 'reject'
      end
    end
    resource :profile, :controller => :profile, except: [:show, :index]
    resources :overseers, except: [:show]

    resources :suppliers do
      collection do
        get 'autocomplete'
      end
    end

    resources :contacts do
      collection do
        get 'autocomplete'
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
      end
    end

    resources :categories do
      collection do
        get 'autocomplete'
        get 'autocomplete_closure_tree'
      end
    end

    resources :products do
      collection do
        get 'autocomplete'
      end
      member do
        get 'customer_bp_catalog'
        get 'best_prices_and_supplier_bp_catalog'
        get 'sku_purchase_history'
        get 'resync'
        get 'resync_inventory'
      end

      collection do
        get 'autocomplete'
        get 'pending'
        get 'export_all'
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
      scope module: 'po_requests' do
        resources :payment_requests
      end

      collection do
        get 'autocomplete'
        get 'pending'
      end

    end

    resources :invoice_requests do
      collection do
        get 'autocomplete'
        get 'pending'
        get 'completed'
      end
    end

    resources :sales_orders do
      member do
        get 'new_purchase_order'
      end

      collection do
        get 'pending'
        get 'export_all'
        get 'drafts_pending'
        get 'export_rows'
        get 'export_for_logistics'
        get 'export_for_sap'
        get 'autocomplete'
        get 'not_invoiced'
      end

      scope module: 'sales_orders' do
        resources :comments
      end
    end

    resources :purchase_orders do
      member do
        get 'edit_internal_status'
        patch 'update_internal_status'
      end

      collection do
        get 'export_all'
        get 'autocomplete'
        get 'material_readiness_queue'
        get 'material_pickup_queue'
        get 'material_delivered_queue'
      end
    end

    resources :sales_invoices do
      member do
        get 'edit_pod'
        patch 'update_pod'
      end
      collection do
        get 'export_all'
        get 'export_rows'
        get 'export_for_logistics'
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

      collection do
        get 'payments'
        get 'refresh_payment'
      end
    end

    resources :inquiries do
      member do
        get 'edit_suppliers'
        post 'update_suppliers'
        get 'calculation_sheet'
        get 'export'
        get 'stages'
      end

      collection do
        get 'new_from_customer_order'
        get 'autocomplete'
        get 'index_pg'
        get 'smart_queue'
        get 'export_all'
      end

      scope module: 'inquiries' do
        resources :comments
        resources :email_messages
        resources :sales_shipments
        resources :purchase_orders

        resources :sales_invoices do
          member do
            get 'edit_mis_date'
            patch 'update_mis_date'

            get 'duplicate'
            get 'triplicate'
            get 'make_zip'
          end
        end

        resources :sales_orders do
          member do
            get 'edit_mis_date'
            patch 'update_mis_date'

            get 'new_revision'
            get 'new_confirmation'
            get 'proforma'
            post 'create_confirmation'
            post 'resync'
            get 'fetch_order_data'
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

    resources :companies do
      collection do
        get 'autocomplete'
        get 'export_all'
      end

      scope module: 'companies' do
        resources :customer_orders

        resources :customer_products do
          collection do
            post 'generate_catalog'
            post 'destroy_all'

            get 'autocomplete'
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
        resources :sales_invoices

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
      end
      scope module: 'accounts' do
        resources :companies
      end
    end


    resources :warehouses do
      collection do
        get 'autocomplete'
      end
    end
    resources :payment_options

    resources :payment_requests do
      collection do
        get 'completed'
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

  end

  namespace 'customers' do
    resource 'sign_in_steps', controller: 'sign_in_steps' do
      post 'reset_current_company'
      get 'edit_current_company'
      patch 'update_current_company'
    end

    resources :reports, only: %i[index] do
      member do
      end

      collection do
        get 'monthly_purchase_data'
        get 'revenue_trend'
        get 'unique_skus'
        get 'order_count'
        get 'categorywise_revenue'
      end
    end

    resource :dashboard, :controller => :dashboard
    resources :cart_items, only: %i[new create destroy update]
    resources :customer_orders, only: %i[index create show] do
      member do
        get 'order_confirmed'
        get 'approve_order'
      end

      collection do
        get 'pending'
        get 'approved'
      end

      scope module: 'customer_orders' do
        resources :comments
      end
    end
    resources :products, :controller => :customer_products, only: %i[index create show] do
      collection do
        get 'generate_all'
        get 'most_ordered_products'
        get 'autocomplete'
      end
    end

    resources :quotes, :controller => :sales_quotes, only: %i[index show] do
      member do
        post 'inquiry_comments'
      end
      scope module: 'sales_quotes' do
        resources :comments
      end
    end
    resources :orders, :controller => :sales_orders, only: %i[index show]
    resources :invoices, :controller => :sales_invoices, only: %i[index show]
    resource :checkout, :controller => :checkout do
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

    resource :cart, :controller => :cart, except: [:index] do
      collection do
        get 'checkout'
        patch 'update_billing_address'
        patch 'update_shipping_address'
        patch 'update_special_instructions'
        patch 'add_po_number'
        get 'empty_cart'
      end
    end

    resources :inquiries do
      scope module: 'inquiries' do
        resources :comments
      end
    end

    resources :companies do
      collection do
        get 'choose_company'
        get 'contact_companies'
      end
    end

  end
end
