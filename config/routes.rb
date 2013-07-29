LinguisticExplorer::Application.routes.draw do
  resources :forum_groups, :except => [:index, :show]
  resources :forums, :except => :index do
    resources :topics, :shallow => true, :except => :index do
      resources :posts, :shallow => true, :except => [:index, :show]
    end
    root :to => 'forum_groups#index', :via => :get
  end

  devise_for  :users, :controllers => { :registrations => "users/registrations" }
  root        :to => 'home#index'

  match "/groups/:group_id/lings/depth/:depth" => "lings#depth", :as => "group_lings_depth"
  match "/groups/:group_id/lings/depth/:depth/dict" => "lings#dict"
  match "/groups/:group_id/properties/dict" => "properties#dict"
  match "/groups/:group_id/memberships/dict" => "memberships#dict"

  resources :groups do
    member do
      get 'info'
    end

    resources :searches do
      collection do
        get 'preview'
        get 'lings_in_selected_row'
        get 'geomapping'
      end
    end

    resources :search_comparisons, :only => [:new, :create, :preview]

    resources :lings do
      member do
        get 'set_values'
        get 'supported_set_values'
        post 'supported_submit_values'
        post 'supported_submit_values_multiple'
      end
    end

    resources :lings_properties, :only => [:show, :index, :destroy]
    resources :examples_lings_properties, :except => [:edit, :update]
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
