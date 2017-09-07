Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resources :stops do
  	collection do
  	  get 'initial_stop'
  	  get 'stop_type'
  	  get 'person_details'
  	end
  end
end
