Rails.application.routes.draw do

  root 'static#index'

  namespace :api do
    get 'hello', to: 'students#index'
    post 'student/authenticate', to: 'students#authenticate'
    put  'student', to: 'students#update'
    post 'student/logout', to: 'students#logout'
    post 'student/cookie', to: 'students#cookie'

    post 'student/subjects', to: 'subjects#list' 
    post 'subject/:code/data', to: 'subjects#data'
    post 'subject/:code/check', to: 'subjects#checkhash'
    post 'subject/:code/text', to: 'subjects#text'
    post 'subject/:code/html', to: 'subjects#html'
    post 'subject/:code/file', to: 'subjects#file'

    post 'portal/timetable', to: 'portals#timetable'

    post 'version/android', to: 'versions#android'
    post 'version/ios', to: 'versions#ios'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


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
