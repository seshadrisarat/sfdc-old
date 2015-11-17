var gp_map; // holds the Map object
//var gp_routeResultsData; // Holds route result data
//var gp_routeRequestLocs; // Holds the route request locations
var gp_bestFitMaxZoom; // max zoom for bestFit. global var b/c we need it in a listener
var gp_forceBestFitMaxZoom = false; // whether the listener should use bestFitMaxZoom or not
var $tabsBeforeStreetView; //keep track of the tabs that where visible before entering street view

// For markers
var gp_markers; // all the map markers as an associative array
var gp_markersPlaces; // all Places  markers
var gp_masterMarker; // The Master Record's Marker - GMarker
var gp_searchMarker;
var gp_bounds; // holds the LatLngBounds object so we can center and zoom properly - GLatLngBounds
var gp_placeBounds; // holds bounds of Places
var gp_infoWindow; // a single info window object used on the map
var gp_tooltip; // a floating tooltip for the markers
var gp_cirOverlays; // all the Circle overlay as an associative array
var gp_kmlOverlays; // all the Circle overlay as an associative array
var gp_layers = {}; // object that contains url as key, and google layer object as value
var gp_sameLocationMarkers = [];

// For Routing
var gp_dir; // Directions Renderer object

// Layers
var gp_traffic;
var gp_trafficState = false;

// For Drawing
var gp_drawingManager; // master drawing manager object
var gp_shapeDragInProgress = false;

//For Heatmaps
var gp_heatmaps = {}; //Object that contains heatmaps with key as the POIC unique Id

//Info about the jQuery Tabs
var gp_JQTabs = {
	"mapDataSets": 0,
	"search": 1,
	"layers": 2,
	"manualEntry": 3,
	"currentRoute": 4,
	"mySettings": 5
}

function __MAPPING_STUFF__(){}
// re-init the global objects
function gp_initJSObjects(){
	if (typeof(gp_markers) == 'undefined'){gp_markers = new Object();}
	if (typeof(gp_bounds) == 'undefined'){gp_bounds = new google.maps.LatLngBounds();}
	if (typeof(gp_infoWindow) == 'undefined'){
		gp_infoWindow = new google.maps.InfoWindow({ maxWidth: 550 });
		google.maps.event.addListener(gp_infoWindow, 'domready', function() {
			jQuery('#gp_demoTabs').tabs();
			jQuery('#gp_demoTabs').show();

			//Find the shapeColor input field
			var $colorInput = jQuery(".gp_shapeColorInput");
			
			if($colorInput.length > 0){ //Only proceed if infowindow has a color input for a shape
				
				//Get the shape object from the polygonObjects object so we can default the
				var shapeId = $colorInput.attr('data-shapeId');
				var polygon = polygonObjects[shapeId];

				//Set starting color value and opacity on the input field
				$colorInput.val(polygon.fillColor);
				$colorInput.attr('data-opacity',polygon.fillOpacity);

				//Apply original colors, they can change when a users hovers
				if(polygon.gpProperties.originalOpacity){
					$colorInput.attr('data-opacity',polygon.gpProperties.originalOpacity);
				}
				if(polygon.gpProperties.originalColor){
					$colorInput.val(polygon.gpProperties.originalColor);
				}

				//Create color selector for the selected shape
				jQuery(".gp_shapeColorInput").minicolors({
					inline:true,
					opacity:true,
					theme: 'geopointe',
					change: function(hex, opacity){
						//Get overlay Id
						var overlayId = jQuery(this).attr('data-shapeId');
						var groupLayerId = jQuery(this).attr('data-groupLayerId');

						//If there is a groupLayerId update all the layers with this id
						if(groupLayerId && groupLayerId != 'undefined' && groupLayerId != ''){
							for(key in polygonObjects){
								if(polygonObjects[key].gpProperties.groupLayerId == groupLayerId){
									polygonObjects[key].setOptions({
										fillColor: hex,
										fillOpacity: opacity
									});
								}
							}

						}else{ //update this single shape
							//Set the color and opacity of the shap on the map
							polygonObjects[overlayId].setOptions({
								fillColor: hex,
								fillOpacity: opacity
							});
						}
					}
				});
			}
		});
	}
	if (typeof(gp_tooltip) == 'undefined'){
		var ttOptions = {
			content: '',
			boxClass: 'gp_tooltip',
			closeBoxURL: '',
			isHidden: true
		}
		gp_tooltip = new InfoBox(ttOptions); // using the infoBox add-in
	}
	if (typeof(gp_cirOverlays) == 'undefined'){gp_cirOverlays = new Object();}
	if (typeof(gp_kmlOverlays) == 'undefined'){gp_kmlOverlays = new Object();}
}

//Clears the global variables out
function gp_cleanMapObjects(){
	for(var i in gp_markers) {
		gp_markers[i].setMap(null);

		//Remove checkbox marker if this marker has one
		if(gp_markers[i].selectedMarker){
			gp_markers[i].selectedMarker.setMap(null);
		}
	}
	gp_infoWindow.close();
	gp_tooltip.hide();
	for(var i in gp_cirOverlays) {
		gp_cirOverlays[i].setMap(null);
	}
	for(var i in gp_kmlOverlays) {
		gp_kmlOverlays[i].setMap(null);
	}

	//Clear heat maps
	for(var i in gp_heatmaps) {
		gp_heatmaps[i].setMap(null);
	}

	//Remove shape fields
	for(key in polygonObjects){
		
		//Don't remove shapes associated with center pin marker
		if(polygonObjects[key].gpProperties.usageType == 'Shape Field' && gp_centerPOI.recordId && gp_centerPOI.recordId == polygonObjects[key].gpProperties.relatedRecordId){
			//don't remove this shape
		}else if(polygonObjects[key].gpProperties.usageType == 'Shape Field'){
			polygonObjects[key].setMap(null);
			delete polygonObjects[key];
		}
	}
	
	gp_bounds = new google.maps.LatLngBounds();
	gp_markers = new Object();
	gp_cirOverlays = new Object();
	gp_kmlOverlays = new Object()
	
}

// Handles a Map Constructor
function gp_mapConstructor(jsAction){
	
	var thisMC = jsAction.mapConstructor;
	
	// Fix up the thisMC object as needed
	thisMC.startingZoom = 2;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c') != "") {
			thisMC.startingZoom = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Zoom__c');
		}
	}
	
	thisMC.startingLat = 0;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c') != "") {
			thisMC.startingLat = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lat__c');
		}
	}
	
	thisMC.startingLng = 0;
	if (typeof(eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c')) != 'undefined'){
		if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c') != "") {
			thisMC.startingLng = eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Starting_Lng__c');
		}
	}
	
	thisMC.width = document.getElementById("mapWrapper").clientWidth;
	if (thisMC.height == "") { thisMC.height = 600;}
	
	if (thisMC.centerLat == null || thisMC.centerLat == ''){
		thisMC.centerLat = thisMC.startingLat;
	}
	
	if (thisMC.centerLng == null || thisMC.centerLng == ''){
		thisMC.centerLng = thisMC.startingLng;
	}
	
	if (thisMC.centerZoom == null || thisMC.centerZoom == ''){
		thisMC.centerZoom = thisMC.startingZoom;
	}
	
	// New Map Object
	if (thisMC.newMap){
		
		gp_map = null;
		document.getElementById('mapDIV').innerHTML = '';
		
		gp_bounds = new google.maps.LatLngBounds();

		//Determine map type
		var savedMapTypeId = gp_userSettings.settings__c[gp_orgSettings.fieldPrefix + 'Map_Type__c'];
		var googleMapTypeId = google.maps.MapTypeId.ROADMAP;
		if(savedMapTypeId == 'map' || savedMapTypeId == 'OSM' || savedMapTypeId == 'roadmap'){
			googleMapTypeId = google.maps.MapTypeId.ROADMAP;
		}else if(savedMapTypeId == 'sat' || savedMapTypeId == 'satellite'){
			jQuery('.mapControlTabInner').addClass('mapControlDarkShadow');
			jQuery('.mapControlContent').addClass('mapControlContentDarkShadow');
			showWhiteSettingsHelp();
			googleMapTypeId = google.maps.MapTypeId.SATELLITE;
		}else if(savedMapTypeId == 'hyb' || savedMapTypeId == 'hybrid'){
			jQuery('.mapControlTabInner').addClass('mapControlDarkShadow');
			jQuery('.mapControlContent').addClass('mapControlContentDarkShadow');
			showWhiteSettingsHelp();
			googleMapTypeId = google.maps.MapTypeId.HYBRID;
		}
	    
		// Set map initial options
		var myOptions = {
			zoom: thisMC.startingZoom,
			center: new google.maps.LatLng(thisMC.startingLat, thisMC.startingLng),
			draggableCursor: 'default',
			mapTypeId: googleMapTypeId,
			mapTypeControlOptions: {
                style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
            },
            panControlOptions: {
            	position: google.maps.ControlPosition.RIGHT_TOP
            },
            zoomControlOptions: {
            	position: google.maps.ControlPosition.RIGHT_TOP
            },
            scaleControl: true,
			scrollwheel: eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Use_Scrollwheel_Zoom__c'),
			overviewMapControl: true
		}
		
		// init the map
		gp_map = new google.maps.Map(document.getElementById("mapDIV"), myOptions);

		gp_setTrafficIcon();
		
		// OSM Tiles
		gp_map.mapTypes.set("OSM", new google.maps.ImageMapType({
            getTileUrl: function(coord, zoom) {
                return "http://tile.openstreetmap.org/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
            	//return "https://otile1.mqcdn.com/tiles/1.0.0/osm/" + zoom + "/" + coord.x + "/" + coord.y + ".png";
            },
            tileSize: new google.maps.Size(256, 256),
            name: "Open Street Map",
            maxZoom: 18
        }));
		
		// Add layers
		gp_traffic = new google.maps.TrafficLayer();

		//Add drawing control
		gp_drawingManager = new google.maps.drawing.DrawingManager({
			drawingMode: google.maps.drawing.OverlayType.MARKER,
			drawingControl: false,
			drawingControlOptions: {
				position: google.maps.ControlPosition.TOP_CENTER,
				drawingModes: [
					google.maps.drawing.OverlayType.POLYGON,
					google.maps.drawing.OverlayType.RECTANGLE
				]
			},
			markerOptions: {
				icon: 'http://www.example.com/icon.png'
			},
			polygonOptions: {
				fillColor: '#EFFF79',
				fillOpacity: .2,
				strokeWeight: 1.5,
				clickable: true,
				zIndex: 1,
				editable: true,
				draggable: false
			}
		});

		//Add event listener when a polygon is added to the map after drawing is complete
		google.maps.event.addListener(gp_drawingManager, 'overlaycomplete', function(e) {
			gp_shapeAddedToMap(e.overlay,e.type);

			//Update the list of layers on the map
			angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true});
		});

		// Event listener on zoom change to correct the zoom if needed
		google.maps.event.addListener(gp_map, 'zoom_changed', function() {
			zoomChangeBoundsListener = google.maps.event.addListener(gp_map, 'bounds_changed', function(event) {
				if (this.getZoom() > gp_bestFitMaxZoom && gp_forceBestFitMaxZoom) {
					this.setZoom(gp_bestFitMaxZoom);
					gp_forceBestFitMaxZoom = false;
				}
				google.maps.event.removeListener(zoomChangeBoundsListener);
	        });
		});
		
		//Event listener for right click
		google.maps.event.addListener(gp_map, 'rightclick', function(e) {
			gp_openRigthClickMenu(e); //Open the right click menu
		});

		//Event listener for left click to hide right click menu
		google.maps.event.addListener(gp_map, 'click', function(e) {
			gp_map.set('disableDoubleClickZoom', false); //Enable double click zoom again
			//Hide the context menu.
	 		jQuery("#mapContextMenu").hide();
	 	});

	 	//Event listener for bounds change to hide right click menu
		google.maps.event.addListener(gp_map, 'bounds_changed', function(e) {
			//Hide the context menu.
	 		jQuery("#mapContextMenu").hide();
	 	});

	 	//Event listner for map type change
	 	google.maps.event.addListener(gp_map, 'maptypeid_changed', function(e) {
			//Update shadow boxes map controls
			var mapType = gp_map.getMapTypeId();

			if(mapType == 'sat' || mapType == 'satellite' || mapType == 'hyb' || mapType == 'hybrid'){
				jQuery('.mapControlTabInner').addClass('mapControlDarkShadow');
				jQuery('.mapControlContent').addClass('mapControlContentDarkShadow');
				showWhiteSettingsHelp();
				gp_setTrafficIcon();
			}else{
				jQuery('.mapControlTabInner').removeClass('mapControlDarkShadow');
				jQuery('.mapControlContent').removeClass('mapControlContentDarkShadow');
				showBlackSettingsHelp();
				gp_setTrafficIcon();
			}

			//Update the map type on user custom settings
			Visualforce.remoting.Manager.invokeAction(gp_remotes.settingSetMapType,gp_map.getMapTypeId(),function(result, event){ 
		        //Nothing to do here
		    },{escape:true, timeout: 120000});

		    //Trigger map resize event to re-align map pan/zoom controls
		    google.maps.event.trigger(gp_map, 'resize');
	 	});

		//Add event listener to show/hide map controls on enter and exit of street view
	 	var thePanorama = gp_map.getStreetView();
		google.maps.event.addListener(thePanorama, 'visible_changed', function() {
		    if (thePanorama.getVisible()) {
		    	//Hide the map control tabs
		    	if( !$tabsBeforeStreetView || $tabsBeforeStreetView.length == 0 ){
		    		$tabsBeforeStreetView = jQuery(".mapControl:visible").hide();
		    	}
		    	jQuery("#settingsAndHelp").hide();
		    } else {
		        //Show the map control tabs
		        if($tabsBeforeStreetView){
		        	$tabsBeforeStreetView.show();
		        	$tabsBeforeStreetView = [];
				}
				jQuery("#settingsAndHelp").show();
		    }
		});

		//Event listener for user drag
		google.maps.event.addListener(gp_map, 'dragend', function(e) {
			//User has moved the map, centerpoint address should change
			gp_mapManualMove();
	 	});

		//Create jquery event listner for map control panel so that if user moves map gp_centerPointKeepAddress is set to false, this is brittle has google may change markup
		jQuery("#mapDIV").on('click','div [title*="Pan"]',function(){
			gp_mapManualMove();
		});

		// Key Drag Zoom
		gp_map.enableKeyDragZoom({
			key: "shift", 
			boxStyle: {
				border: "medium dashed red",
				opacity: 0.80
			},
			paneStyle: {
				backgroundColor: "transparent",
				opacity: 0.00
			},
			visualEnabled: true,
			visualPosition: google.maps.ControlPosition.RIGHT_TOP,
			visualPositionOffset: new google.maps.Size(0, 10),
			visualPositionIndex: null,
			visualSprite: "https://maps.gstatic.com/mapfiles/ftr/controls/dragzoom_btn.png",
			visualSize: new google.maps.Size(20, 20),
			visualTips: {
				off: "Turn on",
				on: "Turn off"
			},
			visualClass: 'gpDragZoom'
		});

		//Event listner to call mapManualMove if someone use the shift drag zoom functionality
        var dz = gp_map.getDragZoomObject();
        google.maps.event.addListener(dz, 'dragend', function (bnds) {
        	gp_mapManualMove();
        });
		
		
		// My Location Control
		if (navigator.geolocation != null){
			var mlControl = jQuery('<div></div>').css({
														"margin": "0px 32px 0px 0px",
														"cursor": "pointer",
														"position": "relative"
													})
													.attr('title', 'Center the map on your current location')
													.append(
														jQuery('<div></div>')
																			.css({
																				"height": "22px",
																				"width": "22px",
																				"padding": "0",
																				"margin": "0",
																				"background-image": "url('https://maps.gstatic.com/mapfiles/my_location2.png')",
																				"background-position": "0 -21px"
																				})
													);
			mlControl[0].index=2;
			gp_map.controls[google.maps.ControlPosition.RIGHT_TOP].push(mlControl[0]);
			google.maps.event.addDomListener(mlControl[0], 'click', function() {
				gp_centerZoomMyPosition();
				gp_mapManualMove();
			});
		}

		//Add autoload layers to the map
		gp_autoLoadLayers();
		
		gp_trackMapLoad();
		
	}
	
	// Set Size
	if (thisMC.setSize){
		//If height is null or auto, use auto height
		if(!thisMC.height || thisMC.height == 'auto'){
			thisMC.height = getAutoMapHeight();
		}
		jQuery("#mapDIV").width('100%');
		jQuery("#mapDIV").height (thisMC.height);
		google.maps.event.trigger(gp_map, 'resize');
	}
	
	// Set Center
	if (thisMC.setCenter){
		gp_map.setCenter(new google.maps.LatLng(thisMC.centerLat, thisMC.centerLng));
		gp_map.setZoom(thisMC.centerZoom);
	}
	
	// GeoLocation
	if (eval('gp_userSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Use_Geolocation__c')){
		if (navigator.geolocation != null){
			if (thisMC.centerByGeoLocation){
    			navigator.geolocation.getCurrentPosition(function(position){
    				gp_map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
			    	gp_map.setZoom(11);
				}, function() {
			      // continue on a failure
			    });
			}
		}
	}

	//After map is created set the max height of the route table, my locations table, and layers table
	setRouteTabHeights();
	setMyLocationsTableMaxHeight();
	setDataSetTabMaxHeight();
	setLayersTableMaxHeight();
}

