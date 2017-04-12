Rails.application.routes.draw do
  resources :posts
  resources :addresses
	match '#' => 'users#profile', :as => :user_root, via: [:get]
  	
  	match 'profile', to: 'users#profile', via: [:get]

	devise_for :users, controllers: { registrations: "registrations" }
	root to: "home#home_page"

	devise_scope :user do
  		get 'log_in', to: 'devise/sessions#new'
	end

	devise_scope :user do
  		get "sign_up" => "devise/registrations#new"
	end

	devise_scope :user do
  		delete 'logout', to: 'devise/sessions#destroy'
	end	
	
	match '/:id', to: 'users#show#:id', via: [:get] 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
