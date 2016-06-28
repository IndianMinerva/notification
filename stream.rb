require 'json'
require 'sinatra'

set :public_folder, Proc.new { File.join(root, "public") }
set server: 'thin'

get '/' do
	erb :index
end

get '/admin' do
	erb :admin
end

def timestamp
    Time.now.strftime("%H:%M:%S")
end

connections = []
notifications = []

get '/connect', provides: 'text/event-stream' do
    stream :keep_open do |out|
      connections << out

      #out.callback on stream close evt. 
      out.callback {
        #delete the connection 
        connections.delete(out)
      }
    end
end

post '/push' do
    puts params
    #Add the timestamp to the notification
    notification = params.merge( {'timestamp' => timestamp}).to_json

    notifications << notification

    notifications.shift if notifications.length > 10
    connections.each { |out| out << "data: #{notification}\n\n"}
end