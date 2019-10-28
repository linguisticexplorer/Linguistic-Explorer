LinguisticExplorer::Application.routes.draw do

  devise_for  :users, :controllers => { :registrations => "users/registrations" }

  root        :to => 'home#index'

  devise_scope :user do
    get     "users" => 'users/users#index'
    get     "users/:id" => 'users/users#show', :as => :user
    get     "users/:id/edit" => 'users/users#edit'
    put     "users/:id" => 'users/users#update'
    delete  "users/:id" => 'users/users#destroy'
  end

  get "/groups/activity/:id" => "groups#activity", :as => "groups_activity"

  # JSON Endpoints
  get "/groups/list" => "groups#list", :as => "groups_list"
  # get "lings/list"   => "lings#all_list", :as => "lings_list"
  # get "properties/list" => "properties#all_list", :as => "properties_list"

  get "/groups/:group_id/lings/depth/:depth" => "lings#depth", :as => "group_lings_depth"
  get "/groups/:group_id/lings/depth/:depth/list" => "lings#by_depth"
  get "/groups/:group_id/lings/:id/list" => "lings#by_depth"
  get "/groups/:group_id/lings/list" => "lings#by_depth",:as => "group_lings_by_depth"
  get "/groups/:group_id/list" => "lings#list" ,:as => "group_lings_all"

  get "/groups/:group_id/properties/list" => "properties#list"

  get "/groups/:group_id/memberships/list" => "memberships#list"
  get "/groups/:group_id/memberships/contributors" => "memberships#contributors", :as => "group_contributors"

  get "/groups/:group_id/lings_properties/exists" => "lings_properties#exists"
  get "/groups/:group_id/lings_properties/sureness" => "lings_properties#sureness"

  post "/groups/:group_id/maps" => "searches#geomapping"

  post "/groups/:group_id/searches/new" => "searches#new"

  namespace :groups do
    get 'user'
  end

  resources :groups do

    member do
      get 'activity'
    end

    resources :searches do
      collection do
        post 'preview'
        post 'get_results'
        # backward compatibility
        get 'preview'
      end
    end

    resources :search_comparisons, :only => [:new, :create, :preview]

    resources :lings do
      member do
        # get 'set_values'
        get 'supported_set_values'
        post 'supported_submit_values'
        # post 'supported_submit_values_multiple'
      end
    end

    resources :lings_properties, :only => [:show, :destroy]
    resources :examples_lings_properties, :except => [:index, :edit, :update]
    resources :properties, :examples, :categories, :memberships
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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
