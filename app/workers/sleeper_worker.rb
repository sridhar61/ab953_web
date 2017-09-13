class SleeperWorker
   #include HTTParty	
   @queue = :snippets_queue

  def self.perform(id)
    puts "-------------------------------  --------------"
    call = '/search_ori.json'
    @result = HTTParty.post("http://localhost:3000#{call}", 
    :body => { :subject => 'This is the screen name'
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } ) 
  end

end

