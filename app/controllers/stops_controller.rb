class StopsController < ApplicationController
  include HTTParty

  def index
  
  end
  
  
  def initial_stop
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.166.216:3000#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response
    raise response.inspect
    
  end
  
  def stop_type
  
  end
  
  def personal_details
  
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
