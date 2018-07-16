Rails.application.routes.draw do
  root :to => 'overseers/dashboard#show'
  get '/overseers', to: redirect('/overseers/dashboard'), as: 'overseer_root'

  namespace 'overseers' do
    resource :dashboard, :controller => :dashboard
    resources :accounts do
      namespace :accounts do
        resources :companies
        resources :contacts
        resources :addresses
      end
    end
  end

end
