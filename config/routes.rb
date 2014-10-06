Rails.application.routes.draw do
  
  
  #------Basic Version---------------
  root 'praxeng#landing_page'
  get '/consent' => 'praxeng#consent'
  get '/practice' => 'praxeng#practice'
  get '/privacy' => "praxeng#privacy"
  get '/about' => "praxeng#about"
  post '/save_response' => 'praxeng#save_response'
  post '/save_response_consent' => 'praxeng#save_response_consent' 
  
  #-----------MDP version-------------
  get '/mdp' => 'praxeng_mdp#landing_page'
  get '/mdp/consent' => 'praxeng_mdp#consent'
  get '/mdp/practice' => 'praxeng_mdp#practice'
  get '/mdp/privacy' => "praxeng_mdp#privacy"
  get '/mdp/about' => "praxeng_mdp#about"
  post '/mdp/save_response' => 'praxeng_mdp#save_response'
  post '/mdp/save_response_consent' => 'praxeng_mdp#save_response_consent'
  
  # get 'english-comprehension-practice/thankyou' => "main#thankyou"


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
