class StopsController < ApplicationController
  include HTTParty

  def index
  
  end
  
  
  def initial_stop
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.167.162:3000#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response   
    
  end
  
  def stop_type
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.167.162:3000#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response  
    
  end
  
  def person_details
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.167.162:3000#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response 
  
  end
  
  def location
  
  end
  
  def stop_reason
  
  end
  
  def post_stop_action
  
  end
  
  def search
  
  end
  
  
end
