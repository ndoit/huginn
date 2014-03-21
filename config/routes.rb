Rails.application.routes.draw do
  get "guide/index"
  get "terms" => 'terms#index'
  get "terms/:id" => 'terms#show'
  get "terms/auth/log/out" => 'terms#logout'
  get "terms/auth/:id" => 'terms#authenticated_show'
  get "offices/:id" => 'offices#show'
  get "search/:search_for" => 'search#show'
  get "reports" => 'reports#index'
  get "/reports/business_objects" => 'reports#business_objects'
  get "/reports/powerview" => 'reports#powerview'
  get "/reports/tableau" => 'reports#tableau'
  get "/reports/ssrs" => 'reports#ssrs'
  get "/reports/access_denied" =>'reports#access_denied'
  get "search" => 'search#index'
  get "cas_proxy_callback/receive_pgt" => 'cas_proxy_callback#receive_pgt'
  get "cas_proxy_callback/retrieve_pgt" => 'cas_proxy_callback#retrieve_pgt'

  root 'guide#index'

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