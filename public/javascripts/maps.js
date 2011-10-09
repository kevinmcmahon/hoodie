var Hoodie = {
	map: null,
	
	init: function () {
	  this.initWithCoords(41.875696,-87.624207);
	},

	initWithCoords: function(lat,lng) {
		var location = new google.maps.LatLng(lat,lng);
		var myOptions = {
			zoom: 14,
			center: location,
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};

		this.map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
		marker = new google.maps.Marker({
			map:this.map,
			draggable:false,
			animation: google.maps.Animation.DROP,
			position: location
		});
	},
	
	showNeighborhood: function(hoodName) {
		var layer = new google.maps.FusionTablesLayer({
		  query: {
		    select: 'geometry',
		    from: '1338203',
		    where: "'desc'='"+ hoodName +"'"
		  }
		});
		layer.setMap(this.map);
	},
	
	showWard: function(wardNum) {
		var layer = new google.maps.FusionTablesLayer({
		  query: {
		    select: 'geometry',
		    from: '1309344',
		    where: "'name'='"+ wardNum +"'"
		  }
		});
		layer.setMap(this.map);
	}
};

