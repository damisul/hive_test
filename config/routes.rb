Rails.application.routes.draw do
  resources :restocking_shipments, only: [:create]
end
