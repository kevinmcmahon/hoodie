var Location = {
	latitude: null,
	longitude: null,
	accuracy: null,
   
	loadLocation: function() {
		if(navigator.geolocation) {

           if($.cookie("posLat")) {
               latitude = $.cookie("posLat");
               longitude = $.cookie("posLon");
               accuracy = $.cookie("posAccuracy");
               updateDisplay();
           } else {
               navigator.geolocation.getCurrentPosition(
                                   	this.success_handler, 
									this.error_handler, 
									{timeout:10000});
           }
       }
   },

   success_handler: function (position) {
       latitude = position.coords.latitude;
       longitude = position.coords.longitude;
       accuracy = position.coords.accuracy;
       
       if (!latitude || !longitude) {
           return;
       }
       
       this.updateDisplay();
       
       $.cookie("posLat", latitude);
       $.cookie("posLon", longitude);
       $.cookie("posAccuracy", accuracy);
     
   },
   
   updateDisplay: function () {               
       document.getElementById("address").innerHTML = latitude + ',' + longitude;
   },
   
   error_handler: function error_handler(error) {
       var locationError = '';
       
       switch(error.code){
       case 0:
           locationError = "There was an error while retrieving your location: " + error.message;
           break;
       case 1:
           locationError = "The user prevented this page from retrieving a location.";
           break;
       case 2:
           locationError = "The browser was unable to determine your location: " + error.message;
           break;
       case 3:
           locationError = "The browser timed out before retrieving the location.";
           break;
       }
   },
   
   clear_cookies: function () {
       $.cookie('posLat', null);
       document.getElementById("status").innerHTML = "Cookies cleared.";
   }
}