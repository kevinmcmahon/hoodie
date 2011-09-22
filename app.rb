require 'rubygems'
require 'sinatra'
require 'haml'
require 'border_patrol'

# Helpers
require './lib/render_partial'
require './lib/map_hacks'

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml

# Application routes
get '/' do
  haml :index, :layout => :'layouts/application'
end

get '/about' do
  haml :about, :layout => :'layouts/page'
end

get '/contact' do
  haml :contact, :layout => :'layouts/page'
end

post '/hood' do
  @address = params[:address]
  @hood_result = MapHacks.processQuery(@address)
  haml :hood, :layout => :'layouts/map'
end