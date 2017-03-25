Rails.application.routes.draw do
	devise_for :users
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
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
