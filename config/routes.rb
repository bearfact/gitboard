Gitboard::Application.routes.draw do

  #get "log_out" => "sessions#destroy", :as => "log_out"
  #post "log_in" => "sessions#create", :as => "log_in"
  #get "sign_up" => "users#new", :as => "sign_up"
  get "current_user" => "sessions#show", :as => "current_user"
  get 'signin' => "welcome#unauthenticated",  :as => "signin"
  get 'beta' => "welcome#beta", :as => "beta"
  post 'agree' => "welcome#agree", :as => "agree"
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'sign_out', to: 'sessions#destroy'
  post '/issueshook' => 'issueshook#triggered'
  post '/pusher/auth' => 'pusher#auth'

  resources :users
  resources :sessions
  resources :repositories
  resources :sprints do
    resources :sprint_issues, only: [:index, :update]
  end
  resources :issues_priorities, :only => [:index]
  get 'milestones', to: 'milestones#index'
  get 'github_owners', to: 'github_owners#index'
  get 'github_owners/:owner/github_repositories', to: 'github_repositories#index'
  get 'github_owners/:owner/github_repositories/:repo/hooks', to: 'github_repositories#hooks'
  get 'app_bootstrap', to: 'app_bootstrap#index'
  resources :owners, :only => [:index] do
    resources :users, :only => [:index]
    resources :repositories, :only => [:index, :update, :show] do
      resources :issues
      #get 'users', :on => :member
    end
  end

  resources :add_issues_comment_events, :only => [:create]
  resources :change_issues_status_events, :only => [:create]
  resources :change_issues_priority_events, :only => [:create]
  resources :assign_issue_events, :only => [:create]
  resources :release_issue_events, :only => [:create]
  resources :change_issues_milestone_events, :only => [:create]
  resources :change_issues_sprint_events, :only => [:create]
  resources :change_webhook_events, :only => [:create]





  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):


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