//Handles a poiCollections Request
function gp_poiCollections(jsAction){

	//Update the gp_dataSetSearches object 
	gp_updateDataSearchesObject(jsAction);
	
	var thisPOICollections = jsAction.poiCollections;
	
	// Quick loop through the POI Collections to determine if we should bestFit and/or remove shapes at the end
	gp_bestFitMaxZoom = 3;
	var toBestFit = false; // assume we are not doing bestFit
	var toRemoveAllShapes = true; // assume we are removing them
	if (thisPOICollections.length == 0){ toRemoveAllShapes = false; } // don't touch the points if there are no poiCollections
	jQuery.each(thisPOICollections, function(key, value) { 
		// Determine if we are removing shapes
		if(!value.removeAllShapes){ 
			toRemoveAllShapes = false;
		}
		
		// Determine if we are doing Best Fit
		if (value.bestFit) {
			toBestFit = true;
		}
		
		// Figure max bestFitMaxZoom
		if (value.bestFitMaxZoom > gp_bestFitMaxZoom){
			gp_bestFitMaxZoom = value.bestFitMaxZoom;
		}
	});
	

	// Removing markers and add back the center one if one exists
	if (toRemoveAllShapes){
		
		// Remove shapes and clear the global vars
		gp_cleanMapObjects();
		
		// Destroy the jQuery Data Tables 
		gp_destroyDataTables('gp_dataTables'); 

		//Reset object that keeps track of selected records
		gp_selectedRecords = {};
		
		// Add the center one back
		if (gp_masterMarker != null){
			
			gp_masterMarker.setMap(gp_map); // Add back onto the map
			gp_bounds.extend(gp_masterMarker.getPosition()); // Extend the bounds object so we can do bestFit later
				
			// Add them using the uniqueId as an Index so we can interact with them outside the map
			if(gp_masterMarker.uniqueID != null){ 
				gp_markers[gp_masterMarker.uniqueID] = gp_masterMarker;
			}
		}
	}

	//Create a list of points to handle/add to map and so this asynchronously later
	var poisToHandle = [];
	
	// Loop through each poiCollection
	jQuery.each(thisPOICollections, function(key, value) {
		
		thisPOIC = value;
		thisPOIC.searchType = jsAction.searchType;
		thisPOIC.sfdcObject = '';
		thisPOIC.writeBackEnabled = jsAction.writeBackEnabled;
		thisPOIC.writeBackLookupObject = jsAction.writeBackLookupObject;
		thisPOIC.writeBackButtonText = jsAction.writeBackButtonText;
		
		// Determine whether we should create the table
		var createTable = thisPOIC.collectionName != gp_centerPOICollectionName;

		//Don't create a table if there are no pois
		if(thisPOIC.POIs && thisPOIC.POIs.length == 0){
			createTable = false;
		}
		
		if(createTable){
			jQuery('#gp_dataTablesNoData').hide(); // Hide the No Data message
			gp_newDataTableStructure('gp_dataTables', thisPOIC); // Add new jQuery Data Table structure
			var tableCols = gp_defineDataTableColumns(thisPOIC); // Prepare the columns array for use in creating the data table
		}
		
		// Loop over data and add POIS / rows to table
		var tableData = new Array();
		var tmpMarkersArray = [];
		if(typeof(value.POIs) != "undefined"){
			if(value.POIs != null){
				for(var i = 0; i < value.POIs.length; i++){
					
					thisPOI = gp_finishPOIObject(value.POIs[i]); //TODO perf 2500ms
					thisPOI.poicCollectionName = thisPOIC.collectionName;
					thisPOIC.sfdcObject = thisPOI.sfdcObject;

					//Set center pin icon if necesssary
					if(thisPOI.mapIconURL == 'centerPin'){
						thisPOI.mapIconURL = gpImg.center_pin2;
					}
					
					// Archive off the centerPOI
					if (thisPOI.uniqueId == gp_centerPOICollectionName) { 
						gp_centerPOI = thisPOI; 
						gp_radialSearchCenter = {lat: gp_centerPOI.lat, 
												 lng: gp_centerPOI.lng, 
												 recordId: gp_centerPOI.recordId};
					}

					poisToHandle.push({poi:thisPOI, poiCollection:thisPOIC});
												
					// Add a row of data to the data table array
					if(createTable){ tableData.push(gp_defineDataTableRow(thisPOIC, thisPOI)); }
					
					thisPOI = null;
				}// end of loop through each poi
			}
		}
		
		// create circle overlay
		if(	thisPOIC.searchType == 'nearby' 
			&& typeof(thisPOIC.searchNearbyRange) != "undefined" 
			&& typeof(thisPOIC.searchNearbyLat) != "undefined" 
			&& typeof(thisPOIC.searchNearbyLng) != "undefined"
			&& jsAction.searchNearbyShowOverlay){
		    
				var radius = gp_milesToMeters(thisPOIC.searchNearbyRange);
				if(thisPOIC.distanceUnits=='kilometers' || thisPOIC.distanceUnits=='km' || thisPOIC.distanceUnits=='k'){
					radius = thisPOIC.searchNearbyRange * 1000;
				}
				
				var cirOptions = {
		          clickable:false, //Disable clicks so right click event on map below opens context menu
		          strokeColor: "#B00303", //'#B00303'; '#1797c0';
		          strokeOpacity: 0.75,
		          strokeWeight: 2,
		          fillColor: "#EFFF79", //'#EFFF79'; '#1797c0';
		          fillOpacity: 0.0,
		          map: gp_map,
		          center: new google.maps.LatLng(thisPOIC.searchNearbyLat, thisPOIC.searchNearbyLng),
		          radius: radius
		        };
			    var circle = new google.maps.Circle(cirOptions);
			    gp_cirOverlays[thisPOIC.collectionName + '_overlay'] = circle;
			    
			    gp_bounds.union(circle.getBounds());
		    
		}
	    
		// Initialize the Data Table
		if(createTable){
			//Delay the creation of the table slightly, TODO WHY?!?!
			setTimeout(function(){ 
				//value is the POI collection in the larger jQuery loop, need to use this due do the way var are stored and used in timeout functions
				gp_initDataTable(value, tableCols, tableData)  

				// Calculate Drive Times
				if (jsAction.searchNearbyDriveCalc){
					gp_calcDriveTimes(value.collectionName, value.distanceUnits);
				}

				//Add same location markers, need to do this after table is created as this is the data source
				gp_createSameLocationMarkers();
			}, 50);
		}
		
	}); // end of loop through each poiCollection 

	//Handle/add pois to map asynchronously 1000 at a time with a little break of 250ms between eash add
	async.eachLimit(poisToHandle, 1000, function( poiObj, callback) {
    	
		gp_handlePOI(poiObj.poiCollection, poiObj.poi);
		
		setTimeout(function(){
			callback();
		},250)
	});

	
	//If there are shapes on the map make sure they are included in the bounds calculation so the map zoom contains entire shape
    for(key in polygonObjects){
    	var bounds = polygonObjects[key].getBounds();
    	gp_bounds.extend( new google.maps.LatLng(bounds.getNorthEast().lat(), bounds.getNorthEast().lng()) );
    	gp_bounds.extend( new google.maps.LatLng(bounds.getSouthWest().lat(), bounds.getSouthWest().lng()) );
    }

	// Best Fit
	if (toBestFit) {
		gp_forceBestFitMaxZoom = true;
		gp_centerZoom();
	}

	//Build the list actions
	buildListActions(); //map.actions.js
}

//Take an object as input and process the POI onto the map
function gp_handlePOI(thisPOIC, thisPOI){
	
	if(!thisPOI.isBlankLat && !thisPOI.isBlankLng){
		
		// Make Lat Lon Object
		var g_latlon = new google.maps.LatLng(thisPOI.latDisplay, thisPOI.lngDisplay);
		
		// Extend the bounds object so we can do bestFit later
		gp_bounds.extend(g_latlon);
		
		// Build the InfoContentHTML
		var tmpInfoContentHTML = '';
		tmpInfoContentHTML += '<div style="font-size: 9pt;" class="poiTooltip" >';
		tmpInfoContentHTML += '<div class="poiTitle">' + thisPOI.title + '</div>';
		if(thisPOI.title2 != ''){
			tmpInfoContentHTML += '<b style="font-size: 9pt;">' + thisPOI.title2 + '</b><br/>';
		}
		tmpInfoContentHTML += thisPOI.formattedAddr;
		if (thisPOI.distanceInfo){
			tmpInfoContentHTML += thisPOI.distanceInfo;
		}
		if (thisPOI.geocodeQuality){
			tmpInfoContentHTML += '<br/><b>'+gp_translations.Geocode_Quality+'</b>: ' + thisPOI.geocodeQuality;
		}
		
		if(thisPOI.additionalFields){
			tmpInfoContentHTML += '<hr/>';
			jQuery.each(thisPOI.additionalFields, function(key, value) { 
				if(value.isShapeField != true){
					tmpInfoContentHTML += '<b>' + value.label + '</b>: ' + gp_formatOutputField(thisPOI.recordId,value.datatype,value.value,thisPOI.recordId,thisPOI.title,value.precision) + '<br/>';
				}
			});
		}
		
		//POI Buttons
		tmpInfoContentHTML += '<div class="poiTooltipButtons">';
		tmpInfoContentHTML += 		buildPOIActions(thisPOIC,thisPOI,'button'); //map.actions.js
		tmpInfoContentHTML += '</div>';
		// end POI Buttons
		
		//Map Actions
		tmpInfoContentHTML += '<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;"><span style="font-size: 10pt;"><b>'+gp_translations.Map_Actions+':</b></span>';
		tmpInfoContentHTML += '<br/><span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + thisPOI.latDisplay + ',' + thisPOI.lngDisplay + ',16);">'+gp_translations.Zoom_and_Center+'</span>';
		tmpInfoContentHTML += '&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + thisPOI.lat + ',' + thisPOI.lng + ')">'+gp_translations.Street_View+'</span>';
		tmpInfoContentHTML += '&nbsp;&nbsp;<a href="http://maps.google.com?f=q&q=' + escape(thisPOI.street) + ',' + escape(thisPOI.city) + ',' + escape(thisPOI.state) + ' ' + escape(thisPOI.postalCode) + ' ' + escape(thisPOI.countryISO) + '@' + thisPOI.lat + ',' + thisPOI.lng + '(' + escape(thisPOI.title) + ')" target="_blank">'+gp_translations.View_on_Google_Maps+'</a>';
		tmpInfoContentHTML += '</div>';
		
		//Record Actions
		var actionsHTML = buildPOIActions(thisPOIC,thisPOI,'link');
		if(actionsHTML){
			tmpInfoContentHTML += '<div class="poiTooltipActions"><span style="font-size: 10pt;"><b>'+gp_translations.Record_Actions+':</b></span><br/>';
			tmpInfoContentHTML += 		actionsHTML;
			tmpInfoContentHTML += '</div>';
		}
		
		//tmpInfoContentHTML += '<hr/><select id="contextShapeType' + thisPOI.uniqueId + '"><option value="Postal Code">Postal Code</option><option value="Municipality">Municipality</option><option value="Time Zone">Time Zone</option></select>';
		//tmpInfoContentHTML += '<input class="btn" onclick="var shapeType = jQuery(\'#contextShapeType' + thisPOI.uniqueId + '\').val(); gp_SGContextSearch(' + thisPOI.lat + ',' + thisPOI.lng + ',shapeType); return false;" value="Add Context Layer" type="button" />';
		
		if (thisPOIC.writeBackEnabled){
			if (thisPOI.sfdcObject == thisPOIC.writeBackLookupObject){
				tmpInfoContentHTML += '<hr/><input class="btn" onclick="geopointeAjaxStart(\'body\',\''+gp_translations.Updating_Originating_Record+'...\'); gp_writeBackSelection(\'' + thisPOI.recordId + '\'); return false;" value="' + thisPOIC.writeBackButtonText + '" type="button" />';
			}
		}
		
		tmpInfoContentHTML += '</div>';
			
		var hoverText = thisPOI.title;
		if (thisPOI.title2 != ''){
			hoverText = '<strong>'+ thisPOI.title + '</strong><br/>' + thisPOI.title2;
		}
		
		// Create this GMarker

		var image = {
		    url: thisPOI.mapIconURL,
		    scaledSize: new google.maps.Size(23, 35), // This marker is 20 pixels wide by 32 pixels tall.
		    anchor: new google.maps.Point(11.5, 30) // The anchor for this image is the base of the flagpole at 0,32.
		};

		var g_marker = gp_createMarker(g_latlon, hoverText, tmpInfoContentHTML, image, thisPOI.uniqueId); //TODO perf 300ms
		
		//Set the collectionName property on the marker object so we can keep track of what markers belong to each data set search
		g_marker.collectionName = thisPOI.poicCollectionName;

		// Add them to the main object using the uniqueId as an Index so we can interact with them outside the map
		if(thisPOI.uniqueId != ''){
			gp_markers[thisPOI.uniqueId] = g_marker;
		}
		
		// Save off the centerPOI marker
		if (thisPOI.poicCollectionName == gp_centerPOICollectionName){
			gp_masterMarker = g_marker;
		}
		
		// Add the Marker to the map
		g_marker.setMap(gp_map); 

		//If this poi has shapes associated with it add those to the map
		if(thisPOIC.shapeMap[thisPOI.recordId]){
			
			//Record could have more that one shape so loop through and add to map
			for(var i = 0; i < thisPOIC.shapeMap[thisPOI.recordId].length; i++){
				var shape = thisPOIC.shapeMap[thisPOI.recordId][i];

				//Create a new polygon overlay
				var shapeOverlay;
				var shapeOptions = {
					fillColor: shape.color,
					fillOpacity: shape.opacity,
					strokeWeight: 1.5,
					clickable: true,
					zIndex: 2,
					editable: false,
					draggable: false
				};

				if(shape.type && shape.type.toLowerCase() == 'polygon'){

					//Decode the lat lng string
					var latLngs = [];

					//Remove all line breaks and spaces
					if(shape.coordinates){
						shape.coordinates = shape.coordinates.replace(/(?:\r\n|\r|\n)/g, '').replace(/ /g, '');
					}

					if(shape.coordinates && shape.coordinates.indexOf('[[[') == 0){ //Stored in GeoJSON format
						var latLngArray = JSON.parse(shape.coordinates)[0]; //Don't support holes so first array of lng lats is the shape

						for(var j = 0; j < latLngArray.length; j++){
							latLngs.push(new google.maps.LatLng(latLngArray[j][1],latLngArray[j][0]));
						}

					}else{
						latLngs = google.maps.geometry.encoding.decodePath(shape.coordinates);
					}

					shapeOptions.paths = latLngs;

					var shapeOverlay = new google.maps.Polygon(shapeOptions);
					shapeOverlay.gpProperties = {};

				}else if(shape.type && shape.type.toLowerCase() == 'circle'){

					//Determing radius in meters
					var radius = JSON.parse(JSON.stringify(shape.radius)); //Copy radius by value, not reference

					if(shape.units == 'm' || shape.units == 'miles' || shape.units == 'Miles'){
						radius = shape.radius * 1.60934;
					}
					radius = radius * 1000; //convert to meters

					shapeOptions.radius = radius;

					//If lat/lng was defined on the Shape__c object use that, other wise use lat/lng from record
					if(shape.centerLat && shape.centerLng){
						shapeOptions.center = new google.maps.LatLng(shape.centerLat,shape.centerLng);
					}else{
						shapeOptions.center = new google.maps.LatLng(thisPOI.lat,thisPOI.lng);
					}
					
					//Create a new circle overlay
					var shapeOverlay = new google.maps.Circle(shapeOptions);
					shapeOverlay.gpProperties = {};
					shapeOverlay.gpProperties.range = shape.radius;
					
					//If lat/lng was defined on the Shape__c object use that, other wise use lat/lng from record
					if(shape.centerLat && shape.centerLng){
						shapeOverlay.gpProperties.centerLatLng = {lat: shape.gpProperties.centerLat, lng: shape.gpProperties.centerLng};
					}else{
						shapeOverlay.gpProperties.centerLatLng = {lat: thisPOI.lat, lng: thisPOI.lng};
					}
				}

				//Set the saved properties on the overlay shape object
				shapeOverlay.gpProperties.sfdcId = shape.sfdcId;
				shapeOverlay.gpProperties.sfdcName = shape.name;
				shapeOverlay.gpProperties.sfdcDescription = shape.description;
				shapeOverlay.gpProperties.relatedRecordName = thisPOI.title;
				shapeOverlay.gpProperties.relatedRecordId = thisPOI.recordId;
				shapeOverlay.gpProperties.usageType = 'Shape Field';
				shapeOverlay.gpProperties.gpCollectionName = thisPOIC.collectionName;
				shapeOverlay.gpProperties.relatedRecordFieldName = shape.relatedRecordFieldName;
				shapeOverlay.gpProperties.relatedRecordFieldLabel = shape.relatedRecordFieldLabel;
				shapeOverlay.gpProperties.units = shape.units;
				shapeOverlay.gpProperties.recordLat = thisPOI.lat;
				shapeOverlay.gpProperties.recordLng =  thisPOI.lng;
				shapeOverlay.gpProperties.gpPoiId = thisPOI.uniqueId;

				//Add the shape to map
				shapeOverlay.setMap(gp_map);

				var shapeBounds = shapeOverlay.getBounds();
				gp_bounds.extend(shapeBounds.getNorthEast());
				gp_bounds.extend(shapeBounds.getSouthWest());

				//Call polygon added to map method, make sure it is added to polygon Objects array
				gp_shapeAddedToMap(shapeOverlay,shape.type.toLowerCase());
			}
		}
	}
	
	return null;
}

//Creates and returns a map marker
function gp_createMarker(latlng,title,html,image,uid,placeInfo) {
	
	// Create traditional marker
	var marker = new google.maps.Marker({
	      position: latlng, 
	      map: gp_map,
	      icon: image,
	      flat: true
	});  

	//If this is a center pin marker make it slightly larger than the rest
	if(image.url == gpImg.center_pin2 || image == gpImg.center_pin2){
		marker.setIcon({
		    url: gpImg.center_pin2,
		    scaledSize: new google.maps.Size(25, 40), // This marker is 20 pixels wide by 32 pixels tall.
		    anchor: new google.maps.Point(12, 32) 
		});
	}
	
	// Add custom properties to it
	marker.tooltip = '<div class="nowrap">'+title+'</div>';
	marker.tooltipDetail = '';
	if(html){
		marker.tooltipDetail = html.substring(0,html.indexOf('<div class="poiTooltipButtons">'));
	}            
	marker.infoWindowHTML = html;
	marker.uniqueID = uid;
	
	// Marker Click Event
	if(typeof(placeInfo)=="undefined"){
		google.maps.event.addListener(marker, 'click', function() {
			
			//If we are in record selection mode perform special handling from record clicks
			if(gp_inRecordSelectionMode && marker.uniqueID != 'gp_mapCenterPoi' && marker.uniqueID != 'centerPOI'){
				gp_toggleRecordSelection(marker.uniqueID);
			}else{
				gp_openPoiInfoMarker(marker.uniqueID);
			}
			gp_tooltip.hide();
		});
	} else {
		google.maps.event.addListener(marker, 'click', function() {
			gp_placesInfoWindowHandler(placeInfo,marker);
		});
	}
	
	// Marker Mouseover Event 
	google.maps.event.addListener(marker,"mouseover", function() {
		if(gp_inRecordSelectionMode && marker.uniqueID != 'gp_mapCenterPoi'){
			gp_tooltip.setContent(marker.tooltipDetail);
		}else{
			gp_tooltip.setContent(marker.tooltip);
		}
		gp_tooltip.show();
		gp_tooltip.open(gp_map, marker);
	});
	
	// Marker Mouseout Event
	google.maps.event.addListener(marker,"mouseout", function() {
		gp_tooltip.hide();
	}); 
	return marker;
}

