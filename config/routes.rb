  require 'resque/server'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :stops do
  	collection do
  	  get 'initial_stop'
  	  get 'stop_type'
  	  get 'person_details'
      get 'location'
  	  get 'single_role'
  	  get 'multiple_role'
  	end
  end

	get '/login' => 'sign_in#login'

	post '/after_login' => "sign_in#after_login"

  get 'download_pdf', to: "stops#download_pdf"

	# Of course, you need to substitute your application name here, a block
	# like this probably already exists.
	Ab953Web::Application.routes.draw do
	  mount Resque::Server.new, at: "/resque"
	end


end
