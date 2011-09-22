module ChicagoKml

 attr_accessor :chicago, :wards, :hoods, :police
 
 def self.get_chicago_boundary
   if @chicago.nil?
     @chicago = BorderPatrol.parse_kml(File.read('./kml/ChicagoBoundary.kml'))
   end
   @chicago
 end
 
 def self.get_ward_boundary
   if @wards.nil? 
     @wards = MapHacks.parse_wards(File.read('./kml/ChicagoWards.kml'))
   end
   @wards
 end
 
 def self.get_hoods_boundary
   if @hoods.nil?
     @hoods = MapHacks.parse_hoods(File.read('./kml/ChicagoHoods.kml'))
   end
   @hoods
 end
 
 def self.get_police_boundary
   if @police.nil?
     @police = MapHacks.parse_police(File.read('./kml/ChicagoPoliceDistricts.kml'))
   end
   @police
 end
 
end