function gp_createSameLocationMarkers(){

	//Wipe out existing same location markers
	for(var i = 0; i < gp_sameLocationMarkers.length; i++){
		gp_sameLocationMarkers[i].setMap(null);
	}
	gp_sameLocationMarkers = [];

	var sameLocations = {};

	//Loop through all of the data
	var allTables = jQuery('.dataTable');

	// Don't continue if there's no data
	if (allTables.length == 0){ return false; }
	
	// Loop through each table
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		// Get the Table Data
		var aoData = jQuery(allTables[i]).dataTable().fnGetData();
		var columnInfo = jQuery(allTables[i]).data('columnInfo');
		var collectionName = jQuery(allTables[i]).attr('id');

		//Only proceed if these markers are visible on the map
		if(gp_dataSetSearches[collectionName] && gp_dataSetSearches[collectionName].markersVisible != false){
			//Loop through the rows
			for ( var j = 0; j < aoData.length; j++ ){
				var row = aoData[j];

				//Get that lat and combine them with a x
				var latLng = row[gp_ColumnInfo.latitudeDisplay] + 'x' + row[gp_ColumnInfo.longitudeDisplay];
				
				//Maker sure there is a key value for this lat long in same locations object
				if(typeof sameLocations[latLng] == 'undefined'){
					sameLocations[latLng] = 0;
				}

				//Increment the count of records at this location
				sameLocations[latLng]++;

			} // END OF Rows Loop
		}
		
	} // END OF tables loop

	//Loop through the same locations object
	var marker;
	for(key in sameLocations){
		
		//If there was more than one location at same spot create a special marker
		if(sameLocations[key] > 1){
			//Parse out the lat long
			var latLng = key.split('x');

			//Create a new marker at this location that is a circle with a Number
			var marker = gp_createSameLocationMarker(latLng[0],latLng[1],sameLocations[key]);

			//Set gp properties
			marker.gpLat = latLng[0];
			marker.gpLng = latLng[1];
			marker.gpRecordCount = sameLocations[key];

			gp_sameLocationMarkers.push(marker);
		}
	}
}

function gp_createSameLocationMarker(lat,lng,count){
	
	var imgUrl = 'https://api.geopointe.io/v1/markers/circle-l+007AA5.png?text=' + count;
	
	//If org setting is default off use the transparent img
	if(gp_orgSettings.settings__c[nameSpacePrefix + 'Same_Location_Markers__c'] == 'Default Off'){
		imgUrl = gpImg.onepxtransparent;
	}
	
	//If user as overriden the same location marker option use this
	if(typeof gp_userSettings.settings__c[nameSpacePrefix + 'Same_Location_Markers__c'] != 'undefined'){
		if(gp_userSettings.settings__c[nameSpacePrefix + 'Same_Location_Markers__c'] == 'on'){
			imgUrl = 'https://api.geopointe.io/v1/markers/circle-l+007AA5.png?text=' + count;
		}else{	
			imgUrl = gpImg.onepxtransparent;
		}
	}

	var marker = new google.maps.Marker({
		position: new google.maps.LatLng(lat, lng), 
		map: gp_map,
	    icon: {
	        scaledSize: new google.maps.Size(33,33),
	        size: new google.maps.Size(33,33),
	        url: imgUrl
	    },
	    zIndex: 100000 //make sure this is always on top of the markers
	});  

	marker.tooltip = '<div class="nowrap">'+count+' records at this location</div>';

	google.maps.event.addListener(marker,"mouseover", function() {
		gp_tooltip.setContent(marker.tooltip);
		gp_tooltip.show();
		gp_tooltip.open(gp_map, marker);
	});
	
	// Marker Mouseout Event
	google.maps.event.addListener(marker,"mouseout", function() {
		gp_tooltip.hide();
	}); 

	//Create event listener for click
	google.maps.event.addListener(marker, 'click', function(e) { 
        gp_showSameLocationMarkerInfoWindow(marker);
    });

	return marker;
}

function gp_showSameLocationMarkerInfoWindow(marker){
	//Calculate max height of infowindow
	var maxHeight = jQuery('#mapDIV').height() * 0.70;

	var infoWindowHTML = '<div class="sameLocationInfoWindowWrapper" style="max-height: '+maxHeight+'px"><table cellspacing="0" cellpadding="0" width="100%" class="sameLocationInfoWindowTable"><tbody>';

	//Loop through all of the data
	var allTables = jQuery('.dataTable');

	// Don't continue if there's no data
	if (allTables.length == 0){ return false; }
	
	// Loop through each table
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		// Get the Table Data
		var aoData = jQuery(allTables[i]).dataTable().fnGetData();
		var columnInfo = jQuery(allTables[i]).data('columnInfo');
		var collectionName = jQuery(allTables[i]).attr('id');

		//Only proceed if markers are on the map for this dataset
		if(gp_dataSetSearches[collectionName].markersVisible != false){
			//Loop through the rows
			for ( var j = 0; j < aoData.length; j++ ){
				var row = aoData[j];
				var titleTop = '-7px;'
				if(row[gp_ColumnInfo.title2]){
					titleTop = '-3px';
				}

				//If record has same lat lng of marker, add it to info window
				if(marker.gpLat == row[gp_ColumnInfo.latitudeDisplay] && marker.gpLng == row[gp_ColumnInfo.longitudeDisplay]){
					infoWindowHTML+= '<tr>'+
							            '<td width="17px">'+
							                '<img src="'+row[gp_ColumnInfo.mapIconURL]+'" height="32px"/>'+
							            '</td>'+
							            '<td>'+
							            	'<div class="sameLocationDetail" style="top: '+ titleTop +'">'+
								                '<div><a href="#" onclick="gp_openPoiInfoMarker(\''+row[gp_ColumnInfo.uniqueId]+'\',true); return false;">'+row[gp_ColumnInfo.title]+'</a></div>'+
								                '<div class="title2">'+row[gp_ColumnInfo.title2]+'</div>'+
							                '</div>'+
							            '</td>'+
							        '</tr>';
				}

			} // END OF Rows Loop
		}
	} // END OF tables loop

	//Close the table
	infoWindowHTML += '</tbody></table></div>';

	//Set properties of info window and show it
	gp_infoWindow.setOptions({pixelOffset: {height: -28, width: 0}});
	gp_infoWindow.setContent(infoWindowHTML);
	gp_infoWindow.setPosition(new google.maps.LatLng(marker.gpLat, marker.gpLng));
	gp_infoWindow.open(gp_map);
}

//Toggle record selection, add checkmark to map, update checkbox in table
function gp_toggleRecordSelection(uniqueId){
	
	//Set apply to picklist to selected records
	jQuery("#applyActionTo").val('selectedRecords');

	//Check to see if the record is already selected
	if(!gp_selectedRecords[uniqueId]){
		gp_selectedRecords[uniqueId] = true;

		//Set z index of the maker pin 1 below the check box icon
		gp_markers[uniqueId].setZIndex(199999);

		gp_markers[uniqueId].selectedMarker = new google.maps.Marker({
			position: gp_markers[uniqueId].getPosition(), 
			map: gp_map,
			icon: {
                anchor: new google.maps.Point(0,17),
                scaledSize: new google.maps.Size(18,18),
                size: new google.maps.Size(18,18),
                url: redCheckIconURL
            },
			flat: false,
			zIndex: 200000
		});  

	}else{
		//Set selected flag as false for the record
		gp_selectedRecords[uniqueId] = false;
		
		//Remove the selected marker from the map
		gp_markers[uniqueId].selectedMarker.setMap(null);
		gp_markers[uniqueId].selectedMarker = null;
	}

	updateDataTableSelectedProp(uniqueId);
}

//Remove a route from the map
function gp_removeRouteFromMap(){
	if(gp_dir){
		gp_dir.setMap(null);
		gp_dir.setPanel(null);
	}
}

//Add the existing route back to the map
function gp_restoreRouteOnMap(){
	if(gp_dir){
		gp_dir.setMap(gp_map);
	}
}

// Handles a Route Request, called from Angular route controller
function gp_routeRequest(route,routeOptions){
	
	// Clear the route from the map
	if (typeof(gp_dir) != 'undefined'){
		gp_dir.setMap(null);
		gp_dir.setPanel(null);
	}
	
	// Create a Directions Renderer object
	gp_dir = new google.maps.DirectionsRenderer({
		suppressInfoWindows: false,
		preserveViewport: routeOptions.preserveViewport
	});
	gp_dir.setMap(gp_map);
	
	// Directions Service
	var gp_dirService = new google.maps.DirectionsService();
	
	if (route.routeStops.length > 1) {
		
		jQuery("#routeNarrativeDIV").html('');
		
		// Directions Request Options
		var opts = {};
		opts.travelMode = google.maps.TravelMode.DRIVING;
        
        if (route.type == 'pedestrian') {
        	opts.travelMode = google.maps.TravelMode.WALKING;
        } else if (route.type == 'bicycle') {
        	opts.travelMode = google.maps.TravelMode.BICYCLING;
        } else if (route.type == 'multimodal' || route.type == 'transit') {
        	opts.travelMode = google.maps.TravelMode.TRANSIT;
        }

        opts.avoidHighways = route.avoidHighways;
        opts.avoidTolls = route.avoidTolls;
        opts.provideRouteAlternatives = false;
        opts.optimizeWaypoints = route.optimize;
        opts.unitSystem = google.maps.UnitSystem.IMPERIAL;
        if (route.units == 'k' || route.units == 'km'){ opts.unitSystem = google.maps.UnitSystem.METRIC; }
        	
        //Set the start and end points of the route
		opts.origin = new google.maps.LatLng(route.routeStops[0].lat, route.routeStops[0].lng);
		opts.destination = new google.maps.LatLng(route.routeStops[route.routeStops.length - 1].lat, route.routeStops[route.routeStops.length - 1].lng);

		//Add the waypoints between the start and end points
		if (route.routeStops.length > 2) {
			var ways = [];
			for(var i = 1; i < route.routeStops.length - 1; i++) {
				ways.push({location: new google.maps.LatLng(route.routeStops[i].lat, route.routeStops[i].lng), stopover:true});
			}
			opts.waypoints = ways;
		}
		
		//Do the directions request to google
		gp_dirService.route(opts, function(result,status){
			if (status == google.maps.DirectionsStatus.OK) {
				gp_getActionsForRouteStops(route.routeStops, result.routes[0].legs);
				gp_dir.setDirections(result);
				gp_displayRouteNarrative(route, result); // write the results out

				//Build an array of route stop order so we can send this to angular controller, first is always 0
				var routeOrder = [0];
				for(var i = 0; i < result.routes[0].waypoint_order.length; i++){
					routeOrder.push(result.routes[0].waypoint_order[i] + 1);
				}
				//Add the last stop
				routeOrder.push(routeOrder.length);

				var routeDetail = {
					order: routeOrder,
					routeResponse: result,
					legs: []
				};

				//Populate the legDurations
				for(var i = 0; i < result.routes[0].legs.length; i++){
					routeDetail.legs.push({
						duration: result.routes[0].legs[i].duration.value * 1000 //convert to ms
					});
				}

				//Let angular controller know map was added successfully, return object with data about the route request, order, etc
				angular.element(jQuery('.routeController')).scope().$broadcast('routeAddedToMap',routeDetail);
				angular.element(jQuery('.routeController')).scope().$apply(); //This is async outside context of angular so update scope on controller

				//Track the route request
				route.status = 'Success';
				gp_trackRoute(route);

			}else{
				//Error messaage
				jQuery.jGrowl(gp_translations.Unable_to_build_route + ' ' + status);
				angular.element(jQuery('.routeController')).scope().$broadcast('routeNotAddedToMap');

				//Track the route request
				route.status = status;
				gp_trackRoute(route);
			}
		});
	}
}

function gp_getActionsForRouteStops(routeStops, legs) {
	for (var i = 0; i < legs.length; i++) {
		if (!routeStops[i].sfdcId) continue;

		legs[i].start_address = '<div class="poiTitle">' + routeStops[i].name +'</div>'+ legs[i].start_address;

		var recId = routeStops[i].sfdcId;
		var poiCollection = {
			qo: {mapObjectName:routeStops[i].mapObjectName},
			"collectionName": "gpRouteStop",
		}

		var poi = {
			"uniqueId": routeStops[i].uniqueId,
			"recordId": routeStops[i].sfdcId,
			"title": routeStops[i].name,
			"title2": "",
			"lat": routeStops[i].lat,
			"lng": routeStops[i].lng,
			"street": routeStops[i].street,
			"city": routeStops[i].city,
			"postalCode": routeStops[i].postalCode,
			"state": routeStops[i].state,
			"country": routeStops[i].country,
			"sfdcObject": routeStops[i].mapObjectName,
		};

		legs[i].start_address += '<hr><div class="routeStop"><div class="poiTooltipButtons">' + buildPOIActions(poiCollection,poi,'button') + '</div>';
		legs[i].start_address += '<div class="poiTooltipActions">' + buildPOIActions(poiCollection,poi,'link') + '</div></div>';
	}	

	// Add info for the last stop
	i = legs.length;
	if (!routeStops[i].sfdcId) return;

	legs[i-1].end_address = '<div class="poiTitle">' + routeStops[i].name +'</div>'+ legs[i-1].end_address;

	recId = routeStops[i].sfdcId;
	poiCollection = {
		qo: {mapObjectName:routeStops[i].mapObjectName},
		"collectionName": "gpRouteStop",
	}

	poi = {
		"uniqueId": routeStops[i].uniqueId,
		"recordId": routeStops[i].sfdcId,
		"title": routeStops[i].name,
		"title2": "",
		"lat": routeStops[i].lat,
		"lng": routeStops[i].lng,
		"street": routeStops[i].street,
		"city": routeStops[i].city,
		"postalCode": routeStops[i].postalCode,
		"state": routeStops[i].state,
		"country": routeStops[i].country,
		"sfdcObject": routeStops[i].mapObjectName,
	};

	legs[i-1].end_address += '<hr><div class="routeStop"><div class="poiTooltipButtons">' + buildPOIActions(poiCollection,poi,'button') + '</div>';
	legs[i-1].end_address += '<div class="poiTooltipActions">' + buildPOIActions(poiCollection,poi,'link') + '</div></div>';
}

