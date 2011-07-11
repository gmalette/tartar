Tartar::Application.routes.draw do
  resources :chats, :only => [:index, :create]

  root :to => "chats#index"
end
