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
    
    def self.processQuery(query)

      chicago = BorderPatrol.parse_kml(File.read('./kml/ChicagoBoundary.kml'))
      wards = MapHacks.parse_wards(File.read('./kml/ChicagoWards.kml'))
      hoods = MapHacks.parse_hoods(File.read('./kml/ChicagoHoods.kml'))

      address = MapUtils.address_geocode(query) 
      location = address['location']
      point = BorderPatrol::Point.new(location['lng'],location['lat'])

      if chicago.contains_point?(point)
        puts query + " is in Chicago."

        ward = ''
        hood = ''
        
        wards.each do |w|
          if w.region.contains_point?(point)
            puts "    Ward #{w.name}"
            ward = w
            break
          end 
        end

        hoods.each do |h|
          if h.region.contains_point?(point)
            puts "    Neighborhood is #{h.name}"
            hood = h
            break
          end
        end

      else
        puts query + " is not in Chicago"
      end

      return {'ward' => ward, 'hood' => hood, 'formatted_address' => address['formatted_address']}
      
    end
    
    def self.parse_wards(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//name').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    def self.parse_hoods(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//Data/value').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    private 
    def self.parse_kml(string)
       doc = Nokogiri::XML(string)
       polygons = doc.xpath('//Polygon').map do |polygon_kml|
         begin 
           parse_kml_polygon_data(polygon_kml.to_s)
         rescue InsufficientPointsToActuallyFormAPolygonError => e
           puts "Problem with Polygon : #{polygon_kml}"
         end
       end
       BorderPatrol::Region.new(polygons)
     end
      
    private
    def self.parse_kml_polygon_data(string)
      doc = Nokogiri::XML(string)
      coordinates = doc.xpath("//coordinates").text.strip.split(" ")

      points = coordinates.map do |coord|
        x, y, z = coord.strip.split(',')
        BorderPatrol::Point.new(x.to_f, y.to_f)
      end
      BorderPatrol::Polygon.new(points)
    end
end