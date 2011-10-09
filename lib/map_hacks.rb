require 'rubygems'
require 'nokogiri'
require 'border_patrol'
require './lib/map_utils'
require './lib/chicago_kml'

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
      
      address = MapUtils.address_geocode(query)
      
      if address.nil?
        return {'status' => :notfound}
      end
      
      location = address['location']
      point = BorderPatrol::Point.new(location['lng'],location['lat'])

      if ChicagoKml.get_chicago_boundary.contains_point?(point)
        puts query + " is in Chicago."

        ward = 'N/A'
        hood = 'N/A'
        police = 'N/A'
        ushouse = 'N/A'
        ilsenate = 'N/A'
        response = {}
        
        ChicagoKml.get_ward_boundary.each do |w|
          if w.region.contains_point?(point)
            puts "    Ward #{w.name}"
            ward = w.name
            break
          end 
        end

        ChicagoKml.get_hoods_boundary.each do |h|
          if h.region.contains_point?(point)
            puts "    Neighborhood is #{h.name}"
            hood = h.name
            break
          end
        end
        
        ChicagoKml.get_police_boundary.each do |p|
          if p.region.contains_point?(point)
            puts "    Police District is #{p.name}"
            police = p.name
            break
          end
        end
        
        ChicagoKml.get_ushouse.each do |uh|
          if uh.region.contains_point?(point)
            puts "    US Congressional District is #{uh.name}"
            ushouse = uh.name
            break
          end
        end
        
        ChicagoKml.get_ilsenate.each do |is|
          if is.region.contains_point?(point)
            puts "    IL Senate is #{is.name}"
            ilsenate = is.name
            break
          end
        end
        response = {'status' => :found, 'ward' => ward, 'hood' => hood, 'formatted_address' => address['formatted_address'],
          'lat' => location['lat'], 'lng' => location['lng'], 'police' => police,
          'ushouse' => ushouse, 'ilsenate' => ilsenate}
      else
        puts query + " is not in Chicago"
        response = {'status' => :notfound}
      end

      return response
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
    
    def self.parse_police(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//ExtendedData/SchemaData/SimpleData[@name="DIST_LABEL"]').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    def self.parse_ushouse(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//ExtendedData/SchemaData[@schemaUrl="#IL_Congress"]/SimpleData[@name="DISTRICT"]').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    def self.parse_ilsenate(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//ExtendedData/SchemaData[@schemaUrl="#IL_Senate"]/SimpleData[@name="DISTRICT"]').text
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