//Custom direction panel (from http://econym.org.uk/gmap/steps.htm) modified for v3 API
function gp_displayRouteNarrative(route, data){
	
	var html = "";
	var htmlPDF = "";
	var dtwaypoints=[];
	
	// Put results into a global variable
	var thisRoute = data.routes[0];
	
	// Determine the route order
	var locationsSequence = []
	locationsSequence.push(0); // push the origin into the array
	if (typeof(thisRoute.waypoint_order) != 'undefined'){
		for (var i=0; i < thisRoute.waypoint_order.length; i++) {
			locationsSequence.push(thisRoute.waypoint_order[i]+1); // waypoint order into the array
		}
	}
	locationsSequence.push(locationsSequence.length); // push the destination into the array
	
	// ===== local functions =====

	function staticMap(){
		// added to front of PDF
		var staticMapURL = 'https://maps.googleapis.com/maps/api/staticmap';
		staticMapURL += '?size=700x500';
		staticMapURL += '&maptype=roadmap';
		staticMapURL += '&format=png';
		staticMapURL += '&sensor=false';
		staticMapURL += '&path=enc:' + thisRoute.overview_polyline.points;
		
		var abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		for (var i=0; i < thisRoute.legs.length; i++) {
			staticMapURL += '&markers=color:green|label:' + abc.substring(i,i+1) + '|' + thisRoute.legs[i].start_location.lat() + ',' + thisRoute.legs[i].start_location.lng();
		}
		staticMapURL += '&markers=color:green|label:' + abc.substring(thisRoute.legs.length,thisRoute.legs.length+1) + '|' + thisRoute.legs[thisRoute.legs.length-1].end_location.lat() + ',' + thisRoute.legs[thisRoute.legs.length - 1].end_location.lng();
		
		htmlPDF =	'<table class="dirImageTable" border="0"><tr><td><img alt="'+gp_translations.Route_Overview_Map+'" id="googleStaticMapUrl" src="' + staticMapURL + '"/></td></tr></table>' + htmlPDF;
	}
	
	function datatable(){
		// added to front of PDF
		var tmp = '<div class="dirSection">'+gp_translations.Location_Summary+'</div>';
		tmp += 	'<table class="waySummary">' + 
						'<tr>' + 
						'<th width: 20px;">&nbsp;</td>' + 
						'<th style="vertical-align: middle;">'+gp_translations.Location_Name+'</td>' +
						'<th style="vertical-align: middle;">'+gp_translations.Street+'</td>' +
						'<th style="vertical-align: middle;">'+gp_translations.City+'</td>' +
						'<th style="vertical-align: middle;">'+gp_translations.State_Province+'</td>' +
						'<th style="vertical-align: middle;">'+gp_translations.Postal_Code+'</td>' +
						'<th style="vertical-align: middle;">'+gp_translations.Country+'</td>' +
						'</tr>';
		for (var i=0; i < dtwaypoints.length; i++) {
			tmp += dtwaypoints[i];
		}
		tmp += '</table>';
		htmlPDF = tmp + htmlPDF;
	}
	
	function warnings(){
		if (thisRoute.warnings){
			for (i = 0; i < thisRoute.warnings.length; i++) {
				var tmp = '<div class="dirWarnings"><b>' + thisRoute.warnings[i] + '</b></div><br/>';
				html += tmp;
				htmlPDF +=	tmp;
			}
		}
	}
	
	function summary(){ 
		var dist = 0; 
		var dur = 0; 
		var unit = '';
		for (var i=0; i < thisRoute.legs.length; i++) {
			dist += thisRoute.legs[i].distance.value; // in meters
			dur += thisRoute.legs[i].duration.value; // in seconds
		}
		if (route.units == 'k'){ 
			unit = gp_translations.Kilometers.toLowerCase();
			dist = dist/1000;
		} else {
			unit = gp_translations.Miles.toLowerCase();
			dist = dist / 1609.344;
		}

		var durationHours = Math.floor(dur/3600);
		var durationMinutes = Math.round( (dur/60)%60 );

		var minLabel = gp_translations.Mins.toLowerCase();
		if(durationMinutes == 1){
			minLabel = gp_translations.Min.toLowerCase();
		}

		var durationText = ' ('+gp_translations.Approximately.toLowerCase()+' '+durationHours;
		if(durationHours == 0){
			durationText = ' ('+gp_translations.Approximately.toLowerCase()+' '+durationMinutes+' '+minLabel+')';
		}else if(durationHours == 1){
			durationText += ' '+gp_translations.Hour.toLowerCase()+' ' + durationMinutes + ' '+minLabel+')' 
		}else{
			durationText += ' '+gp_translations.Hours.toLowerCase()+' ' + durationMinutes + ' '+minLabel+')' 
		}
		
		var tmp = '<div class="dirTotalTimeGOOG">' + 
				'<b style="padding: 0px 10px;">'+gp_translations.Total_Distance_and_Time.toUpperCase()+':</b> ' + Math.round(dist*100)/100 + ' ' + unit + durationText + 
				'</div>';
		
		html += tmp;
		htmlPDF += tmp;
		
	}
	
	// waypoint banner
	function waypoint(img, address, dist) {
		var tmp = 	'<table class="dirLegSummaryGOOG"><tr>' + 
					'<td style="padding: 4px 15px 4px 5px; vertical-align: middle; width: 20px;"><img src="' +img+ '"></td>' + 
					'<td style="vertical-align: middle; width: 760px;">' + address + '</td>' + 
					'<td style="vertical-align: middle; text-align: right; width: 200px;">' + dist + '</td>'
					'</tr></table>';
		html += tmp;
		htmlPDF += tmp;
		
	}
	
	// waypoints for data table
	function waypointInTable(img,thisLD){
		var tmp = 	'<tr>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); padding: 4px 15px 4px 5px; vertical-align: middle; width: 15px;"><img width="75%" height="75%" src="' +img+ '"></td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 150px;">' + thisLD.name + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 150px;">' + thisLD.street + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 80px;">' + thisLD.city + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 50px;">' + thisLD.state + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 60px;">' + thisLD.postalCode + '&nbsp;</td>' +
					'<td style="border-top: 1px solid rgb(205, 205, 205); vertical-align: middle; width: 80px;">' + thisLD.country + '&nbsp;</td>' +
					'</tr>';
		dtwaypoints.push(tmp);
	}

	// step detail
	function detail(num, description, step) {
		var tmp =	'<table class="dirManeuverGOOG"><tr>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px; vertical-align: top; text-align: right; width:20px;">' + num + '</td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px; vertical-align: top; width: 760px;">' + description + '</td>' + 
					'<td style="border-top: 1px solid rgb(205, 205, 205); margin: 0px; padding: 0.3em 5px 0.3em 0.5em; vertical-align: top; text-align: right; width:200px">' + step.distance.text + ' ('+ step.duration.text +')</td>' + 
					'</tr></table>';
		html += tmp;
		htmlPDF += tmp;
	}

	// Copyright tag
	function copyright(text) {
		var tmp = '<div style="font-size: 0.86em;">' + text + "</div>";

		html += tmp;
		htmlPDF += tmp;
	}
	
	// ===== start output =====
	
	// Warning messages
	warnings();
	
	htmlPDF += '<div style="margin: 20px 0 0 0;" class="dirSection">'+gp_translations.Detailed_Directions.toUpperCase()+'</div>';
	
	// Summary at the top of the route
	summary();
	
	// Read through the GRoutes and GSteps
	var abc = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	for (var i=0; i < thisRoute.legs.length; i++) {

		var thisLD = route.routeStops[i]; 
		var nextLD = route.routeStops[i+1];

		var thisLL = route.routeStops[i];
		var nextLL = route.routeStops[i+1];
		
		var img = "https://maps.google.com/mapfiles/marker_green" + abc.substring(i,i+1) + ".png"
		
		var leg = thisRoute.legs[i];

		// Assess geocode quality
		var poorGCImage = '<img src="' + gpImg.warning12 + '" alt="Poor Geocode Quality" />';
		var goodGCImage = '<img src="' + gpImg.confirm12 + '" alt="Good Geocode Quality" />';
		var fromGC = thisLD.geocodeQuality;
		var fromGCImage = poorGCImage;
		var toGC = nextLD.geocodeQuality;
		var toGCImage = poorGCImage;
		if (fromGC == 'POINT' || fromGC == 'ADDRESS' || fromGC == 'STREET' || fromGC == 'INTERSECTION' || fromGC == 'CUSTOM'){
			fromGCImage = goodGCImage;
		}
		if (toGC == 'POINT' || toGC == 'ADDRESS' || toGC == 'STREET' || toGC == 'INTERSECTION' || toGC == 'CUSTOM'){
			toGCImage = goodGCImage;
		}
		
		// To/From Waypoint info
		var fromAddr = thisLD.name + ' @ ' + thisLD.street + ' ' + thisLD.city + ', ' + thisLD.state + ' ' + thisLD.postalCode + ' ' + thisLD.country;
		if (fromGC == 'CUSTOM' && !thisLD.street){
			fromAddr = thisLD.name + ' @ ' + thisLL.lat + ' , ' + thisLL.lng;
		}
		fromAddr += '<i>&nbsp;('+gp_translations.Geocode_Quality+': ' + fromGCImage + '&nbsp;' + fromGC + ')</i><br/>';
		
		var toAddr = nextLD.name + ' @ ' + nextLD.street + ' ' + nextLD.city + ', ' + nextLD.state + ' ' + nextLD.postalCode + ' ' + nextLD.country;
		if (toGC == 'CUSTOM' && !nextLD.street){
			toAddr = nextLD.name + ' @ ' + nextLL.lat + ' , ' + nextLL.lng;
		}
		toAddr += '<i>&nbsp;('+gp_translations.Geocode_Quality+': ' + toGCImage + '&nbsp;' + toGC + ')</i><br/>';
		
		// Distance summary
		var distSum = leg.distance.text + ' ('+leg.duration.text +')';
		
		waypoint(img, fromAddr, distSum);
		
		waypointInTable(img, thisLD);
		
		for (var j=0; j< leg.steps.length; j++) {
			
			var step = leg.steps[j];
			
			// detail lines for each step
			detail(j+1, step.instructions, step);
		}
		
		
		if (i == thisRoute.legs.length-1){
			// the final destination waypoint
			var leg = thisRoute.legs[thisRoute.legs.length-1];
			var img = "https://maps.google.com/mapfiles/marker_green" + abc.substring(thisRoute.legs.length,thisRoute.legs.length+1) + ".png"
			waypoint(img, toAddr, '');
			waypointInTable(img, nextLD);
		}
	}
			 
	// the copyright text
	copyright(thisRoute.copyrights);

	// Add data table to the top of the PDF
	datatable();
	
	// Add static map to the top of the PDF
	staticMap();
	
	//Create a route tab under the map if it doesn't already exisit
	gp_createRouteTab(); //GeopointeJS

	gp_UIElem.hidden_htmlDirections.value = htmlPDF;
	
	jQuery("#routeNarrativeDIV").html(html);
	
	//Reset tab offsets as height of route tab content may have changed
	resetMapControlOffset('#routePanel'); 
}

// Removes the route and adds the markers back onto the map
function gp_resetCenterPOIContext(div){

	// Remove the route
	if (typeof(gp_dir) != 'undefined'){
		gp_dir.setMap(null);
		gp_dir.setPanel(null);
	}
	
	// Add back the markers onto the map
	for(var i in gp_markers) {
		gp_markers[i].setMap(gp_map);
	}
	gp_infoWindow.close();
	gp_tooltip.hide();
	for(var i in gp_cirOverlays) {
		gp_cirOverlays[i].setMap(gp_map);
	}
	for(var i in gp_kmlOverlays) {
		gp_kmlOverlays[i].setMap(gp_map);
	}
	
	// Best Fit
	gp_centerZoom(16);
	
	// Reload the Color By drop-down
	gp_UIElem.hidden_colorMarkersBy.value='';
	
	jQuery( "#theTabPanel" ).tabs("select",gp_JQTabs.mapDataSets);
	
	geopointeAjaxEnd();
}

//Runs a Search Nearby passing the center of the map along with the query
function gp_searchNearbyRecordsWrapper(isRemote,options){

	geopointeAjaxStart('body',gp_translations.Performing_a_Radial_Search + '...'); 
	
	// Clear the hidden data so we don't keep sending it to server
	gp_clearHiddenFields();
 	
	// Get Map Center
	var centerLat = gp_getCenterObject().lat;
	var centerLng = gp_getCenterObject().lng;

	//If options where provided with lat lng use these
	if(options && options.radialCenterLat && options.radialCenterLng){
		centerLat = options.radialCenterLat;
		centerLng = options.radialCenterLng;
	}

	// If we are in Search mode, add a POI to the map to act as the center
	if (loadWithCenterPOI == false || rightClickRepositionOccured == true){
		
		// Removing the center poi if it exists on the map
		if(gp_masterMarker != null){ 
			gp_removeMarkerMap(gp_masterMarker.uniqueID);
			gp_masterMarker = null;
		}
		
		var g_latlon = new google.maps.LatLng(centerLat, centerLng);
		gp_bounds.extend(g_latlon);
		
		tmpInfoContentHTML = '<span id="latLng"><b>'+gp_translations.Latitude+': </b>'+centerLat.toFixed(4)+'<br/><b>'+gp_translations.Longitude+': </b>'+centerLng.toFixed(4)+'<br/></span>'+ //hide after Geocode
		'<span id="address"/>'+ //Show after geocode

		'<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;">'+
			'<span style="font-size: 10pt;"><b>'+gp_translations.Map_Actions+':</b></span><br/>'+
			'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_searchRadialRemote(' + centerLat + ',' + centerLng + ');">'+gp_translations.Search_Nearby+'</span>'+
			'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + centerLat + ',' + centerLng + ',16);">'+gp_translations.Zoom_and_Center+'</span><br/>'+
			'<span id="routesAndLocations" style="display:none;">'+ // show after geocode 
				'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToRouteSearchOrCenterPOI(gp_centerPOI,\'center\');">'+gp_translations.Add_to_Route+'</span>'+
				'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToMyLocations(gp_radialAddress);">'+gp_translations.Save_to_My_Locations+'</span><br/>'+
			'</span>'+ 
			'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + centerLat + ',' + centerLng + ')">'+gp_translations.Street_View+'</span>'+
			'&nbsp;&nbsp;<a href="http://maps.google.com?q='+ centerLat +','+ centerLng +'" target="_blank">'+gp_translations.View_on_Google_Maps+'</a>';
		'</div>';

		//If this radial search was launched from a my location use that HTML
		if(options.keepSearchFromAddress && gp_searchPOI){
			tmpInfoContentHTML = gp_searchPOI.markerHtml;		
		}

		var g_marker = gp_createMarker(	g_latlon
										, '<b>'+gp_translations.Center_of_Map_for_Last_Radial_Search+'</b>', tmpInfoContentHTML
										, gpImg.center_pin2
										, 'gp_mapCenterPoi');
		
		gp_markers[g_marker.uniqueID] = g_marker;
		gp_masterMarker = g_marker;
		g_marker.setMap(gp_map);
		
		//Update search center title
		if(options.keepSearchFromAddress){
			//Keep the existing search from address
			
		}else{
			//Do reverse geocode and attempt to update address in the marker bubble
			var latlng = new google.maps.LatLng(centerLat,centerLng)

			var centerTitle = '';

			//Do the reverse geocode to get the address
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode({'latLng': latlng}, function(results, status) {

				if (status == google.maps.GeocoderStatus.OK) {

					//Set center search title
					centerTitle = results[0].formatted_address;

					//Split the address into two lines after the first commma,
					var firstCommaIndex = results[0].formatted_address.indexOf(',');
					
					if(firstCommaIndex > 0){
						centerTitle = results[0].formatted_address.substring(0,firstCommaIndex) + '<br/>' + results[0].formatted_address.substring(firstCommaIndex + 1,results[0].formatted_address.length);
					}
					
					//Parse google geocode and store result in var, store in case user wants to add to their saved locations
					gp_radialAddress = gp_parseGoogleGeocode(results[0]);

					//Update the gp_CenterPOI object
					gp_centerPOI.lat = results[0].geometry.location.lat();
					gp_centerPOI.lng = results[0].geometry.location.lng();
					gp_centerPOI.countryISO = gp_radialAddress.country;
					gp_centerPOI.title = gp_radialAddress.title;
					gp_centerPOI.street = gp_radialAddress.street;
					gp_centerPOI.city = gp_radialAddress.city;
					gp_centerPOI.state = gp_radialAddress.state;
					gp_centerPOI.postalCode = gp_radialAddress.postalCode;
					gp_centerPOI.country = gp_radialAddress.country;
					gp_centerPOI.geocodeQuality = 'CUSTOM';
					gp_centerPOI.usesCustomerGeocode = '';
					gp_centerPOI.recordId = '';

					//If the search center object has no values, set them as this is the first search
					if(!gp_radialSearchCenter.lat && !gp_radialSearchCenter.lng){
						gp_radialSearchCenter = {lat: gp_centerPOI.lat, 
  												 lng: gp_centerPOI.lng, 
 												 recordId: null};

 						gp_centerPointKeepAddress = true;
					}
					
					//Update the HTML for the gp_masterMarker
					if(gp_masterMarker.infoWindowHTML){
						//Show the Add To Route and Save to Locations links
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="routesAndLocations" style="display:none;">','<span id="routesAndLocations">');

						//Update the address, first hide the defaul address
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="latLng">','<span id="latLng" style="display:none;">');
						gp_masterMarker.infoWindowHTML = gp_masterMarker.infoWindowHTML.replace('<span id="address"/>','<span id="address">'+gp_radialAddress.fullAddress+'</span>');
					}
				}

				//Update the title
				jQuery("#centerContextTitleOutput").html(centerTitle);
				resetMapControlOffset("#dataSetPanel");

				//Called to reset the ActionFunction bug		
				gp_emptyActionFunction(); 
			});
		}	
	}
	
	gp_trackRadialSearch();
	
	if(isRemote != true){
		gp_searchNearbyRecords(centerLat,centerLng);// Action function that does the search
	}
	
}

function gp_removeCenterMarker(){
	// Removing the center poi if it exists on the map
	if(gp_masterMarker != null){ 
		gp_removeMarkerMap(gp_masterMarker.uniqueID);
		gp_masterMarker = null;
		jQuery("#centerContextTitleOutput").html('Center of the Map');
		resetMapControlOffset("#dataSetPanel");
	}
}

//Resizes the map to be the width of the div
function gp_resetMapWidth(){
	google.maps.event.trigger(gp_map, 'resize');

	//Resent legend max width
	setLegendMaxWidthHeight();
}

function gp_setMapHeight(height){
	if(height == 'auto'){
		height = getAutoMapHeight();
	}
	jQuery("#mapDIV").width('100%');
	jQuery("#mapDIV").height (height);
	google.maps.event.trigger(gp_map, 'resize');
	setRouteTabHeights();
	setMyLocationsTableMaxHeight();
	setDataSetTabMaxHeight();
	setLayersTableMaxHeight();
}

//Called from a link inside a POI to zoom down to that location
function gp_zoomToStreet(lat, lon, zoom){
	gp_map.setCenter(new google.maps.LatLng(lat, lon));
	gp_map.setZoom(zoom);
}

function gp_getZoomLevel(){
	return gp_map.getZoom();
}

function gp_centerZoomMyPosition(){

	//Dreamforce demo org
	if(gp_userSettings.userInfo.orgId == '00Do0000000bwHyEAI'){
		gp_map.setCenter(new google.maps.LatLng(37.784188, -122.401519));
		gp_map.setZoom(14);

	}else if (navigator.geolocation != null){
		navigator.geolocation.getCurrentPosition(function(position){
			gp_map.setCenter(new google.maps.LatLng(position.coords.latitude, position.coords.longitude));
	    	gp_map.setZoom(14);
		}, function() {
			jQuery.jGrowl(gp_translations.Your_browser_failed_to_determine_your_current_location);
	    });
	} else {
		jQuery.jGrowl(gp_translations.Your_browser_does_not_support_determination_of_your_current_location);
	}
}

function gp_centerRightClick(){
	//Recenter map
	gp_map.panTo(new google.maps.LatLng(rightClickLatLng.lat, rightClickLatLng.lng));
	gp_trackRightClick('Center');
}

function gp_bestFitRightClick(){
	gp_centerZoom();
	gp_trackRightClick('Show All Mapped Points');
}

function gp_streetViewRightClick(){
	gp_enableStreetView(rightClickLatLng.lat, rightClickLatLng.lng);
	gp_trackRightClick('Street View');
}

function gp_centerZoomRightClick(){
	gp_centerRightClick();

	//Based on current zoom level zoom in.
	var zoom = gp_getZoomLevel();
	var newZoom = 14; //Default
	if(zoom == 0){
		newZoom = 3;
	}else if(zoom == 1){
		newZoom = 5;
	}else if(zoom == 2){
		newZoom = 6;
	}else if(zoom == 3){
		newZoom = 7;
	}else if(zoom == 4){
		newZoom = 7;
	}else if(zoom == 5){
		newZoom = 9;
	}else if(zoom == 6){
		newZoom = 11;
	}else if(zoom == 7){
		newZoom = 11;
	}else if(zoom == 8){
		newZoom = 12;
	}else if(zoom == 9){
		newZoom = 13;
	}else if(zoom == 10){
		newZoom = 14;
	}else if(zoom == 11){
		newZoom = 15;
	}else if(zoom == 12){
		newZoom = 15;
	}else if(zoom == 13){
		newZoom = 16;
	}else if(zoom == 14){
		newZoom = 16;
	}else if(zoom == 15){
		newZoom = 18;
	}else if(zoom == 16){
		newZoom = 18;
	}else if(zoom == 17){
		newZoom = 19;
	}else if(zoom == 18){
		newZoom = 20;
	}else if(zoom == 19){
		newZoom = 20;
	}else if(zoom == 20){
		newZoom = 21;
	}else if(zoom == 21){
		newZoom = 21;	
	}

	gp_map.setZoom(newZoom);

	gp_trackRightClick('Center and Zoom');
}

function gp_openRigthClickMenu(e){
	gp_map.set('disableDoubleClickZoom', true); //disable double click zoom becuase of FF zoom out bug

	//Find the pixel position in the map
	var overlay = new google.maps.OverlayView();
	overlay.draw = function() {};
	overlay.setMap(gp_map);
	var projection = overlay.getProjection(); 
	var pixel = projection.fromLatLngToContainerPixel(e.latLng);

	//Create on object with coordinates and mouse position
	var clickInfo = {
		lat: e.latLng.lat(),
		lng: e.latLng.lng(),
		x: pixel.x,
		y: pixel.y
	};

	//Save the lat lng of the click in rightClickLatLng var so other methods have access
	rightClickLatLng = clickInfo;

	//Show the right click menu
	showMapContextMenu(clickInfo);
}

function gp_searchRadialRemoteRightClick(){
	//Recenter map
	gp_map.panTo(new google.maps.LatLng(rightClickLatLng.lat, rightClickLatLng.lng));

	//Set the right click repositioned flag to true so original centerPOI is not used
	rightClickRepositionOccured = true;

	//Wipe out the old center point poi
	gp_removeCenterPOIshapes();
	gp_centerPOI = {};
	gp_centerPointKeepAddress = false;

	//Set search center
	gp_radialSearchCenter = {lat: rightClickLatLng.lat, 
							 lng: rightClickLatLng.lng, 
							 recordId: null};

	//Do radial search
	gp_searchRadialRemote();

	gp_trackRightClick('Radial Search');
}

//Return an object with center info
function gp_getCenterObject(){
	var r = new Object();
	r.center = gp_map.getCenter();
	r.lat = r.center.lat();
	r.lng = r.center.lng();
	return r;
}




//Return an object with bounds
function gp_getBoundsObject(){
	var r = new Object();
	r.bounds = gp_map.getBounds();
	r.minLat = r.bounds.getSouthWest().lat();
	r.maxLat = r.bounds.getNorthEast().lat();
	r.minLng = r.bounds.getSouthWest().lng();
	r.maxLng = r.bounds.getNorthEast().lng();
	return r;
}

