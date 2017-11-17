  require 'resque/server'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :stops do
  	collection do
  	  get 'initial_stop'
  	  get 'stop_type'
  	  get 'person_details'
      get 'location'
      get 'reason_for_stop'
  	  get 'single_role'
  	  get 'multiple_role'
      get 'action_taken'
      get 'property_seized'
      get 'basis_for_search'
      get 'k12_related'
      get 'result_of_stop'
      get 'contraband_evidence'
      get 'stop_date_entry'
      get 'stop_summary'
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
