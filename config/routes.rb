Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/pricing',    to: 'static_pages#pricing'
  get    '/letsbepartners',    to: 'static_pages#letsbepartners'
  get    '/howtouse',    to: 'static_pages#howtouse'
  get    '/why',    to: 'static_pages#why'
  get    '/wakeupnote',   to: 'static_pages#wakeupnote'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/termsofuse', to: 'static_pages#termsofuse'
  get    '/features', to: 'static_pages#features'
  get    '/accessrightserror', to: 'static_pages#accessrightserror'
  get    '/signup',  to: 'users#new'
  post    '/signup',  to: 'users#new'
  get    '/editpwd',  to: 'users#editpwd'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  get     '/resendactivation',        to: 'users#resendactivation'
  get     '/resendactivationsbmt',    to: 'users#resendactivation'
  post    '/resendactivationsbmt',    to: 'users#resendactivationsbmt'

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

  get     '/api_read_step_bc/:ref',    to: 'barcode#apireadstepbc'
  get     '/checkbc',    to: 'barcode#checkbc'
  post	  '/check_step'   => 'barcode#checkstep'
  get     '/check_step' => redirect("/")
  post	  '/check_step_home'   => 'barcode#checkstephome'
  get     '/check_step_home' => redirect("/")

  #Route for Partner Controller
  get     '/dashboard',    to: 'partner#dashboard'
  post     '/dashboard',    to: 'partner#dashboard'
  get     '/dashboardbyclient',    to: 'partner#dashboardbyclient'
  get     '/dashboardbymother',    to: 'partner#dashboardbymother'

  post     '/dashboardbyclient',    to: 'partner#dashboardbyclient'
  post     '/dashboardbymother',    to: 'partner#dashboardbymother'
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

  #Route for mothers
  get     '/mothermng',    to: 'mother#mothermng'
  post    '/createmother',    to: 'mother#createmother'
  post    '/mark_step_mother',    to: 'mother#markstepmother'

  post    '/associate_mother' => 'mother#associatemother'
  get     '/associate_mother' => 'mother#associatemother'

  post    '/dissociate_mother' => 'mother#dissociatemother'
  get     '/dissociate_mother' => 'mother#dissociatemother'

  post    '/incident_mother' => 'mother#incidentmother'
  get     '/incident_mother' => 'mother#incidentmother'



  # File: config/routes.rb
  if Rails.env.production?
    get "/404", to: "errors#not_found", :defaults => { :format => 'html' }
    get "/422", to: "errors#unacceptable", :defaults => { :format => 'html' }
    get "/500", to: "errors#internal_error", :defaults => { :format => 'html' }
  end

end