//A Best Fit function for Google Maps - depends upon the gp_bounds object being populated
function gp_centerZoom(){
	
	if (gp_activeMapMode == 'ROUTE' && typeof(gp_dir) != 'undefined'){
		gp_dir.setMap(gp_map);
	} else {
		if (gp_bounds.getCenter().lat() != 0 && gp_bounds.getCenter().lng() != -180){
			
			// Center
			gp_map.setCenter(gp_bounds.getCenter());
			
			// Zoom
			gp_map.fitBounds(gp_bounds);
			
			// an event listener will reset the zoom if its in too far
		}
	} 
	
}

// Open the Info Window
function gp_openPoiInfoMarker(markerID,sameLocationMarker) {
	var marker = gp_markers[markerID];
	
	if(sameLocationMarker){
		gp_infoWindow.setOptions({pixelOffset: {height: -28, width: 0}});
	}else{
		gp_infoWindow.setOptions({pixelOffset: {height: -16, width: 0}});
	}
	gp_infoWindow.setContent(marker.infoWindowHTML);
	gp_infoWindow.setPosition(marker.getPosition());
	gp_infoWindow.open(gp_map);
	gp_infoWindow.markerId = marker.uniqueID;
	gp_infoWindow.tabsDIV - null;
}

// Remove the marker from the map
function gp_removeMarkerMap(markerID) {

	// Remove marker from map
	gp_markers[markerID].setMap(null);

	//Remove selected checkbox marker for this marker
	if(gp_markers[markerID].selectedMarker){
		gp_markers[markerID].selectedMarker.setMap(null);
	}
	
	// Close info window if applicable
	if (markerID == gp_infoWindow.markerId){
		gp_infoWindow.close();
		gp_tooltip.hide();
	}
	
	// Remove from the gp_markers object
	delete gp_markers[markerID];

	//Recalc the samelocation markers
	gp_createSameLocationMarkers();
	
}

//Given a data set search collection name, remove those markers from the map
function gp_removeDataSetSearchFromMap(collectionName){

	//Loop through markers collection and remove those from map for the specified collection
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			gp_markers[key].setMap(null);

			//Remove the selected checkbox marker if there is one for the search marker
			if(gp_markers[key].selectedMarker){
				gp_markers[key].selectedMarker.setMap(null);
			}

			// Close info window if applicable
			if (gp_markers[key].uniqueID == gp_infoWindow.markerId){
				gp_infoWindow.close();
				gp_tooltip.hide();
			}
		}
	}

	//Remove any circles on the map related to this search
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			gp_cirOverlays[key].setMap(null);
		}
	}

	//Remove shape fields
	for(key in polygonObjects){
		if(polygonObjects[key].gpProperties.gpCollectionName == collectionName){
			polygonObjects[key].setMap(null);
		}
	}

	//Set markers visible flag to false for this search
	if(gp_dataSetSearches[collectionName]){
		gp_dataSetSearches[collectionName].markersVisible = false;
	}

	//Rebuild the same location markers
	gp_createSameLocationMarkers();
}

function gp_removeDataSetSearchTab(collectionName){

	//Remove markers from gp_markers object
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			gp_markers[key].setMap(null);
			delete gp_markers[key];
		}
	}

	//Remove circle from gp_cirOverlays object
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			gp_cirOverlays[key].setMap(null);
			delete gp_cirOverlays[key];
		}
	}

	//Remove shape fields
	for(key in polygonObjects){
		if(polygonObjects[key].gpProperties.gpCollectionName == collectionName){
			polygonObjects[key].setMap(null);
			delete polygonObjects[key];
		}
	}

	//Remove the tab and content
	jQuery(".dataSetResultTableTab[data-collectionName='"+collectionName+"']").remove();
	jQuery("#tabs-" + collectionName).remove();

	//Remove from gp_dataSetSearches object
	delete gp_dataSetSearches[collectionName];

	//Update the layers list with new record counts
	setTimeout(function(){
		angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
	},0);

	//If there no more result or route tabs show the no data message
	var $tabs = jQuery(".dataSetResultTableTab,#routeDirectionsTab");
	if($tabs.length == 0){
		jQuery("#gp_dataTablesNoData").show();
		jQuery("#gp_dataTables").hide();
	}else{ 
		jQuery($tabs[0]).find("a").click();
	}
}

function gp_restoreDataSetSearchOnMap(collectionName){
	//If markers where visibile before data set was removed from map, add them back
	for(key in gp_markers){
		if(gp_markers[key].collectionName == collectionName){
			gp_markers[key].setMap(gp_map);

			//Restore the selected checkbox marker if there is one
			if(gp_markers[key].selectedMarker){
				gp_markers[key].selectedMarker.setMap(gp_map);
			}
		}
	}

	//Add back any necessary circles
	for(key in gp_cirOverlays){
		if(key == collectionName + '_overlay'){
			gp_cirOverlays[key].setMap(gp_map);
		}
	}

	//Add shape fields
	for(key in polygonObjects){
		if(polygonObjects[key].gpProperties.gpCollectionName == collectionName){
			polygonObjects[key].setMap(gp_map);
		}
	}

	//Set markers visible flag to true for this search
	if(gp_dataSetSearches[collectionName]){
		gp_dataSetSearches[collectionName].markersVisible = true;
	}

	//Rebuild the same location markers
	gp_createSameLocationMarkers();
}

// Enable Street View
function gp_enableStreetView(lat,lng){
	jQuery("#mapContextMenu").hide();
	gp_map.getStreetView().setPosition(new google.maps.LatLng(lat,lng));
	gp_map.getStreetView().setVisible(true);
}


//Toggles the Traffic Overlay
function gp_toggleTraffic() {
	try{
		if (gp_trafficState) {
			gp_traffic.setMap(null);
			gp_trafficState = false;
			jQuery('#buttonTrafficLayer').val(gp_translations.Toggle_Traffic_On);
			gp_trackLayerToggle('Traffic','Off');
		} else {
			gp_traffic.setMap(gp_map);
			gp_trafficState = true;
			jQuery('#buttonTrafficLayer').val(gp_translations.Toggle_Traffic_Off);
			gp_trackLayerToggle('Traffic','On');
		}
		gp_setTrafficIcon();
		return false;
	} catch(e){
		alert(e); 
		geopointeAjaxEnd();
		return false;
	}
}

function gp_setTrafficIcon(){
	//Hide all the traffic icons
	jQuery('.trafficIcon').hide();
	var mapType = gp_map.getMapTypeId();

	//Only proceed if google
	if(gp_trafficState){ //traffic layer is on
		if(mapType == 'sat' || mapType == 'satellite' || mapType == 'hyb' || mapType == 'hybrid'){
			jQuery(".trafficLightWhiteColor").show();
		}else{
			jQuery(".trafficLightBlackColor").show();
		}
	}else{ // traffic layer is off
		if(mapType == 'sat' || mapType == 'satellite' || mapType == 'hyb' || mapType == 'hybrid'){
			jQuery(".trafficLightWhite").show();
		}else{
			jQuery(".trafficLightBlack").show();
		}
	}
}

function __PLACES__(){}
//Add a Places result to the map as a layer
function gp_addPlaces(data){
	
	// NOKIA
	if (typeof(data.results) == "undefined"){return;}
	if (typeof(data.results.items) == "undefined"){return;}

	// icons are 60x65
	var icon_w = 60*.6; 
	var icon_h = 65*.6;
	
	gp_clearPlaces();
	
	var added = false;
	jQuery.each(data.results.items, function(index, poi) {
		
		if(poi.type=='urn:nlp-types:place'){
			var lat = poi.position[0];
			var lng = poi.position[1];
			if (!jQuery('#gp_placesRestrictSearchArea').is(':checked') || gp_latLngInBounds(lat,lng)){
				var g_latlon = new google.maps.LatLng(lat, lng);
				gp_placeBounds.extend(g_latlon);
				var placeInfo =	{	"gp_placeId":poi.id, 
									"gp_placeURL":poi.href,
									"gp_placeLat":lat,
									"gp_placeLng":lng,
									"gp_iconURL":poi.icon.replace("http://","https://"),
									"gp_iconW":icon_w,
									"gp_iconH":icon_h,
									"gp_placeSponsored":false
								}
				if(typeof(poi.sponsored)!="undefined"){if(poi.sponsored){obj.gp_placeSponsored=true;}}
				var g_icon = new google.maps.MarkerImage(	poi.icon.replace("http://","https://"),
															null,
															null,
															null,
															new google.maps.Size(icon_w,icon_h)
															);
				var g_marker = gp_createMarker(g_latlon, poi.title, 'TBD', g_icon, poi.id, placeInfo);
				if(poi.id != ''){
					gp_markersPlaces[poi.id] = g_marker;
				}
				g_marker.setMap(gp_map);
				added = true;
			}
		}
		
	});
	
	if (added){
		gp_centerZoom(16);
		gp_map.setCenter(gp_placeBounds.getCenter());
		gp_map.fitBounds(gp_placeBounds);
	} else {
		jQuery.jGrowl(gp_translations.No_results_were_found_that_met_your_search_criteria, { life: 5000 });
	}
	
}

function gp_clearPlaces(){
	gp_placeBounds = new google.maps.LatLngBounds();
	for(var i in gp_markersPlaces) {
		gp_markersPlaces[i].setMap(null);
	}
	gp_markersPlaces = new Object();
}

function gp_placesInfoWindowHandler(placeInfo,marker){
	var url = placeInfo.gp_placeURL.replace("http://","https://");
	jQuery.ajax({
		url: url,
		dataType: 'jsonp',
		type: 'GET',
		crossDomain: true,
		success: function(data, textStatus, XMLHttpRequest){
			var html = gp_buildPlacesInfoContent(data,placeInfo);
			gp_infoWindow.setContent(html);
			gp_infoWindow.setPosition(marker.getPosition());
			gp_infoWindow.setOptions({pixelOffset: {height: -29, width: -3}});
			gp_infoWindow.open(gp_map);
			gp_infoWindow.markerId = marker.uniqueID;
			gp_infoWindow.tabsDIV = null;
			gp_tooltip.hide();
		}
	});
}

function gp_updateSearchMarker(address,isGotoMyLocation){
	
	//1 Center the map on result
	gp_map.panTo(new google.maps.LatLng(address.lat,address.lng));

	if(gp_getZoomLevel() < 13){
		gp_map.setZoom(13);
	}

	//2 Remove existing center map marker if it exists
	if(gp_searchMarker != null &&  gp_markers['gp_mapSearchPoi']){ 
		gp_removeMarkerMap(gp_searchMarker.uniqueID);
		gp_searchMarker = null;
	}
	
	//3 Add new center map marker
	var g_latlon = new google.maps.LatLng(address.lat, address.lng);

	//Set option to keep center address for marker and "Search Center" on dataset 
	var keepSearchFromAddress = false;
	if(isGotoMyLocation || address.keepAddress){
		keepSearchFromAddress = true;
	}

	//Update search center location
	gp_radialSearchCenter = {lat: address.lat, 
							 lng: address.lng, 
							 recordId: null};
	jQuery('#centerContextTitleOutput').html(address.fullAddress);
	resetMapControlOffset("#dataSetPanel");

	
	tmpInfoContentHTML = '';
	if(address.title){
		tmpInfoContentHTML += '<strong><u>'+address.title+'</u></strong>';
	}
	tmpInfoContentHTML += '<div>'+address.fullAddress+'</div>'+
	'<div style="margin: 5px 0; padding: 5px; background-color: #efebe2; line-height:1.5em;">'+
		'<span style="font-size: 10pt;"><b>'+gp_translations.Map_Actions+':</b></span><br/>'+
		'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_searchRadialRemote(' + address.lat + ',' + address.lng + ',' + keepSearchFromAddress +'); return false;">'+gp_translations.Search_Nearby+'</span>'+
		'&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_zoomToStreet(' + address.lat + ',' + address.lng + ',16);">'+gp_translations.Zoom_and_Center+'</span><br/>'+
		'<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToRouteSearchOrCenterPOI(gp_searchPOI,\'search\');">'+gp_translations.Add_to_Route+'</span>';
		//Only show this if was an address search, not a goto location
		if(isGotoMyLocation != true){
			tmpInfoContentHTML += '&nbsp;&nbsp;<span style="text-decoration:underline; cursor:pointer;" onclick="gp_addToMyLocations(gp_searchAddress);">'+gp_translations.Save_to_My_Locations+'</span>';
		}
		tmpInfoContentHTML += '<br/><span style="text-decoration:underline; cursor:pointer;" onclick="gp_enableStreetView(' + address.lat + ',' + address.lng + ')">'+gp_translations.Street_View+'</span>'+
		'&nbsp;&nbsp;<a href="http://maps.google.com?f=q&q='+ address.singleLineAddress +'" target="_blank">'+gp_translations.View_on_Google_Maps+'</a>';
	'</div>';

	//Update html on searchPOI object
	if(gp_searchPOI){
		gp_searchPOI.markerHtml = tmpInfoContentHTML;
	}

	var image = {
	    url: searchPinURL,
	    scaledSize: new google.maps.Size(25, 40), // This marker is 20 pixels wide by 32 pixels tall.
	    anchor: new google.maps.Point(13, 32) // The anchor for this image is the base of the flagpole at 0,32.
	};

	var g_marker = gp_createMarker(g_latlon
									, '<b>'+address.singleLineAddress+'</b>'
									,tmpInfoContentHTML 
									, image
									, 'gp_mapSearchPoi');


	
	
	gp_markers[g_marker.uniqueID] = g_marker;
	gp_searchMarker = g_marker;
	g_marker.setMap(gp_map);
}

//--------DRAWING AND POLYGON/SHAPE SEARCH METHODS----------
var polygonObjects = {}; //keeps track of polygons on the map

function gp_enterDrawMode(){
	
	//Remove selected class from other drawtool buttons*/
	jQuery(".drawToolOption").removeClass('gp-btn-selected');
			
	//Add the selected class to the polygon drawtool
	jQuery("#drawPolygon").addClass('gp-btn-selected');

	//Enable drawing mode
	if(gp_drawingManager){
		gp_drawingManager.setMap(gp_map);

		//Default to polygon
		gp_drawingManager.setDrawingMode(google.maps.drawing.OverlayType.POLYGON);
	}

	//Reset tab offset as height of panel changed
	if(gp_mapMode != 'addShape'){
		resetMapControlOffset('#dataSetPanel');
	}
}

function gp_exitDrawMode(){
	jQuery(".drawToolOption").removeClass('gp-btn-selected');
	jQuery("#drawHand").addClass('gp-btn-selected');
	if(gp_drawingManager){
		gp_drawingManager.setDrawingMode(null);
	}
}

function doPolygonSearch(params){ //{overlayId: id of shape, groupLayerId: id group layer, jqThis: jQuery(this)}
	//If there are no polygons add one to the map and do not perform the search
	if(jQuery.isEmptyObject(polygonObjects)){
		gp_enterDrawMode();

	}else{
		
		//Show modal and track search
		geopointeAjaxStart('body',gp_translations.Performing_a_Shape_Search + '...'); 
		gp_trackShapeSearch();

		//Create options object
		var options = {};
		options.searchType = 'shape';

		//Loop through all of the objects on the map and build bound boxes for each shape
		var shapeBoundBoxes = [];
		
		//If overlay id for a shape was defined only search this bound box
		if(params.overlayId){
			var bounds = polygonObjects[params.overlayId].getBounds();

			var boundBox = {
				minLat: bounds.getSouthWest().lat(),
				maxLat: bounds.getNorthEast().lat(),
				minLng: bounds.getSouthWest().lng(),
				maxLng: bounds.getNorthEast().lng()
			}
			shapeBoundBoxes.push(boundBox);

			//Set id of over lay that is being searched on the options object
			options.groupLayerId = params.groupLayerI;

		}else{ //Else is a groupLayer search, a Geo Shape search
			
			//Create an object of groupLayerId to a bounding box, as one layer could be comprised of many parts but we only want one bbox
			var groupLayerIdBbox = {};

			//Create search bounds for all of the shapes
			for(key in polygonObjects){
				var layer = polygonObjects[key];
				var groupLayerId = layer.gpProperties.groupLayerId;
				
				//Only process layers with groupId that was provided, if it wasnt search all shapes
				if(typeof params.groupLayerId == 'undefined' || params.groupLayerId == layer.gpProperties.groupLayerId ){
					if(typeof groupLayerIdBbox[layer.gpProperties.groupLayerId] == 'undefined'){
						groupLayerIdBbox[groupLayerId] = new google.maps.LatLngBounds();
					}

					//Extend the bounding box for this layer
					groupLayerIdBbox[groupLayerId].extend(layer.getBounds().getNorthEast());
					groupLayerIdBbox[groupLayerId].extend(layer.getBounds().getSouthWest())
				}
			}

			//Now for each layer that has a bounding box populate array of bboxes that will be used in search
			for(key in groupLayerIdBbox){
				var bounds = groupLayerIdBbox[key];

				var boundBox = {
					minLat: bounds.getSouthWest().lat(),
					maxLat: bounds.getNorthEast().lat(),
					minLng: bounds.getSouthWest().lng(),
					maxLng: bounds.getNorthEast().lng()
				}
				shapeBoundBoxes.push(boundBox);
			}

			//Set group layer Id so we only check for pois in this group of shapes being searched
			options.groupLayerId = params.groupLayerId;
		}

		//Add bound boxes to options
		options.shapeBoundBoxes = shapeBoundBoxes;

		//Show the data set section by 'clicking the back to search button'
		jQuery("#drawCancel").click();

		//Remove the center marker
		gp_removeCenterMarker();

		//Do the search and pass in the options
		gp_doSearch(options);

	}
}

