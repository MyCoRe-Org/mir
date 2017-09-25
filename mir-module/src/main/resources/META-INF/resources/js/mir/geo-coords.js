(function($) {
    $﻿(document).ready(function() {
        $('.show_openstreetmap').click(function() {
            $(this).parent().next(".openstreetmap-container").collapse('toggle');
            if(!$(this).hasClass("map_drawn")) {
                drawMap($(this));
            }
        });

        function drawMap(btn) {
            var input = $(btn).parent().parent().prev().find("input[name*='coordinates']")[0];
            var typeSelect = $(btn).parent().next().find("#type")[0];
            var mapElement = $(btn).parent().next().find(".map")[0];
            var lat = $(btn).data("lat") === "" ? 50.930453 : $(btn).data("lat");
            var lon = $(btn).data("lon") === "" ? 11.587786 : $(btn).data("lon");
            
            function init() {
                var raster = new ol.layer.Tile({
                    source: new ol.source.OSM()
                });

                var source = new ol.source.Vector({
                    wrapX: false
                });

                // setup color of geometric object
                var vector = new ol.layer.Vector({
                    source: source,
                    style: new ol.style.Style({
                        fill: new ol.style.Fill({
                            color: 'rgba(0, 153, 255, 0.1)'
                        }),
                        stroke: new ol.style.Stroke({
                            color: '#0099FF',
                            width: 2
                        }),
                        image: new ol.style.Circle({
                            radius: 7,
                            fill: new ol.style.Fill({
                                color: '#0099FF'
                            })
                        })
                    })
                });

                var map = new ol.Map({
                    layers: [raster, vector],
                    target: mapElement,
                    view: new ol.View({
                        center: ol.proj.fromLonLat([lon, lat]),
                        zoom: 10
                    })
                });

                // witout select its not the editor, so don't need modify
                if(typeSelect) {
                    var modify = new ol.interaction.Modify({
                        source: source
                    });

                    // after modify write new coords to input
                    modify.on("modifyend", function(event) {
                        if(source.getState() === "ready") {
                            var array = event.features.getArray();
                            writeToInput(array[0]);
                        }
                    });

                    map.addInteraction(modify);

                    var draw, snap;

                    function addInteractions() {
                        var selectValue = typeSelect.value;

                        if(selectValue !== "None") {
                            var geometryFunction;
                            if(selectValue === "Box") {
                                selectValue = "Circle";
                                geometryFunction = ol.interaction.Draw.createBox();
                            }

                            draw = new ol.interaction.Draw({
                                source: source,
                                type: selectValue,
                                geometryFunction: geometryFunction
                            });
                            map.addInteraction(draw);

                            snap = new ol.interaction.Snap({
                                source: source
                            });
                            map.addInteraction(snap);

                            // on start delete all geometry first
                            draw.on("drawstart", function(event) {
                                if(source.getState() === "ready") {
                                    source.clear();
                                }
                            });

                            // after draw write new coords to input
                            draw.on("drawend", function(event) {
                                writeToInput(event.feature);
                            });
                        }
                    }

                    // handles the change event (select)
                    typeSelect.onchange = function() {
                        map.removeInteraction(draw);
                        map.removeInteraction(snap);
                        addInteractions();
                    };

                    addInteractions();

                    // writes coords to input like 'lon lat, lon lat, lon lat, lon lat' for polygon or 'lon lat' for point
                    function writeToInput(feature) {
                        var geometry = feature.getGeometry();
                        var coordinates = geometry.getCoordinates();
                        var lonLat = [];
                        var inputText = "";

                        if(coordinates.length === 1) {
                            $.each(coordinates[0], function(i, val) {
                                lonLat = ol.proj.toLonLat(val);
                                inputText += " " + lonLat[0] + " " + lonLat[1] + ",";
                            });
                            inputText = inputText.trim().slice(0, -1);
                        } else {
                            lonLat = ol.proj.toLonLat(coordinates);
                            inputText = lonLat[0] + " " + lonLat[1];
                        }

                        input.value = inputText;
                    }
                }

                // check if there are coords available as input (in editor) or data on btn (in metadata view)
                if($(input).length && $(input).val() != "") {
                    loadLonLat($(input).val());
                } else {
                    if($(btn).data("coords")) {
                        loadLonLat($(btn).data("coords"));
                    } else {
                        if (navigator.geolocation) {
                            navigator.geolocation.getCurrentPosition(function(position) {
                                map.setView(new ol.View({
                                    center: ol.proj.fromLonLat([position.coords.longitude, position.coords.latitude]),
                                    zoom: 10
                                }));
                            });
                        }
                    }
                }

                // use the given coords to draw on map
                function loadLonLat(lonLatData) {
                    var data = lonLatData.trim().split(", ");
                    var obj, geometry;
                    
                    if(data.length >= 2) {
                        var newArray = [];
                        $.each(data, function(i, val) {
                            var lonLat = val.split(" ");
                            newArray.push(ol.proj.fromLonLat([parseFloat(lonLat[0]), parseFloat(lonLat[1])]));
                        });
                        geometry = new ol.geom.Polygon([newArray]);
                    } else {
                        var lonLat = data[0].split(" ");
                        var pointCoords = ol.proj.fromLonLat([parseFloat(lonLat[0]), parseFloat(lonLat[1])]);
                        geometry = new ol.geom.Point(pointCoords);
                    }
                    
                    if(geometry) {
                        obj = new ol.Feature({
                            geometry: geometry
                        });

                        map.getView().fit(geometry, map.getSize());

                        if(data.length === 1) {
                            map.getView().setZoom(10);
                        }

                        source.addFeature(obj);
                    }
                }
            }

            init();

            // after finishing mark as drawn so that it won't be used again
            $(btn).addClass("map_drawn");
        }
    });
})(jQuery);