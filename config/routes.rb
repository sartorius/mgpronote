Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  get     '/savebc',    to: 'barcode#savebc'
  post	  '/save_step'   => 'barcode#savestep'
  get     '/save_step' => redirect("/")

  get     '/checkbc',    to: 'barcode#checkbc'
  post	  '/check_step'   => 'barcode#checkstep'
  get     '/check_step' => redirect("/")


end