function gp_shapeAddedToMap(overlay,type){
	//Exit draw mode
	gp_exitDrawMode();

	//Create a gpProperties object if it does not exist
	if(typeof overlay.gpProperties == 'undefined'){
		overlay.gpProperties = {};
	}	

	//Calculate and set the bounds for this 
	gp_updateBoundsOnOverlay(overlay);

	//Create a unique Id for this overlay
	overlay.gpProperties.uniqueId = guid();

	//Create a group layer Id if one does not alreay exist
	if(typeof overlay.gpProperties.groupLayerId == 'undefined'){
		overlay.gpProperties.groupLayerId = guid();
	}

	//Set custom properties to empty string if they are null
	if(!overlay.gpProperties.sfdcName){
		overlay.gpProperties.sfdcName = '';
	}
	if(!overlay.gpProperties.sfdcDescription){
		overlay.gpProperties.sfdcDescription = '';
	}

	buildShapeInfoWindowHTML(overlay);

	//Set type
	overlay.gpProperties.gpType = type.toLowerCase();

	//Specialy handling for shape fields
	if(!overlay.gpProperties.usageType){
		overlay.gpProperties.usageType = 'Standard';
		if(gp_mapMode == 'addShape'){
			overlay.gpProperties.usageType = 'Shape Field';

			//Set different color
			var controller = angular.element('.shapeFieldTypeController').scope();
			var color = controller.color;
			if(color.indexOf('#') != 0){
				color = '#' + color;
			}

			overlay.setOptions({clickable: false, fillColor: color, fillOpacity: controller.opacity});

			//Set overlay in controller
			controller.overlay = overlay;
		}
	}

	//Add the polygon to the polygonObjects object to keep track of shapes on the map
	polygonObjects[overlay.gpProperties.uniqueId] = overlay;

	//Update record count in shapes
	calcRecordsInShapes();

	//Add event listener to the polygon overlay to open the infowindow popup bubble
	google.maps.event.addListener(overlay, 'click', function(e) {
		gp_infoWindow.setOptions({pixelOffset: {height: 0, width: 0}});
		gp_infoWindow.setContent(overlay.gpProperties.htmlContent);
		gp_infoWindow.setPosition(e.latLng);
		gp_infoWindow.open(gp_map);
	});

	//Event listeners for when polygon shape changes
	google.maps.event.addListener(overlay, 'mousedown', function(e) {
		if(overlay.gpProperties.gpType == 'polygon'){
			google.maps.event.addListener(overlay.getPath(), 'set_at', function() {
				gp_updateBoundsOnOverlay(overlay);
	            calcRecordsInShapes();
	        });
			google.maps.event.addListener(overlay.getPath(), 'insert_at', function() {
				gp_updateBoundsOnOverlay(overlay);
	            calcRecordsInShapes();
	        });
	        google.maps.event.addListener(overlay.getPath(), 'remove_at', function() {
	        	gp_updateBoundsOnOverlay(overlay);
	            calcRecordsInShapes();
	        });
    	}
	});

	//http://stackoverflow.com/questions/5560248/programmatically-lighten-or-darken-a-hex-color-or-rgb-and-blend-colors
	function lightenDarkenHex(color, percent) {   
	    var f=parseInt(color.slice(1),16),t=percent<0?0:255,p=percent<0?percent*-1:percent,R=f>>16,G=f>>8&0x00FF,B=f&0x0000FF;
	    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1);
	}

	//Event listen to change the color slightly on hover
	google.maps.event.addListener(overlay, 'mouseover', function(e) {
		overlay.gpProperties.originalOpacity = parseFloat(overlay.fillOpacity);
		overlay.gpProperties.originalColor = overlay.fillColor;
		
		//Only set darker opacity if it is less or equal to 70
		var newOpacity = parseFloat(overlay.fillOpacity);
		if(newOpacity <= .70) newOpacity += 0.20;

		var newColor = lightenDarkenHex(overlay.fillColor,-0.2);

		overlay.setOptions({fillOpacity: newOpacity, fillColor: newColor}); 
	});

	google.maps.event.addListener(overlay, 'mouseout', function(e) {
		//For all polygons that are part of this layer change the color back to orginal before hover
		overlay.setOptions({fillOpacity: overlay.gpProperties.originalOpacity, fillColor: overlay.gpProperties.originalColor}); 
	});

	//Create a right click event listener on the shape to open the right click context menu
	google.maps.event.addListener(overlay, 'rightclick', function(e) {
		gp_openRigthClickMenu(e); //Open the right click menu
	});
}

function gp_updateBoundsOnOverlay(overlay){
	
	try{
		if(overlay && overlay.gpProperties.usageType != 'Shape Field'){ //getPaths() check makes sure it is a polygon and not a shape file server

			var bounds = new google.maps.LatLngBounds();
		    var paths = overlay.getPaths();
		    var path;        
		    for (var i = 0; i < paths.getLength(); i++) {
		        path = paths.getAt(i);
		        for (var ii = 0; ii < path.getLength(); ii++) {
		            bounds.extend(path.getAt(ii));
		        }
		    }
		    overlay.gpProperties.bounds = bounds;
		}
	}catch(e){
		//Some shapes like circles wont be able to calc bounds as there is no getPaths() method
	}
}

function getShapeBubbleRecordCountHtml(overlay){

	var html = '<div id="shapeRecordCounts" style="margin-bottom: 6px; font-size: 12px;">';

	//Record Counts
	for(key in overlay.gpProperties.recordCounts){
		//Get the label
		var objectLablePlural = gp_objectMeta[key].objectLablePlural;
		html += '<div style="margin-bottom: 2px;"><span style="font-weight:bold;">' + objectLablePlural + '</span>: ' + overlay.gpProperties.recordCounts[key] + '</div>';
	}

	//Aggregations
	for(key in overlay.gpProperties.aggregations){
		//Get the label
		var amount = overlay.gpProperties.aggregations[key].amount;
		var formattedAmount = angular.injector(["ng"]).get("currencyFilter")(amount,gp_userSettings.userInfo.userCurrency.symbol);

		//Append to html
		html += '<div style="margin-bottom: 2px;"><span style="font-weight:bold;">' + overlay.gpProperties.aggregations[key].label + '</span>: ' + formattedAmount + '</div>';
	}

	html += '</div>';

	return html;
}

function buildShapeInfoWindowHTML(overlay){

	//Only show delete button if record has sfdc id
	var deleteDisplay = 'none';
	if(overlay.gpProperties.sfdcId){
		deleteDisplay = '';
	}

	var html = '<div style="max-width:240px; min-width: 80px;" id="'+overlay.gpProperties.uniqueId+'">'+
				'<div id="shapeBubbleTitle" >';
				if(overlay.gpProperties.usageType == 'Shape Field' && overlay.gpProperties.gpPoiId){
	html+=			'<a href="#" onclick="gp_openPoiInfoMarker(\''+overlay.gpProperties.gpPoiId+'\',true); return false;">'+overlay.gpProperties.sfdcName+'</a>';    
				}else{
	html+=			'<div style="width: 200px;">'+overlay.gpProperties.sfdcName+'</div>';
				}
	html+=		'</div>'+
				'<div id="shapeBubbleDescription">'+overlay.gpProperties.sfdcDescription.replace(/(?:\r\n|\r|\n)/g, '<br />')+'</div>'+
				'<div id="shapeRecordCountWrapper">';
				
					if(overlay.gpProperties.recordIdsInShape && overlay.gpProperties.recordIdsInShape.length > 0){
						html+= getShapeBubbleRecordCountHtml(overlay);
					}

	html+=		'</div>';

				//Don't show the shape actions if map mode is addShape 
				if(gp_mapMode != 'addShape' || overlay.gpProperties.sfdcId){
	html+=			'<div class="shapeEditButtons">'+
						'<span id="shapeActionsBtn" class="gpButton openMultiButtonOptions" onclick="showShapeActions(\''+overlay.gpProperties.uniqueId+'\');"/>'+
		                    '<div class="multiButtonInner multiButtonLeftLarge noRightBorder">'+
		                        'Actions'+
		                    '</div>'+
		                    '<div class="multiButtonInner multiButtonRightLarge">'+
		                        '<span class="ui-icon ui-icon-triangle-1-s" style="margin-top: 2px;"></span>'+
		                    '</div>'+
		                '</span>'+
					'</div>';
				}

				if(overlay.gpProperties.usageType != 'Shape Field'){			
	html+=		    '<div style="height: 165px; margin-left: 4px;" class="gp_ShapeColorDiv"><input type="text" class="gp_shapeColorInput" data-shapeId="'+overlay.gpProperties.uniqueId+'" data-groupLayerId="'+overlay.gpProperties.groupLayerId+'" value="E7DC40" id="shapeColor'+overlay.gpProperties.uniqueId+'"/></div>'+
					'<style>.gp_ShapeColorDiv .minicolors-theme-geopointe .minicolors-panel{top: 4px}</style>'+
					'</div>';	
				}


	overlay.gpProperties.htmlContent = html;
}

function showShapeActions(shapeId){
	//Get the shape
	var shape = polygonObjects[shapeId];

	var $shapeActionBtn = jQuery("#shapeActionsBtn");
	var actionButtonOffset = $shapeActionBtn.offset();

	//Only show delete button if record has sfdc id, TODO remove this, moved to edit modal
	var deleteDisplay = 'none';
	if(shape.gpProperties.sfdcId){
		deleteDisplay = '';
	}

	//Determine if this is a multi part shape, ie one layer consisting of many sub shapes
	var multiPartShape = false;
	if(shape.gpProperties.usageType == 'GeoShape' && shape.gpProperties.uniqueId != shape.gpProperties.groupLayerId){
		multiPartShape = true;
	}

	//Remove action menu element already exists
	jQuery(".shapeActionMenu").remove();

	var saveMethod = 'gp_saveShape';
	if(shape.gpProperties.usageType == 'GeoShape') saveMethod = 'gp_editShape';

	var htmlString = '<div class="multiButtonContent shapeActionMenu">';
						if(multiPartShape){
	htmlString+=			'<div class="multiButtonOptionHeader">'+shape.gpProperties.sfdcName+'</div>';
						}
	
						if(shape.gpProperties.usageType == 'GeoShape'){
	htmlString+=       		'<div class="multiButtonOption" onclick="doPolygonSearch({groupLayerId: \''+shape.gpProperties.groupLayerId+'\'}); return false;">'+
	                        	'<span class="multiButtonOptionText">'+
	                            	gp_translations.Search+
	                        	'</span>'+   
	                    	'</div>';
						}else{
	htmlString+=       		'<div class="multiButtonOption" onclick="doPolygonSearch({overlayId: \''+shape.gpProperties.uniqueId+'\'}); return false;">'+
	                        	'<span class="multiButtonOptionText">'+
	                            	gp_translations.Search+
	                        	'</span>'+   
	                    	'</div>';
						}
	htmlString+=        '<div class="multiButtonOption" onclick="gp_removeShape(\''+shape.gpProperties.uniqueId+'\'); return false;">'+
	                        '<span class="multiButtonOptionText">'+
	                            gp_translations.Remove+
	                        '</span>'+   
	                    '</div>'+
	                    '<div class="multiButtonOption" onclick="gp_editShape(\''+shape.gpProperties.uniqueId+'\'); return false;">'+
	                        '<span class="multiButtonOptionText">'+
	                            gp_translations.Edit+
	                        '</span>'+   
	                    '</div>';
	                    if(shape.gpProperties.usageType != 'Shape Field'){
							if(shape.gpProperties.usageType != 'GeoShape'){
	htmlString+=        		'<div class="multiButtonOption" onclick="'+ saveMethod +'(\''+shape.gpProperties.uniqueId+'\'); return false;">'+
		                        	'<span class="multiButtonOptionText">'+
		                            	gp_translations.Save+
		                        	'</span>'+   
		                    	'</div>';
							}
		                    
		                    if(shape.gpProperties.sfdcId && shape.gpProperties.usageType != 'GeoShape'){
	htmlString+=	        	'<div class="multiButtonOption" onclick="window.open(\'/p/share/CustomObjectSharingDetail?parentId='+shape.gpProperties.sfdcId+'\'); return false;">'+
			                        '<span class="multiButtonOptionText">'+
			                            'Sharing'+
			                        '</span>'+   
			                    '</div>';
		                	}
						}

						if(shape.gpProperties.usageType != 'GeoShape'){	
	htmlString+=        	'<div class="multiButtonOption" onclick="gp_deleteShapeConfirm(\''+shape.gpProperties.uniqueId+'\'); return false;" style="display: '+deleteDisplay+';" >'+
		                        '<span class="multiButtonOptionText">'+
		                            gp_translations.Delete+
		                        '</span>'+   
		                    '</div>';
	                	}


	//Build html for custom list actions
	var actionsHTML = getCustomShapeActionsHTML(shape,shape.gpProperties.groupLayerId);
	
	//If there were custom actions add to list of options
	if(actionsHTML != ''){
		htmlString += '<hr/>';
		htmlString += actionsHTML;
	}

	//If this was a multipart shape build actions specific to the sub shape that was selected
	if(multiPartShape){
		htmlString += '<div class="multiButtonOptionHeader">'+shape.gpProperties.geoShapeName+'</div>';
		htmlString+=  '<div class="multiButtonOption" onclick="doPolygonSearch({overlayId: \''+shape.gpProperties.uniqueId+'\'}); return false;">'+
	                        '<span class="multiButtonOptionText">'+
	                            gp_translations.Search+
	                        '</span>'+   
	                    '</div>'+
	                    '<div class="multiButtonOption" onclick="gp_removeSubShape(\''+shape.gpProperties.uniqueId+'\'); return false;"">'+
	                        '<span class="multiButtonOptionText">'+
	                            gp_translations.Remove+
	                        '</span>'+   
	                    '</div>';
		
	    var actionsHTML = getCustomShapeActionsHTML(shape,shape.gpProperties.uniqueId);
	
		//If there were custom actions add to list of options
		if(actionsHTML != ''){
			htmlString += '<hr/>';
			htmlString += actionsHTML;
		}
	}

	htmlString += '</div>';

   	gp_disableMultiButtonContentClose = true;
    jQuery(htmlString).appendTo('body').show().css({top: actionButtonOffset.top + $shapeActionBtn.outerHeight() , left: actionButtonOffset.left  });
    setTimeout(function(){
    	gp_disableMultiButtonContentClose = false;	
    },1);
}

function getCustomShapeActionsHTML(shape,shapeId){

	var objects = {}; //Use object keys to keep unique list of map objects
	var actionsHTML = '';

	//Build a list off objects in which we should build the action list for
	for(key in shape.gpProperties.recordCounts){
		objects[key] = true;
	}

	//Loop through all of the geopointe actions
	for(var i = 0; i < getOrderedActionsArray().length; i++){
		var action = getOrderedActionsArray()[i];
		var actionObjects;
		if(action.mapObjects){
			actionObjects = action.mapObjects.split(',');
		}
		var actionValidForObjects = false;

		//Check to see if this action should be applied to any of the data set searches based on the map object
		for(key in objects){
			if(actionObjects.indexOf(key) > -1){
				actionValidForObjects = true;
				break;
			}
		}

		//Only build an action if it is for all objects or one of the searched objects
		if(action.applyTo == 'List' && (action.allObjects == true || actionValidForObjects == true) ){

			if(action.standardAction){
				/* all these methods need to be refactored to work with shapes
				if(action.standardAction.toLowerCase() == 'add all to route'){
					actionsHTML += '<div class="multiButtonOption" onclick="gp_addAllToRoute();">'+
				                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
				                    '</div>';

				}else if(action.standardAction.toLowerCase() == 'add to campaign'){
					actionsHTML += '<div class="multiButtonOption" onclick="gp_addToCampaign(); return false;">'+
				                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
				                    '</div>';

				}else if(action.standardAction.toLowerCase() == 'change owner'){
					actionsHTML += '<div class="multiButtonOption" onclick="gp_trackChangeOwner(); executeListPOSTAction(\''+action.id+'\');">'+
				                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
				                    '</div>';

				}else if(action.standardAction.toLowerCase() == 'export csv' && gp_userSettings.userInfo.exportReports){
					actionsHTML += '<div class="multiButtonOption" onclick="return gp_writeCSV();"">'+
				                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
				                    '</div>';

				}else if(action.standardAction.toLowerCase() == 'export kml' && gp_userSettings.userInfo.exportReports){
					actionsHTML += '<div class="multiButtonOption" onclick="return gp_writeKML();">'+
				                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
				                    '</div>';
				}*/
			}else if(action.actionType == 'Apex'){
				//Custom actions				
				actionsHTML += '<div class="multiButtonOption" onclick="executeShapeApexAction(\''+action.id+'\',\''+shapeId+'\');">'+
			                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
			                    '</div>';

			}else if(action.actionType == 'POST (Visualforce)'){
				actionsHTML += '<div class="multiButtonOption" onclick="executeShapePOSTAction(\''+action.id+'\',\''+shapeId+'\');">'+
			                        '<span class="multiButtonOptionText">'+action.name+'</span>'+   
			                    '</div>';
			}
		}
	}

	return actionsHTML;
}

function gp_editShape(uniqueId){
	
	//Get the shape
	var overlay = polygonObjects[uniqueId];

	//Unique Id may have been a groupingId for a geoshape, try to find overlay with this
	if(!overlay){
		for(key in polygonObjects){
			if(polygonObjects[key].gpProperties.groupLayerId == uniqueId){
				overlay = polygonObjects[key];
				break;
			}
		}
	}

	if(overlay.gpProperties.usageType == 'GeoShape'){
		//Setup the geo shape controller
		var controller = angular.element('.geoShapeController').scope();

		controller.isEdit = true;
		controller.sfdcId = overlay.gpProperties.sfdcId;
		controller.groupLayerId = overlay.gpProperties.groupLayerId;
		controller.uniqueId = uniqueId;
		controller.layerName = overlay.gpProperties.sfdcName;
		controller.color = overlay.fillColor;
		controller.opacity = overlay.fillOpacity;
		controller.usedInAssignments = overlay.gpProperties.usedInAssignments;
		controller.selectedGeoShapes = {};
		controller.initList = true;
		controller.$broadcast('resetGeoShapeSelector');

		//If overlay contains geoshape Id and name, no need to fetch these from API, rebuild the geoshapes
		if(overlay.gpProperties.geoShapeId && overlay.gpProperties.geoShapeName && overlay.gpProperties.geoShapeType){
			//Loop through all the polygon overlay objects
			for(key in polygonObjects){
				
				var thisOverlay = polygonObjects[key];

				//If this polygon is part of the larger shape add it to list of selected geo shapes
				if(thisOverlay.gpProperties.groupLayerId == overlay.gpProperties.groupLayerId){
					controller.selectedGeoShapes[thisOverlay.gpProperties.geoShapeId] = {
						id: thisOverlay.gpProperties.geoShapeId,
						name: thisOverlay.gpProperties.geoShapeName,
						type: thisOverlay.gpProperties.geoShapeType
					}
				}
			}
		}

		//Execute apply on the controller so UI updates as this is outsite scope of angular
		setTimeout(function(){
			controller.$apply();
		},0);
		
		var title = 'Edit Shape - ' + overlay.gpProperties.sfdcName;
		var height = overlay.gpProperties.usedInAssignments ? 638 : 600; 

		jQuery( "#geoShapeModal" ).dialog({
			height: height,
			width: 800,
			modal: true,
			title: title,
			resizable: false,
			draggable: false,
			dialogClass: 'dataSetEditModalWrapper gp-modal',
			open: function( event, ui ) {
				//Set height of modal content
				setGPmodalContentHeight(jQuery(this));
			}
		});
	
	}else if(overlay.gpProperties.usageType == 'Shape Field'){

		gp_mapMode = 'addShape';
		gp_infoWindow.setMap(null); //Hide the open info window

		//Setup the angular controller by passing over data
		var controller = angular.element('.shapeFieldTypeController').scope();
		controller.isEdit = true;
		controller.sfdcId = overlay.gpProperties.sfdcId;
		controller.recordName = overlay.gpProperties.relatedRecordName;
		controller.relatedRecordId = overlay.gpProperties.relatedRecordId;
		controller.selectedShapeField = {name: overlay.gpProperties.relatedRecordFieldName, label: overlay.gpProperties.relatedRecordFieldLabel};
		controller.shapeDescription = overlay.gpProperties.sfdcDescription;
		controller.allShapeFieldsPopulated = false;
		controller.noShapeFields = false;
		controller.color = overlay.fillColor;
		controller.opacity = overlay.fillOpacity;
		controller.overlay = overlay;

		if(overlay.gpProperties.gpType){
			controller.shapeType = overlay.gpProperties.gpType.toLowerCase();

			if(overlay.gpProperties.gpType.toLowerCase() == 'polygon'){
				overlay.setOptions({editable:true});
				controller.range = 5;//default to 5 if user switch from circle to polygon
				controller.centerLatLng = {lat: overlay.gpProperties.recordLat, lng: overlay.gpProperties.recordLng}; //Set center as record 
			
			}else if(overlay.gpProperties.gpType.toLowerCase() == 'circle'){
				controller.centerLatLng = overlay.gpProperties.centerLatLng;
				controller.range = overlay.gpProperties.range;
			}
		}
		
		if(overlay.gpProperties.units == 'Miles'){
			controller.rangeUnits = 'm';
		}else if(overlay.gpProperties.units == 'Kilometers'){
			controller.rangeUnits = 'k';
		}

		setTimeout(function(){
			controller.$apply();
		},0);

		jQuery('.mapControl').hide(); //Hide the map controls, TODO this needs to be a smart function
		jQuery('#addShapeFieldShape').show(); //Show the box explaining add shape mode

	}else{

		//If shape is used in Assignment plans show a warning.
		if(overlay.gpProperties.usedInAssignments == true){
			alert('This Shape is used in Geopointe Assignment Plans. Modifiying it may affect geographic assignment of records to this shape.');
		}

		//Make shape editable
		overlay.setOptions({editable:true});
		
		//Hide the info window
		gp_infoWindow.setMap(null);
	}
}

