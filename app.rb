require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'haml'
require 'pony'
require 'json'
require 'data_mapper'
require 'sinatra/config_file'
require 'awesome_print'

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

DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://ypntkm_oewsph:86ca73ec@spacialdb.com:9999/ypntkm_oewsph")
    
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

get '/hood' do
  @hood_result = params[:address].nil? ? MapHacks.processLatLong(params[:lat],params[:lng]) : MapHacks.processQuery(params[:address])
  
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

get '/ward?' do
   haml :ward, :layout => :'layouts/page'
end 

get '/lookupward' do
  @lat = params['lat']
  @lng = params['lng']
  puts 'Latitude  : ' + @lat
  puts 'Longitude : ' + @lng
  
  @ward = MapHacks.getWard(@lat,@lng)

  content_type :json
  { :ward => @ward['ward'], :alderman => @ward['alderman']}.to_json
end

get '/lookup' do
  @lat = params['lat']
  @lng = params['lng']
  puts 'Latitude  : ' + @lat
  puts 'Longitude : ' + @lng
  
  @hood_result = MapHacks.processLatLong(@lat,@lng)
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
