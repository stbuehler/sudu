Sudu::Application.routes.draw do
  devise_scope :user do
    get :new_user_session, :path => 'login', :to => "devise/sessions#new"
    post :user_session, :path => 'login', :to => "devise/sessions#create"
    match :destroy_user_session, :path => 'logout', :to => "devise/sessions#destroy", :via => [ :post, :delete ]

    get :new_user_registration, :path => 'sign_up', :to => "devise/registrations#new"
  end
  devise_for :users, :skip => :sessions, :controllers => { :registrations => 'users/registrations' } 

  resources :projects, :only => [:index,:show,:edit,:update,:create,:destroy] do
    delete :leave
    get :role_new, :path => 'roles/new', :action => :new_role
    delete :role_destroy, :path => "roles/:id", :action => :destroy_role
    
    post :lists, :action => :create_list
  end

  resources :todo_items, :path => :items, :only => [:show,:update,:destroy] do
    resources :todo_item_changes, :path => :changes, :only => [:show]
  end
  resources :todo_lists, :path => :lists, :only => [:show,:edit,:update,:destroy] do
    collection do
      post :create_item
    end
    get :item_new, :path => 'items/new', :action => :new_item
  end

  match :markdown, :controller => :markdown, :action => :index, :via => [ :get, :put, :post ]

  devise_scope :admin do
    get :new_admin_session, :path => 'admin/login', :to => "devise/sessions#new"
    post :admin_session, :path => 'admin/login', :to => "devise/sessions#create"
    match :destroy_admin_session, :path => 'admin/logout', :to => "devise/sessions#destroy", :via => [ :post, :delete ]
  end
  devise_for :admins, :path => "admin/admins", :skip => :sessions

  namespace :admin do
    authenticated :admin do
      get :dashboard_index, :path => '/', :to => "dashboard#index"
    end

    resources :projects, :only => [:index,:create,:show,:update,:destroy] do
      get :role_new, :path => 'roles/new', :action => :new_role
      delete :role_destroy, :path => "roles/:id", :action => :destroy_role
    end
    resources :admins, :only => [:index,:create,:show,:update,:destroy]
    resources :users, :only => [:index,:create,:show,:update,:destroy] do
      member do
        post :become
        post :lock
        post :unlock
        post :restore
        post :confirm
        post :make_admin
      end
    end
  end

  authenticated :user do
    # for authenticated users "root" is the dashboard, also this is the dashboard_index_path
    get :dashboard_index, :path => '/', :to => "dashboard#index"
  end

  devise_scope :user do
    # before login root is the login screen
    root :to => "devise/sessions#new"
  end

  devise_scope :admin do
    get :admin_root, :path => 'admin', :to => "devise/sessions#new"
  end


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
