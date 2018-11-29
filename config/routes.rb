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
      get 'serializer'
      get 'migrations'
      get 'console'
    end

    resources :remote_requests do
      member do
        get 'show'
      end
    end

    resources :callback_requests do
      member do
        get 'show'
      end
    end

    resources :reports
    resources :activities, except: [:show]
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
        get 'login_as_contact'
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
      end
    end

    resources :addresses do
      collection do
        get 'autocomplete'
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
      collection do
        get 'autocomplete'
        get 'pending'
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
        get 'autocomplete'
      end

      scope module: 'sales_orders' do
        resources :comments
      end
    end

    resources :purchase_orders do
      collection do
        get 'export_all'
        get 'autocomplete'
      end
    end

    resources :sales_invoices do
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

    resources :inquiries do
      member do
        get 'edit_suppliers'
        post 'update_suppliers'
        get 'calculation_sheet'
        get 'export'
        get 'stages'
      end

      collection do
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

        resources :purchase_orders do

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

    resources :warehouses
  end

  namespace 'customers' do
    resources :reports do
      member do
      end

      collection do
        get 'quarterly_purchase_data'
      end
    end

    resource :dashboard, :controller => :dashboard
    resources :cart_items, only: %i[new create destroy]
    resources :customer_orders, only: %i[index create show] do
      member do
        get 'order_confirmed'
      end
    end
    resources :quotes, :controller => :sales_quotes, only: %i[index show]
    resources :orders, :controller => :sales_orders, only: %i[index show]
    resources :invoices, :controller => :sales_invoices, only: %i[index show]
    resources :products, only: %i[index show] do
      collection do
        get 'most_ordered_products'
      end
    end

    resource :cart, :controller => :cart, only: [:show] do
      collection do
        get 'checkout'
      end
    end
  end
end