function gp_saveShape(uniqueId){
	//Get the shape from the polygonObjects object
	var polygon = polygonObjects[uniqueId];

	var title = gp_translations.Save_Shape;
	if(polygon.gpProperties.sfdcName){
		title += ' - ' + polygon.gpProperties.sfdcName;
	}

	var buttonText = gp_translations.Save;
	var body = gp_translations.Enter_a_Name_and_Short_Description_for_the_shape +'<br/>'+
				'<table>'+
				'<tr><td class="saveShapeLabel">'+gp_translations.Name+'</td><td><input type="text" value="'+polygon.gpProperties.sfdcName+'" id="gp_saveShapeName"/></td></tr>'+
				'<tr><td class="saveShapeLabel alignTop">'+gp_translations.Description+'</td><td><textarea maxlength="255" style="height: 50px; width: 200px;" id="gp_saveShapeDescription">'+polygon.gpProperties.sfdcDescription+'</textarea></td></tr>'+
				'</table>';

	jQuery('<div></div>')
		.append('<p>'+body+'</p>')
		.dialog({
			modal: true, 
			draggable: false, 
			width: '515px', 
			title: title, 
			position: { my: "bottom", at: "center", of: window },
			open: function() {
		      	//Create Enter event listner
		      	jQuery('#gp_saveShapeName').keypress(function(e) {
				    if (e.keyCode == 13) {
				    	//Click the first button in this modal, which is the OK button
				    	jQuery(this).parents(".ui-dialog").find("button").first().click();
				    }
				});		      	
		    },

		    buttons:[{text: buttonText, 
		    			click: function(){ 
		    		   		var name = jQuery("#gp_saveShapeName").val();	
		    		   		var description = jQuery("#gp_saveShapeDescription").val();		
		    				
		    				//Proceed if name was supplied
		    		   		if(name){

		    		   			//Close this dialog
								jQuery( this ).remove();

								geopointeAjaxStart('body',gp_translations.Saving_Shape+'...');
								
								//Build a shape object to save
								var shapeToSave = {
									sfdcId: polygon.gpProperties.sfdcId,
									name: name,
									description: description,
									type: 'Polygon',
									usageType: 'Standard',
									color: polygon.fillColor,
									opacity: polygon.fillOpacity,
									coordinates: [],
								};

								//Build a string of lng lat coordinates - code copied from shapeFieldTypeController.js
								var coords = [];

								polygon.getPath().forEach(function(e,i){
									var point = [];

									//Following geoJSON structure so store lng first.
									point.push(Number(Math.round(e.lng()+'e'+6)+'e-'+6));
									point.push(Number(Math.round(e.lat()+'e'+6)+'e-'+6));
									coords.push(point);
								});

								//Following geoJSON spec the last point needs to match the first
								coords.push([coords[0][0],coords[0][1]]);

								shapeToSave.coordinates = JSON.stringify([coords]);

								//Uncomment following line to create encoded data for testing
								//shapeToSave.coordinates = google.maps.geometry.encoding.encodePath(polygon.getPath());

								// Save the shape
								Visualforce.remoting.Manager.invokeAction(gp_remotes.saveShape,JSON.stringify(shapeToSave),function(result, event){
									if (event.status) { //Success
										
										//Update the object stored in polygonObjects
										polygon.gpProperties.sfdcName = name;
										polygon.gpProperties.sfdcDescription = description;
										polygon.gpProperties.sfdcId = result.sfdcId;

				                    	//Update the html for the shape bubble
				                    	buildShapeInfoWindowHTML(polygon);

										//Turn off edit mode
										polygon.setOptions({editable:false});

										//Update info window content
										gp_infoWindow.setContent(polygon.gpProperties.htmlContent);

										//Update the picklist of saved shapes, first check to see if there is already a picklist value for this shape
										gp_rerenderShapeListAdd(result.sfdcId); //actionFunction on map.page

										//Update the list of saved shapes
										angular.element('.layersController').scope().getSavedShapes();

									} else {
										//Error handling
										var message = {
											severity: 'ERROR',
											message: 'Uh oh. Something didn\'t work quite right. If this error continues please contact Arrowpointe support. '+ event.message
										};
										updatePageMessages([message]);
										gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'saveShape', 'Message':event.message});

										geopointeAjaxEnd();
									}
								},
									{escape: true}
								);
							}	
		    			} 
		    		},
		    		{text: gp_translations.Cancel, 
		    			click: function(){ 
		    		   		jQuery( this ).remove(); 
		    			} 
		    		}] 
	});
}

function gp_addShapeToMap(){
	
	//Get the Id of the currently selected shape
	var sfdcShapeId = jQuery("#shapeList").val();

	if(sfdcShapeId && sfdcShapeId != '--'+gp_translations.None+'--'){

		//Check to see if shape is already on the map
		for(key in polygonObjects){
			if(sfdcShapeId == polygonObjects[key].gpProperties.sfdcId){
				geopointeAjaxEnd();
				
				var overlay = polygonObjects[key];

				var title = 'Duplicate Shape';
				var body = '<b>'+ overlay.gpProperties.sfdcName +'</b> '+gp_translations.has_already_been_added_to_the_map+'<br/><br/>'+
							gp_translations.You_can_view_this_shape_by_selecting;

				jQuery('<div></div>')
					.append('<p>'+body+'</p>')
					.dialog({
						modal: true, 
						draggable: false, 
						width: '515px', 
						title: title, 
						position: { my: "bottom", at: "center", of: window },
						open: function() {
					      	//Create Enter event listner
					      	jQuery('#gp_saveShapeName').keypress(function(e) {
							    if (e.keyCode == 13) {
							    	//Click the first button in this modal, which is the OK button
							    	jQuery(this).parents(".ui-dialog").find("button").first().click();
							    }
							});		      	
					    },

					    buttons:[{text: gp_translations.Go_to_Shape, 
					    			click: function(){ 
					    		   		gp_bounds = new google.maps.LatLngBounds();

					    		   		var paths = overlay.getPaths();

										for (var p = 0; p < paths.getLength(); p++) {
											var path = paths.getAt(p);
											for (var i = 0; i < path.getLength(); i++) {
												gp_bounds.extend(path.getAt(i));
											}
										}

										//Readjust the map
										gp_centerZoom();

										//Close this dialog modal
										jQuery( this ).remove(); 

										//Exit drawing mode
										gp_exitDrawMode();
					    			} 
					    		},
					    		{text: gp_translations.Cancel, 
					    			click: function(){ 
					    		   		jQuery( this ).remove(); 
					    			} 
					    		}] 
				});
				//Do not proceed with add shape to map
				return false;
			}
		}
		
		geopointeAjaxStart('#searchControl',gp_translations.Adding_Shape+'...');

		//Get the shape coordinates
		Visualforce.remoting.Manager.invokeAction(getShapeLatLngRemoteMethodName,sfdcShapeId,function(result, event){
			if (event.status) {

				//Make sure color starts with #
				if(result.color.indexOf('#') != 0){
					result.color = '#' + result.color;
				}
				
				//Special handing for Geo Shapes
				if(result.usageType == 'GeoShape'){
					
					//Set user the Angular geoShapeService to add shapes to the map
					var geoShapeControllerElement = angular.element('.geoShapeController');
					var injector = geoShapeControllerElement.injector();
					var geoShapeService = injector.get('geoShapeService');

					//Build a list of Geo Shape URLs that should be used to add shapes to the map
					var geoShapeIds = JSON.parse(result.coordinates);
					var tempGetURL = '?id=';
					var queryURLs = [];
					var count = 0;
					
					for(var i = 0; i < geoShapeIds.length; i++){
						tempGetURL += geoShapeIds[i] + ',';
						count++;

						if(count == 20){
							//remove the last comma
							tempGetURL = tempGetURL.substring(0, tempGetURL.length - 1);

							//Add the fields to query
							tempGetURL += '&fields=id,name,geometry,type&featureCollection=1';

							queryURLs.push(tempGetURL);

							//Reset temp url
							tempGetURL = '?id=';
							count = 0;
						}
					}

					//Finish the last url
					if(tempGetURL != '?id='){
						tempGetURL = tempGetURL.substring(0, tempGetURL.length - 1); //remove the last comma
						tempGetURL += '&fields=id,name,geometry,type&featureCollection=1'; //Add the fields to query
						queryURLs.push(tempGetURL);
					}

					geoShapeService.GETgeoShapes({
						addToMap: true,
						color: result.color,
						opacity: result.opacity,
						layerName: result.name,
						sfdcId: result.sfdcId,
						usedInAssignments: result.usedInAssignments,
						queryURLs: queryURLs,
						onComplete: function(result){
							
							//Zoom and fit map to shape
							gp_bounds = new google.maps.LatLngBounds();

							for(key in polygonObjects){
								var overlay = polygonObjects[key];

								if(overlay.gpProperties.groupLayerId == result.groupLayerId){

									var paths = overlay.getPaths();

									for (var p = 0; p < paths.getLength(); p++) {
										var path = paths.getAt(p);
										for (var i = 0; i < path.getLength(); i++) {
											gp_bounds.extend(path.getAt(i));
										}
									}
								}
							}

							//Readjust the map
							gp_centerZoom();

							//geoShapeControllerElement.scope().$apply();

							//Notify shape layer controller that layers on map changed
							angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
						}
					});
				
				}else{ //Standard Shape
					var latLngs = [];
					if (result.coordinates && result.coordinates.indexOf('[[[') == 0){ //Stored in GeoJSON format
						var lngLatArray = JSON.parse(result.coordinates)[0]; //Don't support holes so first array of lng lats is the shape

						for(var j = 0; j < lngLatArray.length; j++){
							latLngs.push(new google.maps.LatLng(lngLatArray[j][1],lngLatArray[j][0]));
						}
					} else {
						//Decode the lat lng string stored in sfdc, multiple lat lng fields are combined into Lat_Lng_1__c
						latLngs = google.maps.geometry.encoding.decodePath(result.coordinates);
					}
					//Create a new polygon overlay
					var shape = new google.maps.Polygon({
						paths: latLngs,
						fillColor: result.color,
						fillOpacity: result.opacity,
						strokeWeight: 1.5,
						clickable: true,
						zIndex: 1,
						editable: false,
						draggable: false
					});

					//Set the saved properties on the overlay shape object
					shape.gpProperties = {};
					shape.gpProperties.sfdcId = result.sfdcId;
					shape.gpProperties.sfdcName = result.name;
					shape.gpProperties.sfdcDescription = result.description;
					shape.gpProperties.usedInAssignments = result.usedInAssignments;

					//Add the shape to map
					shape.setMap(gp_map);

					//Call polygon added to map method, make sure it is added to polygon Objects array
					gp_shapeAddedToMap(shape,'polygon');

					//Track in mixpanel that a geo shape was added to the map
					gp_track('Shape Added',{"Type": "Standard", "Number of Sub Shapes": 1});

					//Make sure bounds of map include the shape
					for (var i = 0; i < latLngs.length; i++) {
						gp_bounds.extend(latLngs[i]);
					}

					//Readjust the map
					gp_centerZoom();

					//Remove the ajax status modal
					geopointeAjaxEnd();	
				}

			} else {
				//Error handling
				var message = {
					severity: 'ERROR',
					message: 'Uh oh. Something didn\'t work quite right. If this error continues please contact Arrowpointe support. '+ event.message
				};
				updatePageMessages([message]);
				gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'gp_addShapeToMap', 'Message':event.message});

				geopointeAjaxEnd();
			}
		},
			{escape: false}
		);
	}
}

function gp_deleteShapeConfirm(uniqueId){
	//Get the current data set
	var polygon = polygonObjects[uniqueId];

	//Set the dialog title and body
	var title = gp_translations.Delete_Shape + ' - ' + polygon.gpProperties.sfdcName;
	
	var body = '<div class="gp-modal-content">';

	if(polygon.gpProperties.usageType == 'Shape Field'){
		body+= gp_translations.This_will_DELETE_the_selected_shape_and_clear_the_Shape_field_on_the_record + ':<br/><br/>';
		body+= '<b>'+gp_translations.Record_Name + '</b>: ' + polygon.gpProperties.relatedRecordName + '<br/>';
		body+= '<b>'+gp_translations.Shape_Field + '</b>: ' + polygon.gpProperties.relatedRecordFieldLabel;
	}else{
		body+= gp_translations.This_will_DELETE_the_selected_Shape_and_remove_it_from_your_list;
	}

	body += '</div>'+
			'<div class="gp-modal-footer">'+
                '<input class="gp-btn btn-lg modalButtonRight" onclick="jQuery(this).closest(\'.ui-dialog-content\').dialog(\'close\');" type="button" value="'+gp_translations.Close+'">'+
                '<input class="gp-btn btn-lg btn-danger modalButtonRight" onclick="jQuery(this).closest(\'.ui-dialog-content\').dialog(\'close\'); gp_deleteShape(\''+polygon.gpProperties.uniqueId+'\')" type="button" value="'+gp_translations.Delete+'">'+
                '<div class="clear"></div>'+
            '</div>';

	jQuery('<div></div>')
		.append(body)
		.dialog({
			modal: true, 
			draggable: false, 
			width: '515px', 
			title: title, 
			position: { my: "bottom", at: "center", of: window },
			dialogClass: 'gp-modal warn',
			resizable: false,
			open: function( event, ui ) {
				//Set height of modal content
				setGPmodalContentHeight(jQuery(this));
			}
		});
}

function gp_deleteShape(shapeId){
	geopointeAjaxStart('body',gp_translations.Deleting_Shape+'...');

	//Find the shape to delete
	var shape;
	for(key in polygonObjects){
		if(polygonObjects[key].gpProperties.uniqueId == shapeId){
			shape = polygonObjects[key];
			break;
		}
	}

	//Remoting save methods for dataSet
	Visualforce.remoting.Manager.invokeAction(deleteShapeRemoteMethodName,shape.gpProperties.sfdcId,function(result, event){
		if (event.status) {
			
			//Remove this data set from the shape picklist by rerendering it
			if(shape.gpProperties.usageType == 'Shape Field'){
				geopointeAjaxEnd();
			}else{
				gp_rerenderShapeListRemove(); //actionFunction on map.page
			}
			
			//Remove the data set from polygon objects and map
			gp_removeShape(shapeId);

			//Close the geo shape edit modal as it may have  if it was open
			jQuery( "#geoShapeModal" ).dialog('close');

			//Update the list of saved shapes
			angular.element('.layersController').scope().getSavedShapes();

			//Show success message
			jQuery.extend(toastr.options,{ timeOut: 5000 });
			toastr.success('Shape deleted.');

		} else {
			//Show error message
			jQuery.extend(toastr.options,{ timeOut: 60000 });
			toastr.error('Uh oh. Something didn\'t work quite right. '+ event.message);
		
			//Track the error
			gp_track('Error', {'Language': 'JavaScript', 'Type':'Remoting', 'Function':'dataShape', 'Message':event.message});
		}

		geopointeAjaxEnd();
	},
		{escape: true}
	);
}

function gp_removeCenterPOIshapes(){
	for(key in polygonObjects){
		//Remove shapes associated with center pin marker
		if(polygonObjects[key].usageType == 'Shape Field' && gp_centerPOI.recordId && gp_centerPOI.recordId == polygonObjects[key].relatedRecordId){
			polygonObjects[key].setMap(null);
			delete polygonObjects[key];
		}
	}
}

function gp_removeShape(uniqueId){
	//Remove from map
	var overlay = polygonObjects[uniqueId];
	var groupLayerIdToRemove = uniqueId;
	if(overlay) groupLayerIdToRemove = overlay.gpProperties.groupLayerId;

	for(key in polygonObjects){
		if(polygonObjects[key].gpProperties.groupLayerId == groupLayerIdToRemove){
			polygonObjects[key].setMap(null);
			delete polygonObjects[key];
		}
	}

	//Close the info window
	gp_infoWindow.close();

	//Update the layers list with new record counts
	setTimeout(function(){
		angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
	},0);
}

//IE this will remove one zip code from a shape comprised of many zip codes
function gp_removeSubShape(uniqueId){
	var overlay = polygonObjects[uniqueId];
	overlay.setMap(null);
	delete polygonObjects[uniqueId];

	//Close the info window
	gp_infoWindow.close();

	//Update the layers list with new record counts
	setTimeout(function(){
		angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
	},0);
}

function gp_removeAllShapesFromMap(){
	jQuery('<div></div>')
		.append('<p>'+gp_translations.This_will_remove_all_shapes_from_the_map+'<br/><br/>'+gp_translations.Select_Remove_to_continue+'</p>')
		.dialog({
			modal: true, 
			draggable: false, 
			width: '270px', 
			title: gp_translations.Remove_All_Shapes, 
			position: { my: "bottom", at: "center", of: window },
			
		    buttons:[{text: "Remove", 
		    			click: function(){ 
		    				//Remove shapes from the map
							for(key in polygonObjects){
								var shape = polygonObjects[key];

								//Dont remove shape field shapes
								if(shape.gpProperties.usageType != 'Shape Field'){
									shape.setMap(null);
									delete polygonObjects[key];
								}
							}

							//Remove geojson files
							gp_map.data.forEach(function(shape){
								gp_map.data.remove(shape);
							});

							//Close info window that may be open
							gp_infoWindow.close();	

							//Close this dialog
							jQuery( this ).remove(); 

							//Update angular ui elements
							angular.element('.dataSetController').scope().$apply();
		    			} 
		    		},
		    		{text: "Cancel", 
		    			click: function(){ 
		    		   		jQuery( this ).remove(); 
		    			} 
		    		}] 
		});
}

