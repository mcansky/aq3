IIIaquarii::Application.routes.draw do |map|
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
  resources :aq_repositories, :users, :user_sessions, :ssh_keys, :rights, :beans

  # login routes
  match "/logout" => 'user_sessions#destroy', :as => "logout"
  match "/login" => 'user_sessions#new', :as => "login"
  match "/signup" => 'users#new', :as => "signup"

  # ssh key export
  match "/ssh_keys/export/:id" => "ssh_keys#export"

  # repo join
  match "/aq_repositories/join/:id" => "aq_repositories#join"

  # right accept and reject
  match "/rights/accept/:id" => "rights#accept"
  match "/rights/reject/:id" => "rights#reject"

  # fork
  match "/aq_repositories/fork/:id" => "aq_repositories#fork"

  # browse
  match "/aq_repositories/browse/:id/(:dir)", :to => "aq_repositories#show", :dir => /(.*)/

  # view a file
  match "/aq_repositories/view_file/:id/(:path)", :to => "aq_repositories#view_file", :path => /(.*)/

  # commit log
  match "/aq_repositories/commits/:id", :to => "aq_repositories#show_commits"
  match "/aq_repositories/commits/:id/:commit_id", :to => "aq_repositories#show_commit"

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
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
  # root :to => "welcome#index"
  root :to => "application#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
