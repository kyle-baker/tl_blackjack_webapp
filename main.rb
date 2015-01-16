require 'rubygems'
require 'sinatra'

# Set port for compatability with Nitrous.IO 
configure :development do   
  set :bind, '0.0.0.0'   
  set :port, 3000 # Not really needed, but works well with the "Preview" menu option
end

set :sessions, true
 
get '/' do
  "Hello World!"
end

get '/test' do
  "From testing action! " + params[:some].to_s
end
