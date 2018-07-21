Rails.application.routes.draw do
  mount Maily::Engine, at: '/maily'
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  devise_for :overseers, controllers: { sessions: 'overseers/sessions' }

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard

    resources :brands
    resources :products
    resources :categories

    resources :inquiries do
      scope module: 'inquiries' do
        resources :rfqs do
          collection do
            get 'select_suppliers'
            post 'suppliers_selected'
            get 'generate_rfqs'
            post 'rfqs_generated'
            get 'rfqs_generated_mailer_preview'
          end
        end
      end
    end

    resources :companies do
      scope module: 'companies' do
        resources :addresses
        resources :inquiries
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
