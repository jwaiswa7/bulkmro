Rails.application.routes.draw do
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  devise_for :overseers, controllers: { sessions: 'overseers/sessions' }

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard

    resources :brands

    resources :products do
      collection do
        get 'autocomplete'
      end
    end

    resources :categories
    resources :suppliers
    resources :overseers

    resources :inquiries do
      scope module: 'inquiries' do
        resources :imports do
          collection do
            get 'new_excel_import'
            post 'create_excel_import'
            get 'new_list_import'
            post 'create_list_import'
          end
        end

        resources :rfqs do
          collection do
            get 'edit_suppliers'
            post 'update_suppliers'
            get 'edit_rfqs'
            post 'update_rfqs'
            get 'edit_rfqs_mailer_preview'
            get 'edit_quotations'
            post 'update_quotations'
          end
        end

        resources :sales_quotes
      end
    end

    resources :sales_quotes do
      scope module: 'sales_quotes' do
        resources :sales_approvals
      end
    end

    resources :sales_approvals do
      scope module: 'sales_approvals' do
        resources :sales_orders
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
