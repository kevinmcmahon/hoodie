require 'rubygems'
require 'nokogiri'
require 'border_patrol'
require './lib/map_utils'

module MapHacks
    class InsufficientPointsToActuallyFormAPolygonError < ArgumentError; end
    class InsufficientPlacemarkArguments < ArgumentError; end

    class Placemark
        attr_accessor :name
        attr_accessor :region

        def initialize(*args)
          args.flatten!
          args.uniq!
          raise InsufficientPlacemarkArguments unless args.size == 2
          @name, @region = args
        end
    end
    
    def self.in_chicago?(location)
      sql = "SELECT EXISTS(SELECT *
       FROM boundary 
       WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326)));"

       DataMapper.repository(:default).adapter.select sql
    end
    
    def self.getHood(location)
       sql =  "SELECT pri_neigh AS neighborhood 
       FROM hoods 
       WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326));"
       puts sql
       DataMapper.repository(:default).adapter.select sql
    end
    
    def self.getWard(location)
       sql =  "SELECT ward 
       FROM wards 
       WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326));"
       puts sql
       DataMapper.repository(:default).adapter.select sql
    end
    
    def self.getPoliceDistrict(location)
      sql = "SELECT police_stations.name AS district FROM police_stations
      INNER JOIN police_districts
      ON police_districts.dist_num = police_stations.descriptio
      WHERE ST_Contains(police_districts.the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326));"

       DataMapper.repository(:default).adapter.select sql
    end
    
    def self.getIlCongress(location)
      sql = "SELECT district FROM il_congress
            WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326));"      

      DataMapper.repository(:default).adapter.select sql
    end

    def self.getIlSenate(location)
      sql = "SELECT district FROM il_senate
      WHERE ST_Contains(the_geom,ST_GeomFromText('POINT(#{location['lng']} #{location['lat']})', 4326));"

      DataMapper.repository(:default).adapter.select sql
    end
    
    
    def self.processQuery(query)
      
      address = MapUtils.address_geocode(query)
      
      if address.nil?
        return {'status' => :notfound}
      end
      
      location = address['location']
      
      if self.in_chicago?(location)
        puts query + " is in Chicago."

        ward = self.getWard(location)
        hood = self.getHood(location)
        police = self.getPoliceDistrict(location)
        ushouse = self.getIlCongress(location)
        ilsenate = self.getIlSenate(location)
        
        response = {'status' => :found, 'ward' => ward, 'hood' => hood, 'formatted_address' => address['formatted_address'],
          'lat' => location['lat'], 'lng' => location['lng'], 'police' => police,
          'ushouse' => ushouse, 'ilsenate' => ilsenate}
      else
        puts query + " is not in Chicago"
        response = {'status' => :notfound}
      end

      return response
    end
end