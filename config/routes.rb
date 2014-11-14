Rails.application.routes.draw do
  
  root 'welcome#index'

  

  get '/up' => 'reports#upload_test'
  post '/up' => 'reports#upload', as: :report_image_upload

  get "browse" => 'guide#index', as: :browse
  get "browse/:selected_resources" => 'guide#index'

  get "guide_search" => 'guide#search'

  get "terms" => 'terms#index'

  get "/login" => 'session#login'
  get "/logout" => 'session#logout'

    #get "terms/partial_search" => 'terms#partial_search'
  get "terms/partial_search" => 'terms#partial_search'
  get "terms/:id" => 'terms#show'
  put "terms/:id" => 'terms#update'  #BMR
  delete "terms/:id" => 'terms#destroy'  #SMM
  post "terms" => 'terms#create' #SMM


 # get "terms/:search1" => 'terms#search_string'
  #get "terms/auth/log/out" => 'session#logout'
  get "terms/auth/:id" => 'terms#authenticated_show'


  get "offices" => 'offices#index'

  get "offices/partial_search" => 'offices#partial_search'
  get "offices/:id" => 'offices#show'
  put "offices/:id" => 'offices#update'  #SMM
  delete "offices/:id" => 'offices#destroy'  #SMM
  post "offices" => 'offices#create' #SMM

  get "search/:search_for" => 'search#show'
  get "reports/:id" => 'reports#show'
  post "reports" => 'reports#create' #SMM
  get "reports" => 'reports#index'
  put "reports/:id" => 'reports#update'  #SMM
  delete "reports/:id" => 'reports#destroy'  #SMM
  get "reports/partial_search" => 'reportss#partial_search'


  get "/reports/access_denied" =>'reports#access_denied'
  get "search" => 'search#index'
  get "cas_proxy_callback/receive_pgt" => 'cas_proxy_callback#receive_pgt'
  post "cas_proxy_callback/receive_pgt" => 'cas_proxy_callback#receive_pgt'
  put "cas_proxy_callback/receive_pgt" => 'cas_proxy_callback#receive_pgt'
  get "cas_proxy_callback/retrieve_pgt" => 'cas_proxy_callback#retrieve_pgt'



  resources :results, only: [:index]
  #root to:  "results#index"


  
  #root  'terms#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
