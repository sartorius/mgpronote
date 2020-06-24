Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/pricing',    to: 'static_pages#pricing'
  get    '/letsbepartners',    to: 'static_pages#letsbepartners'
  get    '/howtouse',    to: 'static_pages#howtouse'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  post     '/' => redirect("/")

  #Route for Barcode Controller

  get     '/getnext',    to: 'barcode#getnext'
  post	  '/save_bc'   => 'barcode#savebc'
  get     '/save_bc' => redirect("/")

  post	  '/save_step'   => 'barcode#savestep'
  get     '/save_step' => redirect("/")

  get     '/checkbc',    to: 'barcode#checkbc'
  post	  '/check_step'   => 'barcode#checkstep'
  get     '/check_step' => redirect("/")

  #Route for Partner Controller
  get     '/dashboard',    to: 'partner#dashboard'
  get     '/printtwelve',    to: 'partner#printtwelve'
  get     '/printnotrack',    to: 'partner#printnotrack'

  get     '/onebarcodemng',    to: 'partner#onebarcodemng'

end
