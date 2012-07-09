SnapA::Application.routes.draw do

  match '/admin/users', to: 'users#index'
  match '/admin/reports', to: 'reports#index'
  match '/admin/photos', to: 'photos#index'
  match '/admin/news', to: 'notifications#index'

  match 'upload/pc' , to: 'photos#pc'

  match '/admin', to: 'users#admin_page'
  match '/search/name/' , to: 'searchs#search_name'
  match '/search/box/',to: 'searchs#search_box'
  match '/search', to: 'searchs#search_page'
  match '/toggle', to: 'users#toggle_active'

  resources :users do
      member do
      get :following, :followers
    end
  end
  resources :boxes do
    member do 
      get :followers
    end
  end
  resources :password_resets, only: [ :new, :create, :edit, :update ]
  resources :categories
  resources :photos
  resources :sessions, only: [ :new, :create, :destroy]
  resources :user_box_follows, only: [ :create, :destroy]
  resources :user_user_relationships, only: [ :create, :destroy]
  resources :authentications

  root to: 'static_pages#home'


  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/about', to: 'static_pages#about'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/resetpassword', to: 'password_resets#new'
  # match '/editpassword', to: 'password_resets#edit'

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider/destroy' => 'authentications#destroy'

  match '/upload', to: 'photos#new'
  match '/upload/facebook', to: 'photos#facebook'
  match '/upload/url', to: 'photos#url'
  match '/upload/pc', to: 'photos#pc'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
