require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'border_patrol'
require 'pony'
require 'json'
require 'data_mapper'
require 'sinatra/config_file'

# Helpers
require './lib/render_partial'
require './lib/map_hacks'

enable :sessions

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml

DataMapper::setup(:default, 'postgres://kmcmahon:0c791fd488@beta.spacialdb.com:9999/spacialdb_1321928742fe_kmcmahon')
#   "postgres://localhost:5432/chicago_db")
    
config_file "settings.yml"

# Application routes
get '/?' do
  haml :index, :layout => :'layouts/application'
end

get '/about/?' do
  @title = 'About'
  haml :about, :layout => :'layouts/page'
end

get '/contact/?' do
  @title = 'Contact'
  haml :contact, :layout => :'layouts/page'
end

post '/' do
  @address = params[:address]
  
  @hood_result = MapHacks.processQuery(@address)
  if @hood_result['status'] == :found
    haml :hood, :layout => :'layouts/map'
  else
    flash[:error] = 'Address not found'
    redirect '/'
  end
end

get '/lookup/:address' do
  @address = params[:address]
  @location = MapUtils.address_geocode(@address)
   
  @hood_result = MapHacks.processQuery(@address)

  if @hood_result['status'] == :found  
    content_type :json
    { :status => 'success', :ward => @hood_result['ward'], :hood => @hood_result['hood'],
      :address => @hood_result['formatted_address'], :lat => @hood_result['lat'].to_s, :long => @hood_result['lng'].to_s, 
      :police => @hood_result['police'], :ushouse => @hood_result['ushouse'], :ilsenate => @hood_result['ilsenate']}.to_json
  else
    content_type :json
    {:status => 'failed' }.to_json
  end
end

post '/feedback' do
  Pony.mail :to => settings.mailaddress,
            :from => params[:email],
            :subject => "Web Feedback",
            :body => erb(:feedback_email, :layout => false)
          
  Pony.mail :to => params[:email],
            :from => settings.mailaddress,
            :via => :smtp, 
            :via_options => {
              :address => 'smtp.gmail.com',
              :port => '587',
              :enable_starttls_auto => true,
              :user_name => settings.mailaddress,
              :password => settings.mailpassword,
              :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
              :domain => "HELO", # don't know exactly what should be here
            },
            :subject => "Thanks for the feedback.",
            :body => erb(:reply_email, :layout => false)
  @title = 'Thanks!'
  haml :thanks, :layout => :'layouts/page'
end