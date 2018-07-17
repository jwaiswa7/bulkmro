Rails.application.routes.draw do
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  devise_for :overseers, controllers: { sessions: 'overseers/sessions' }

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard

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
