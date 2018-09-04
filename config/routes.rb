Rails.application.routes.draw do
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  devise_for :overseers, controllers: {sessions: 'overseers/sessions'}

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard
    resources :brands
    resources :categories
    resources :suppliers
    resources :overseers

    resources :products do
      member do
        get 'best_prices'
      end

      collection do
        get 'autocomplete'
        get 'pending'
      end

      scope module: 'products' do
        resources :comments
      end
    end

    resources :inquiries do
      member do
        get 'edit_suppliers'
        post 'update_suppliers'
      end

      scope module: 'inquiries' do
        resources :sales_quotes do
          member do
            get 'new_revision'
          end

          scope module: 'sales_quotes' do
            resources :sales_orders
          end
        end

        resources :sales_orders

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
      end
    end

    resources :accounts do
      scope module: 'accounts' do
        resources :companies
        resources :contacts
        resources :addresses
      end
    end
  end
end
