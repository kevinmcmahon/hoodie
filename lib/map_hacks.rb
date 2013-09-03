require 'rubygems'
require 'nokogiri'
require 'geocoder'
require './lib/map_utils'

module MapHacks
    
    def self.in_chicago?(lat,lng)
      sql = 
      "SELECT EXISTS(SELECT * FROM boundary WHERE ST_Contains(geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326)));"

      result = DataMapper.repository(:default).adapter.select sql
      result[0]
    end
    
    def self.getHood(lat,lng)
      sql =  
      "SELECT pri_neigh AS neighborhood 
      FROM hoods 
      WHERE ST_Contains(geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326))
      LIMIT 1;"

      result = DataMapper.repository(:default).adapter.select sql
      result[0]
    end
    
    def self.getWard(lat,lng)
      sql =  "SELECT ward, alderman, ward_phone, hall_phone, address AS ward_address, hall_offic AS hall_address FROM wards 
      WHERE ST_Contains(geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326))
      LIMIT 1;"

      result = DataMapper.repository(:default).adapter.select sql
      result[0]
    end
    
    def self.getPoliceDistrict(lat,lng)
      sql = 
      "SELECT police_stations.name AS district FROM police_stations
       INNER JOIN police_districts
       ON police_districts.dist_num = police_stations.descriptio
       WHERE ST_Contains(police_districts.geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326));"

       result = DataMapper.repository(:default).adapter.select sql
       result[0]
    end
    
    def self.getIlCongress(lat,lng)
      sql = 
      "SELECT district FROM il_congress
       WHERE ST_Contains(geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326));"

       result = DataMapper.repository(:default).adapter.select sql 
       result[0]
    end

    def self.getIlSenate(lat,lng)
      sql = "SELECT district FROM il_senate
             WHERE ST_Contains(geom,ST_GeomFromText('POINT(#{lng} #{lat})', 4326));"

      result = DataMapper.repository(:default).adapter.select sql
      result[0]
    end
    
    def self.processQuery(query)
      result = Geocoder.search(query)
      self.processAddress(result)
    end
    
    def self.processLatLong(lat,lng) 
      result = Geocoder.search([lat,lng])
      self.processAddress(result)
    end
    
    def self.processAddress(result)
      formatted_address = result[0].formatted_address
      lat = result[0].latitude
      lng = result[0].longitude

      if self.in_chicago?(lat,lng)
        puts "#{formatted_address} is in Chicago."

        ward = self.getWard(lat,lng)[0]
        hood = self.getHood(lat,lng)
        police = self.getPoliceDistrict(lat,lng)
        ushouse = self.getIlCongress(lat,lng).sub! /\A0+/, ''
        ilsenate = self.getIlSenate(lat,lng)

        response = {'status' => :found, 'ward' => ward, 'hood' => hood, 'formatted_address' => formatted_address,
          'lat' => lat, 'lng' => lng, 'police' => police,
          'ushouse' => ushouse, 'ilsenate' => ilsenate}
      else
        puts "#{formatted_address} is NOT in Chicago."
        response = {'status' => :notfound}
      end

      return response
    end
end