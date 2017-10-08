class StopsController < ApplicationController
  include HTTParty

  def index
    #@basis_search_options = Constant.get_all_constants
  end


  def initial_stop
    #raise @queue.inspect
    #Resque::Job.create(select_queue(params), self, 5)
    if true
      #Resque.enqueue(SleeperWorker, 5)
=begin
      respond_to do |format|
        format.html { redirect_to stop_type_stops_path, notice: 'Snippet was successfully destroyed.' }
        format.json { head :no_content }
      end
=end
    else
    end
  end

  def stop_type

  end

  def download_pdf
    #to send a file
    send_file "#{Rails.root}/app/assets/docs/Физика.pdf", type: "application/pdf", x_sendfile: true
  end

  def single_role
    #@cookies = params[:cookies]
    #@parsed_cookie = JSON.parse(@cookies)
  end


  def multiple_role
    #@cookies = params[:cookies]
    #@parsed_cookie = JSON.parse(@cookies)
  end

  def stop_type_submit
    call = '/data_validation.json'
    url =   HTTParty.get("http://192.168.167.162:3001#{call}",
      :headers => {'ContentType' => 'application/json'})
    response = url.parsed_response

  end

  def person_details
    #call = '/data_validation.json'
    #url =   HTTParty.get("http://192.168.167.162:3001#{call}",
     # :headers => {'ContentType' => 'application/json'})
    #response = url.parsed_response

  end

  def location

  end

  def reason_for_stop

  end

  def post_stop_action

  end

  def search

  end

  def basis_for_search

  end

  def k12_related

  end

  def result_of_stop

  end

  def contraband_evidence

  end

end
