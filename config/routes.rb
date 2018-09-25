Rails.application.routes.draw do
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  devise_for :overseers, controllers: {sessions: 'overseers/sessions', omniauth_callbacks: 'overseers/omniauth_callbacks'}

  namespace 'callbacks' do
    resources :sales_orders do
      collection do
        patch 'update'
      end
    end
    resources :sales_invoices do
      collection do
        patch 'update'
      end
    end
    resources :item_weights do
      collection do
        patch 'update'
      end
    end
    resources :shipments do
      collection do
        patch 'update'
      end
    end

    resources :receipt_collections

    resources :bank_masters

    resources :activities

    get 'login' => '/callbacks/sessions#new'
  end

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard
    resources :overseers

    resources :suppliers do
      collection do
        get 'autocomplete'
      end
    end

    resources :brands do
      collection do
        get 'autocomplete'
      end
    end

    resources :categories do
      collection do
        get 'autocomplete'
      end
    end

    resources :tax_codes do
      collection do
        get 'autocomplete'
      end
    end

    resources :products do
      member do
        get 'customer_bp_catalog'
        get 'best_prices_and_supplier_bp_catalog'
      end

      collection do
        get 'autocomplete'
        get 'pending'
      end

      scope module: 'products' do
        resources :comments
      end
    end

    resources :sales_orders do
      collection do
        get 'pending'
      end

      scope module: 'sales_orders' do
        resources :comments
      end
    end

    resources :inquiries do
      member do
        get 'edit_suppliers'
        post 'update_suppliers'
        get 'export'
      end

      scope module: 'inquiries' do

        resources :comments

        resources :sales_orders do
          member do
            get 'new_revision'
            get 'new_confirmation'
            post 'create_confirmation'
          end
        end

        resources :sales_quotes do
          member do
            get 'new_revision'
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
      scope module: 'companies' do
        resources :addresses
        resources :contacts
      end
    end

    resources :accounts do
      scope module: 'accounts' do
        resources :companies
      end
    end
  end
end
