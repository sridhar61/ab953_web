class StopsController < ApplicationController
  include HTTParty
   
  
  def index
  
  end
  
  
  def initial_stop
    #raise @queue.inspect
    #Resque::Job.create(select_queue(params), self, 5)
    if true 

      Resque.enqueue(SleeperWorker, 5)
      respond_to do |format|
        format.html { redirect_to stop_type_stops_path, notice: 'Snippet was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
    end  
  end

  def stop_type

  end

  def stop_type_submit
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
