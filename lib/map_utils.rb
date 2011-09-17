require 'rubygems'
require 'open-uri'
require 'json'
require 'net/http'

module MapUtils
  def self.address_geocode(query)
    base_url = "http://maps.googleapis.com/maps/api/geocode/json"
    url = "#{base_url}?address=#{URI.encode(query)}&sensor=false"
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
  
    # we convert the returned JSON data to native Ruby
    # data structure - a hash
    result = JSON.parse(data)
  
    # if the hash has 'Error' as a key, we raise an error
    if result.has_key? 'Error'
      raise "web service error"
    end
    return {'location' => result['results'][0]['geometry']['location'], 'formatted_address' => result['results'][0]['formatted_address']}
  end
end