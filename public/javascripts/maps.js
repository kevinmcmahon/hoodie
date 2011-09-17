var map;

function init() {
  var chicago = new google.maps.LatLng(41.875696,-87.624207);
  var myOptions = {
    zoom: 11,
    center: chicago,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  }

  map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
}

function showRegion(kml) {
  var regionLayer = new google.maps.KmlLayer(kml);
  regionLayer.setMap(map);
}