function gp_goToShapeField(sfdcRecordId,shapeRecordId){
	//Loop through all the polygon objects
	for(key in polygonObjects){
		var shape = polygonObjects[key];
		if(shape.gpProperties.relatedRecordId == sfdcRecordId && shape.gpProperties.sfdcId == shapeRecordId){
			gp_goToShape(key);
		}
	}
}

function gp_goToShape(sfdcIdUniqueId){
	for(key in polygonObjects){
		var shape = polygonObjects[key];
		if(shape.gpProperties.sfdcId == sfdcIdUniqueId || shape.gpProperties.uniqueId == sfdcIdUniqueId){
			var bounds = shape.getBounds();
			gp_map.fitBounds(bounds);
		}
	}
}

function checkIfPoiInShapes(poi,groupLayerId){ //groupLayerId is optional
	
	//Construct a google lat lng object from the poi
	var latLng = new google.maps.LatLng(poi.lat,poi.lng);

	for(key in polygonObjects){	

		var overlay = polygonObjects[key];

		if(typeof groupLayerId == 'undefined' || ( typeof groupLayerId != 'undefined' && groupLayerId == overlay.gpProperties.groupLayerId ) ){

			var isWithinPolygon = false;

			if(overlay.gpProperties.gpType == 'circle'){ // Is a circle

				var circleRadiusKM = overlay.radius / 1000; 
	            var distanceFromCenterKM = getGeoDistance(overlay.gpProperties.centerLatLng.lat, overlay.gpProperties.centerLatLng.lng, poi.lat, poi.lng, 'kilometers');

	            if(distanceFromCenterKM <= circleRadiusKM){
	            	return true;
	            }

			}else{ //Not a circle
				isWithinPolygon = google.maps.geometry.poly.containsLocation(latLng,overlay);
			}

			if(isWithinPolygon == true){
				return true;
			}

		}
	}

	//Poi is not inside a shape
	return false;
}

var recordsInShapesTimeoutHandler;

function calcRecordsInShapes(){
	window.clearTimeout(recordsInShapesTimeoutHandler);

	if(gp_shapeDragInProgress == false){
		recordsInShapesTimeoutHandler = window.setTimeout(function(){
			doCalcRecordsInShapes();
		},250);
	}
}

//Never ever call this method directly. Always call calcRecordsInShapes();
function doCalcRecordsInShapes(){
	try{

		//Get the tables to process
		var tables = [];

		//Loop through all of the tabs and check to see it it has been removed from the map
		jQuery(".dataSetResultTableTab").each(function(){
			var collectionName = jQuery(this).attr('data-collectionName');

			//If tab is not hidden from the map add the table to list of those that should be returned
			if(jQuery(this).find(".poiCollectionTabLabel").hasClass('tabDataHidden') == false){
				tables.push(jQuery("#" + collectionName));
			}
		});

		//Reset shape recordCount values
		for(key in polygonObjects){
			polygonObjects[key].gpProperties.recordCounts = {};
			polygonObjects[key].gpProperties.recordIdsInShape = [];
			polygonObjects[key].gpProperties.aggregations = {};
		}

		// Reset recordCount values for DataSet layers
		for(key in gp_dataSetSearches) {
			if(!gp_dataSetSearches[key].name)
				continue;

			gp_dataSetSearches[key].aggregations = {};
		}

		// Loop thru all tables and populate recordIds array and recordIdToObjectName object
		for(var i = 0; i < tables.length; i++){

			//Determin the object name for this search/collection/datatable
			var collectionName = jQuery(tables[i]).attr('id');
			var objectName = gp_dataSetSearches[collectionName].objectName;
			
			//Use the column info object attached to the data table as each table could have different number of columns
			var gp_ColumnInfo = jQuery(tables[i]).data('columnInfo');
			var apiNameToColNumber = jQuery(tables[i]).data('apiNameToColNumber');
			var additionalHiddenFieldColNumbers = jQuery(tables[i]).data('additionalHiddenFieldColNumbers');

			var oSettings = jQuery(tables[i]).dataTable().fnSettings();
			var columns = oSettings.aoColumns;

			// Get the Table Data
			var table = jQuery(tables[i]).dataTable();
			var aoData = table.fnGetData();
			

			var aggregates = {};

			// Loop through fields to determine currency fields for this object
			for(apiName in apiNameToColNumber){
				var columnNumber = apiNameToColNumber[apiName]
				var columnDetail = columns[columnNumber];
				
				//Only aggregate currency fields
				if(columnDetail.gpFieldType == 'CURRENCY')
					aggregates[columnDetail.gpAPIname] = {
						 aggkey: objectName + columnDetail.gpAPIname
						,columnNumber: columnNumber
						,label: columnDetail.sTitle
						,precision: columnDetail.gpPrecision
					};
			}

			// Loop through the rows and populate list of recordIds, and object that store recordId to objectname
			for (var j=0; j < oSettings.aiDisplay.length; j++){
				var thisRow = aoData[j];
				var recordId = thisRow[gp_ColumnInfo.recordId];
				var lat = thisRow[gp_ColumnInfo.latitude];
				var lng = thisRow[gp_ColumnInfo.longitude];

				var latLng = new google.maps.LatLng(lat,lng); 

				//Loop through all the polygon objects and check to see if this record is inside the shape
				for(key in polygonObjects){	
					var shape = polygonObjects[key];

					//Only proceed with complex point in poly check if point is within the bounds of the overlay
					if(typeof shape.gpProperties.bounds == 'undefined' || !shape.gpProperties.bounds.contains(latLng)) 
						continue;
			 
			        //Perform complex point in poly check		
					if(!google.maps.geometry.poly.containsLocation(latLng,shape))
						continue;

					//Increment record counts
					shape.gpProperties.recordIdsInShape.push(recordId);

					if(!shape.gpProperties.recordCounts[objectName]){
						shape.gpProperties.recordCounts[objectName] = 0;
					}
					shape.gpProperties.recordCounts[objectName]++;

					// Loop through currency fields
					for (key in aggregates) {
						var agg = aggregates[key];
						var value = agg.columnNumber ? thisRow[agg.columnNumber] : null;

						if(typeof value != 'number') continue;

						if(typeof shape.gpProperties.aggregations[agg.aggkey] == 'undefined'){
							shape.gpProperties.aggregations[agg.aggkey] = {label: agg.label, amount: 0, precision: agg.precision};
						}

						shape.gpProperties.aggregations[agg.aggkey].amount += value;
					}

				} // End loop through polygon shapes

				// Add field into to DataSet aggregations
				for (key in aggregates) {
					if (!aggregates.hasOwnProperty(key)) continue;

					var agg = aggregates[key];
					var value = thisRow[agg.columnNumber];

					if(typeof value != 'number') 
						continue;

					if (typeof gp_dataSetSearches[collectionName].aggregations[agg.aggkey] == 'undefined'){
						gp_dataSetSearches[collectionName].aggregations[agg.aggkey] = {label: agg.label, amount: 0, precision: agg.precision};
					}

					gp_dataSetSearches[collectionName].aggregations[agg.aggkey].amount += value;
				}

			} // End loop through rows
		}

		//Update the shape html for each shape
		for(key in polygonObjects){
			var shape = polygonObjects[key];

			buildShapeInfoWindowHTML(shape);

			//If the info window is currently open for this shape update the content
			if(gp_infoWindow.content && gp_infoWindow.content.indexOf(shape.gpProperties.uniqueId) > -1){
				jQuery("#shapeRecordCountWrapper").html(getShapeBubbleRecordCountHtml(shape));
			}
		}

		//Update the layers list with new record counts
		angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 

	}catch(err){
		console.log(err);
		gp_track('Error', {'Language': 'JavaScript','Type':'Shape Record Count','Message': err.message});
	}
}

//Record action that launches process to create a new shape associated with a record, ie Polygon Field type
function gp_addShapeFieldShape(recordId,poiId,name,lat,lng){

	gp_mapMode = 'addShape';
	gp_enterDrawMode(); //Enter draw mode, duh
	gp_infoWindow.setMap(null); //Hide the open info window

	//Setup the angular controller by passing over data
	var controller = angular.element('.shapeFieldTypeController').scope();
	controller.recordName = name;
	controller.centerLatLng = {lat: lat, lng: lng};
	controller.relatedRecordId = recordId;
	controller.getShapeFields();
	controller.isEdit = false;
	controller.poiId = poiId;
	controller.$apply();

	jQuery('.mapControl').hide(); //Hide the map controls, TODO this needs to be a smart function
	jQuery('#addShapeFieldShape').show(); //Show the box explaining add shape mode
	geopointeAjaxStart('#addShapeFieldShape',gp_translations.Loading+'...');
}

function gp_exitAddShapeMode(){
	gp_mapMode = 'search';
	gp_exitDrawMode(); //Exit draw mode
	jQuery('.mapControl').show(); //Show the map controls, TODO this needs to be a smart function
	jQuery('#addShapeFieldShape').hide(); //Hide the box explaining add shape mode
	resetMapControlOffset('.mapControl'); //Make sure map control tabs are aligned properly
	
	for(key in polygonObjects){
		var shape = polygonObjects[key];
		
		//Turn off edit mode for the shape
		shape.setOptions({editable: false});

		//Remove any pending shape that was drawn on the map
		if(shape.usageType == 'Shape Field' && !shape.sfdcId){
			shape.setMap(null);
			delete polygonObjects[key];
		}
	}

}

//Extend the google Polygon object with getBounds - https://github.com/tparkin/Google-Maps-Point-in-Polygon
if (!google.maps.Polygon.prototype.getBounds) {
  google.maps.Polygon.prototype.getBounds = function(latLng) {
    var bounds = new google.maps.LatLngBounds();
    var paths = this.getPaths();
    var path;
    
    for (var p = 0; p < paths.getLength(); p++) {
      path = paths.getAt(p);
      for (var i = 0; i < path.getLength(); i++) {
        bounds.extend(path.getAt(i));
      }
    }

    return bounds;
  }
}

/* Layer methods */
function gp_initLayerObject(layers){
	gp_layers = {};
	for(var i = 0; i < layers.length; i++){
		gp_layers[ layers[i][nameSpacePrefix + 'URL__c'] ] = layers[i];
	}
}

function gp_autoLoadLayers(){
	for(key in gp_layers){
		var layer = gp_layers[key];
		if(layer[nameSpacePrefix + 'Auto_Load__c'] == true){
			gp_addKMLlayer({'url': layer[nameSpacePrefix + 'URL__c'], 'showStatus': false, 'isAutoLoad':true});
		}
	}
}

function gp_showKMLlayer(url){
	gp_layers[url].kmlLayer.setMap(gp_map);
}

function gp_hideKMLlayer(url){
	gp_layers[url].kmlLayer.setMap(null);
}

function gp_removeKMLlayer(url){
	gp_layers[url].kmlLayer.setMap(null);
	delete gp_layers[url].kmlLayer;
}

function gp_addKMLlayer(opts){ //recieves opts object with arguments {url: string, this: jQuery(this)}	
	console.log('adding layer')

	//Create a new layer object
	var layer = new google.maps.KmlLayer({
		url: opts.url,
		preserveViewport: true,
		map: gp_map
	});

	//Use exising kml layer if it is already attached to the gp_layers object
	if(gp_layers[opts.url].kmlLayer){
		layer = gp_layers[opts.url].kmlLayer;
	}

	//Event listener to track if the kml layer was added to map successfully
	google.maps.event.addListener(layer, 'status_changed', function(kmlEvent) {
		if(layer.getStatus() == 'OK'){
				
			//On success update text and show the little green dot indicating layer is visible on map
			if(opts.url){

				//Update list of layers on the map
				angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
				
				//Hide Ajax status spinner
				geopointeAjaxEnd();
			}
		}else{
			//Remove Ajax status icon
			geopointeAjaxEnd();

			//'Remove' layer from the map as it was never added successfully
			layer.setMap(null);
			delete gp_layers[opts.url].kmlLayer;

			var layerMessage;
			var status = layer.getStatus();

			if(status == 'DOCUMENT_NOT_FOUND'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.Unable_to_locate_the_file;

			}else if(status == 'DOCUMENT_TOO_LARGE'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.The_file_is_too_large;

			}else if(status == 'FETCH_ERROR'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.Unable_to_fetch_the_file;

			}else if(status == 'INVALID_DOCUMENT'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.The_document_is_not_a_well_formed;

			}else if(status == 'INVALID_REQUEST'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.The_KmlLayer_is_invalid;
				
			}else if(status == 'LIMITS_EXCEEDED'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.The_document_exceeds_the_limit_of_supported_features;

			}else if (status == 'TIMED_OUT'){
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.Connection_timeout;

			}else{
				layerMessage = gp_translations.The_layer_could_not_be_added_to_the_map + '<br/><br/>'+gp_translations.Please_contact_Arrowpointe_Support_if_you_continue_to_see_this_error;
			}

			jQuery('<div style="margin-top: 4px;"></div>')
			.append('<div class="gp-alert gp-alert-error">'+layerMessage+'<div>')
			.dialog({
				modal: true, 
				draggable: true, 
				width: 350,
				title: gp_translations.Layers_Error, 
				draggable: false,
				resizable: false,
				buttons: { 
					Close: function() {jQuery( this ).remove();} 
				}
			});
		}
	});

	//Add layer to map
	layer.setMap(gp_map);

	//update kml object
	gp_layers[opts.url].kmlLayer = layer;

	//Log layer being added in mixpanel
	if(typeof opts.isAutoLoad == 'undefined') opts.isAutoLoad = false;

	gp_track('Layer', {	"Layer Type": 'KML', 
						"Layer Status": 'On',
						"Is Auto Load": opts.isAutoLoad
						});
}
/* End Layer Methods */

/*Start Heatmap Methods */
function toggleHeatMap(btn,collectionName){

	//Check to see if heatmap is all ready visible on the map
	if(gp_heatmaps[collectionName]){
		if(gp_heatmaps[collectionName].getMap()){
			//Remove from map
			gp_heatmaps[collectionName].setMap(null);
			delete gp_heatmaps[collectionName];

			//Hide the heat map slider controls
			jQuery("#heatMapSlider-"+collectionName).hide();
			jQuery(btn).removeClass('btnSelected');

			//Add markers back to map
			if(gp_dataSetSearches[collectionName]){
				gp_dataSetSearches[collectionName].markersVisible = true;
			}
			gp_restoreDataSetSearchOnMap(collectionName);

			//Unselect the button to toggle map markers
			jQuery("#heatMapSlider-"+collectionName+" .toggleMarkersBtn").removeClass('btnSelected');

		}

	}else{ //Need to add to map

		var columnInfo = jQuery("#" + collectionName).data('columnInfo'); //Object that maps column name to column #
		var oSettings = jQuery("#" + collectionName).dataTable().fnSettings();
		var aoColumns = oSettings.aoColumns;
		var aoData = oSettings.aoData;

		//Create array of google.maps.LatLng objects
		var latLngs = [];

		for (var i = 0; i < aoData.length; i++ ){
			var colData = aoData[i]._aData;
			latLngs.push(new google.maps.LatLng(colData[columnInfo.latitudeDisplay],colData[columnInfo.longitudeDisplay]));
		}

		//Create a lat/lng point array for the heatmap
		var heatMapPointArray = new google.maps.MVCArray(latLngs);

		heatmap = new google.maps.visualization.HeatmapLayer({
			data: heatMapPointArray,
			opacity: 0.5,
			radius: jQuery("#heatmapSlider-"+collectionName).slider("value"),
			maxIntensity: 2,
			gradient: [
				'rgba(0, 0, 255, 0)',
			    'rgba(0, 0, 255, 1)',
			    'rgba(0, 255, 255, 1)',
			    'rgba(0, 255, 0, 1)',
			    'rgba(255, 255, 0, 1)',
			    'rgba(255, 0, 0, 1)'
			]
		});

		heatmap.setMap(gp_map);

		//Remove the marker pins on the map
		gp_removeDataSetSearchFromMap(collectionName);

		//Update the gp_dataSetSearches object with state of marker visibility
		if(gp_dataSetSearches[collectionName]){
			gp_dataSetSearches[collectionName].markersVisible = false;
		}

		//Add to heatmap object
		gp_heatmaps[collectionName] = heatmap;

		//Show the heat map slider controls
		jQuery("#heatMapSlider-"+collectionName).show();
		jQuery(btn).addClass('btnSelected');

		//Track in mixpanel
		if(gp_dataSetSearches[collectionName]){
			gp_track('Heatmap Added', {'Number of Markers': gp_dataSetSearches[collectionName].numOfRecords, 
										'Zoom Level': gp_getZoomLevel()
			});
		}
	}
}

function toggleMapMarkers(btn,collectionName){
	//Only proceed if gp_dataSetSearches object contains meta data for this search, it always should
	if(gp_dataSetSearches[collectionName]){
		if(gp_dataSetSearches[collectionName].markersVisible != false){
			gp_removeDataSetSearchFromMap(collectionName);

			//Update the gp_dataSetSearches object with state of marker visibility
			if(gp_dataSetSearches[collectionName]){
				gp_dataSetSearches[collectionName].markersVisible = false;
			}

			jQuery(btn).removeClass('btnSelected');
		}else{
			//Update the gp_dataSetSearches object with state of marker visibility
			if(gp_dataSetSearches[collectionName]){
				gp_dataSetSearches[collectionName].markersVisible = true;
			}
			
			gp_restoreDataSetSearchOnMap(collectionName); //Add markers to map
			jQuery(btn).addClass('btnSelected'); //Change style of marks toggle button as selected
		}
	}
}
/* End Heatmap Methods */

function gp_convertGeoJSONFeatureToLayer(feature){
	
	//Use data object to extract the lat lng
	var data = new google.maps.Data();
	data.addGeoJson(feature);

	//Create a overlay object
	var overlay = new google.maps.Polygon();
	var paths = [];

	if(feature.geometry.type.toLowerCase() == 'polygon'){

		//There will only be record in this forEach
		data.forEach(function(dataFeature){
			
			//For this feature and an array or lat/lng array. 
			var linearRing = dataFeature.getGeometry().getArray(); 

			//Loop through the linear array and update path
			for(var i = 0; i < linearRing.length; i++){
				paths.push(linearRing[i].getArray());
			}
		});

	}else if(feature.geometry.type.toLowerCase() == 'multipolygon'){

		//There will only be one Feature in this forEach
		data.forEach(function(dataFeature){
			
			var polygons = dataFeature.getGeometry().getArray();;
			
			for(var j = 0; j < polygons.length; j++){
				var linearRing = polygons[j].getArray(); 

				//Loop through the linear array and update path
				for(var i = 0; i < linearRing.length; i++){
					paths.push(linearRing[i].getArray());
				}
			}
		});
	}

	overlay.setPaths(paths);
	return overlay;
}