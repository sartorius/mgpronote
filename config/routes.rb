Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/pricing',    to: 'static_pages#pricing'
  get    '/letsbepartners',    to: 'static_pages#letsbepartners'
  get    '/howtouse',    to: 'static_pages#howtouse'
  get    '/why',    to: 'static_pages#why'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/termsofuse', to: 'static_pages#termsofuse'
  get    '/accessrightserror', to: 'static_pages#accessrightserror'
  get    '/signup',  to: 'users#new'
  get    '/editpwd',  to: 'users#editpwd'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  post     '/' => redirect("/")

  #Route for Barcode Controller POST checkstep/savebc

  get     '/getnext',    to: 'barcode#getnext'
  get     '/grpgetnext',    to: 'barcode#grpgetnext'

  post	  '/save_bc'   => 'barcode#savebc'
  get     '/save_bc' => redirect("/")

  post    '/grpsave_bc' => 'barcode#grpsavebc'
  get     '/grpsave_bc' => redirect("/")

  post    '/grpsave_step' => 'barcode#grpsavestep'
  get     '/grpsave_step' => 'barcode#grpsavestep'

  post	  '/save_step'   => 'barcode#savestep'
  get     '/save_step' => redirect("/")

  get     '/checkbc',    to: 'barcode#checkbc'
  post	  '/check_step'   => 'barcode#checkstep'
  get     '/check_step' => redirect("/")
  post	  '/check_step_home'   => 'barcode#checkstephome'
  get     '/check_step_home' => redirect("/")

  #Route for Partner Controller
  get     '/dashboard',    to: 'partner#dashboard'
  post     '/dashboard',    to: 'partner#dashboard'
  post     '/dashboardbyclient',    to: 'partner#dashboardbyclient'
  get     '/printtwelve',    to: 'partner#printtwelve'
  get     '/printnotrack',    to: 'partner#printnotrack'

  # Route to check one BC
  post	  '/onebarcodemng'   => 'partner#onebarcodemng'
  get	  '/onebarcodemng'   => 'partner#onebarcodemng'

  get     '/mainstatistics',    to: 'partner#mainstatistics'

  #Client manager
  get     '/signnewclient',    to: 'client#signnewclient'
  get     '/clientmng',    to: 'client#clientmng'
  post    '/clientmng',    to: 'client#newclient'
  post    '/createbarcodeforclient',    to: 'client#createbarcodeforclient'
  post    '/revokmngbarcodeforclient',    to: 'client#revokmngbarcodeforclient'


  #Route for Personal and Reseller Controller
  get     '/persoreseldash',    to: 'persoresel#dashboard'
  post	  '/seeone'   => 'persoresel#seeone'
  get     '/seeone'   => redirect("/")
  post	  '/addaddress'   => 'persoresel#addaddress'
  post	  '/addadditionnal'   => 'persoresel#addadditionnal'
  get     '/getmypartnerlist',    to: 'persoresel#getmypartnerlist'
  post    '/createbarcodebyclient',    to: 'persoresel#createbarcodebyclient'


  # File: config/routes.rb
  if Rails.env.production?
    get "/404", to: "errors#not_found", :defaults => { :format => 'html' }
    get "/422", to: "errors#unacceptable", :defaults => { :format => 'html' }
    get "/500", to: "errors#internal_error", :defaults => { :format => 'html' }
  end

end
