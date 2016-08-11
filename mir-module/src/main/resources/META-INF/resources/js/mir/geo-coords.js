(function($) {
  $﻿(document).ready(function() {
    $('.show_openstreetmap').click(function() {
		if (!$(this).hasClass("map_drawn")) {
			drawMap($(this));
		}
		$(this).parent().next(".openstreetmap-container").collapse('toggle');
    });

  	function drawMap(btn) {
  		var map;
  		var input = $(btn).parent().parent().prev().find("input[name*='coordinates']"); 
  		var mapElement = $(btn).parent().next().find(".map");
	  	var layer_markers;
	  	var projection = new OpenLayers.Projection("EPSG:900913");
	  	var display_projection = new OpenLayers.Projection("EPSG:4326");
	  	//latitude, longitude
	  	var lat, lon;
	  	
	  	function init() {
	  		var layer_mapnik;
	      OpenLayers.Lang.setCode('de');
	      
	      if($(input).length && $(input).val() != "") {
	      	loadLonLat($(input).val());
	      } else {
	      	if($(btn).attr("data")) {
	      		loadLonLat($(btn).attr("data"));
	      	} else {
	      		lat = 50.930453;
	      		lon = 11.587786;
	      	}
	      }
	      var zoom = 10;
	
	      map = new OpenLayers.Map($(mapElement)[0], {
	          projection: projection,
	          displayProjection: display_projection,
	          controls: [
	              new OpenLayers.Control.Navigation(),
	              new OpenLayers.Control.LayerSwitcher(),
	              new OpenLayers.Control.PanZoomBar()],
	          maxExtent:
	              new OpenLayers.Bounds(-20037508.34,-20037508.34,
	                                      20037508.34, 20037508.34),
	          numZoomLevels: 18,
	          maxResolution: 156543,
	          units: 'meters'
	      });
	      
	      layer_mapnik = new OpenLayers.Layer.OSM.Mapnik("Mapnik");
	      layer_markers = new OpenLayers.Layer.Markers("Markers");
	      
	      map.addLayers([layer_mapnik, layer_markers]);
	
	      var lonLat = new OpenLayers.LonLat(lon, lat).transform(
	      		display_projection, 
	      		projection
	      		);
		  	
	      if(!$(btn).attr("data")) {
			  	var clickControl = new OpenLayers.Control.Click();
			  	map.addControl(clickControl);
	      }
		  	
		    map.setCenter(lonLat, zoom);
		    addMarker(lon, lat);
	  	}
	  	
	  	OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {               
	  		initialize: function(options) {
	  			this.handlerOptions = OpenLayers.Util.extend(
	  					{}, this.defaultHandlerOptions
	  			);
	  			OpenLayers.Control.prototype.initialize.apply(
	  					this, arguments
	  			);
	  			this.handler = new OpenLayers.Handler.Click(
	  					this, {
	  						'click': this.trigger
	  					}, this.handlerOptions
	  			);
	  		},
	  		autoActivate: true,
	  		trigger: function(e) {
	        var lonlat = map.getLonLatFromViewPortPx(e.xy).transform(
	        		projection, 
	        		display_projection
	        		);
	        var lat_sign = lonlat.lat >= 0 ? "+" : "";
	        var lon_sign = lonlat.lon >= 0 ? "+" : "";
	        $(input).val(lat_sign + lonlat.lat + "°, " + lon_sign + lonlat.lon + "°");
	        addMarker(lonlat.lon, lonlat.lat);
	  		}
	  	});
	  	
	  	function addMarker(lon, lat) {
	  		layer_markers.clearMarkers();
	      var lonlat = new OpenLayers.LonLat(lon, lat).transform(
	      		display_projection,
	      		projection
	      		);
	      
	  		var marker = new OpenLayers.Marker(lonlat);
	
	  		layer_markers.addMarker(marker);
	  	}
	  	
	  	function loadLonLat(lonLatData) {
      	var lonlat = lonLatData.replace("°", "");
      	lat = lonlat.split(",")[0];
        lon = lonlat.split(",")[1];
	  	}
	  	
	  	$(input).keyup(function(e) {
	  		if(e.keyCode == 13) { 
	  			loadLonLat($(this).val());
	        
	        addMarker(lon, lat);
	        
		      var lonLat = new OpenLayers.LonLat(lon, lat).transform(
		      		display_projection,
		      		projection
		      		);
	        map.setCenter(lonLat);
	  		}
	  	});
	  	init();
		$(btn).addClass("map_drawn");
  	}
  });
})(jQuery);