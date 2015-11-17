/*************************
* Global  Vars
*************************/
var 
	gp_stopSubmit = false // boolean to stop the form submit in certain cases
	,gp_dataSetInfo = {}
	,gp_objectMeta = new Object() // global holding configuration information for each map object
	,gp_tooltips = new Object() // global holding the content of the tooltips
	,gp_userSettings // global holding the user settings record + some additional user specific info
	,gp_orgSettings // global holding the org settings record + some additional org specific info
	,gp_remotes // global holding access to the Remoting methods accessed in static resources
	,gp_lastMapObject // a string with the most recent Map Object selected based upon the data set selected
	,gp_lastDataSet //keeps track of previously selected data set
	,gp_activeMapMode = 'SEARCH' // global holding the map mode of the page
	,gp_centerPOICollectionName = 'centerPOI' // a constant, keep it in sync with the value in controller, mq
	,gp_searchPOICollectionName = 'searchPOI' // collecton name for address search marker mq
	,gp_centerPOI = {} // Object containing information about the centerPOI since we are not holding it in a Data Table, goog
	,gp_searchPOI // Object containing information about the searchPOI since we are not holding it in a Data Table, goog
	,gp_MQApiKey // The applicable MapQuest API Key. Used for Geocoding and other client-side purposes
	,gp_baseURL // The Base Salesforce URL for the org
	,gp_searchAddress //Updated with parsed geocode response everytime a address search is performed
	,gp_radialAddress //Updated with parsed geocode response everytime a radial search is performed
	,gp_centerPointKeepAddress //Boolean that keeps track if the center point address should be saved and used instead of reverse geocoding on radial searches
	,gp_dataSetSearches = {} //Keeps track of basic info about each data set search that is performed, stays in sync with data searches/list, reset with each search when clear existing = true
;

// Visualforce UI Elements on Map page that get put into JavaScript variables since their ID is unpredictable
var gp_UIElem = {
	"clearExisting": null, // clear existing flag
	"selectedcolor": null, // override marker color
	"dataSetSelectList": null, // drop-down box for the data set select. code at Penske uses this
	"hidden_routeLocXML": null, // hidden form data
	"hidden_htmlDirections": null, // hidden form data
	"hidden_colorMarkersBy": null, // hidden form data
	"hidden_customSOQL": null, // hidden form data // used at Penske
	
	"googViz_DataSet": null, // Data Set
	"googViz_Region": null, // Region
	"googViz_SumBy": null, // Summarize By
	"googViz_showData": null, // Show data table
	
	"analytics_DataSetList": null, // list of DS to load to SK
	"analytics_OrgWide": null
}

//Column Definitions for the Data Tables
var gp_ColumnInfo = {
	"uniqueId": 0,
	"recordId": 1,
	"mapIconURLDataTable": 2,
	"mapIconURL": 3,
	"mapIconColor": 4,
	"mapIconSize": 5,
	"latitude": 6,
	"longitude": 7,
	"latitudeDisplay": 8,
	"longitudeDisplay": 9,
	"usesCustomerGeocode": 10,
	"actions": 11,
	"rowNum": 12,
	"title": 13,
	"title2": 14,
	"fulladdress": 15,
	"street": 16,
	"city": 17,
	"state": 18,
	"postalCode": 19,
	"country": 20,
	"countryISO": 21,
	"col1Type": 22,
	"col1Value": 23,
	"col2Type": 24,
	"col2Value": 25,
	"col3Type": 26,
	"col3Value": 27,
	"col4Type": 28,
	"col4Value": 29,
	"col5Type": 30,
	"col5Value": 31,
	"distance": 32,
	"distanceDrive": 33,
	"geocodeQuality": 34,
	"infoContent": 35
}

//Little script that should prevent console errors in IE
if (!window.console || typeof console == "undefined"){ 
	console = {log: function() {},time: function(){},timeEnd: function(){}};
}

// Run the jQuery noConflict code
jQuery.noConflict();

/*************************
* jQuery Data Tables functions
*************************/
function __JQUERY_DATA_TABLE_FUNCTIONS__(){}

// Destroy all jQuery Data Tables in the DIV passed in
function gp_destroyDataTables(div){
	//Wipe out the dataset result tabs and content
	jQuery(".dataSetResultTableTab,.dataSetResultTableTabContent").remove();
	jQuery('#gp_dataTablesNoData').show();
}

// Create a new tab that will contain the data table
function gp_newDataTableStructure(div, poiCollection){
	jQuery("#gp_dataTables").show();

	//Set the left and right padding for the tabs, varies due to translations
	var $tabsList = jQuery("#gp_dataTableTabs ul:first");
	$tabsList.css({'padding-left': jQuery("#mappedDataTitle").width() + 17, 'padding-right': jQuery("#mappedDataButtons").width() + 13});

	//Create label for tab and add to page, first determine count bubble color
	var countColor = poiCollection.mapIconColor;
	var colorOverride = jQuery("input[id$='gp_selectedcolor']").val();
	if(colorOverride){
		countColor = colorOverride;
	}

	var tabLabel = '<li class="dataSetResultTableTab" data-collectionName="'+poiCollection.collectionName+'">'+
						'<a href="#tabs-'+poiCollection.collectionName+'">'+
							'<span class="poiCollectionTabLabel" data-collectionName="'+poiCollection.collectionName+'" notranslate>'+poiCollection.dataSetName+'</span>&nbsp;&nbsp;'+
							'<span id="countBubble-'+poiCollection.collectionName+'" class="countBubble countBubbleTab" style="background-color:#'+countColor+';">' + poiCollection.POIs.length + '</span>'+
							'<img class="tabShowHideIcon tabHideIcon removeDataSetSearchIcon" src="'+blackXiconURL+'" data-collectionName="'+ poiCollection.collectionName +'" title="Remove Data Set Search from map"/>'+
							'<img class="tabShowHideIcon tabShowIcon showDataSetSearchIcon" src="'+blackPlusIconURL+'" data-collectionName="'+ poiCollection.collectionName +'" title="Show Data Set Search on map"/>'+
						'</a>'+
					'</li>';
	jQuery("#gp_dataTableTabs ul").append(tabLabel);

	//Create the tab content which is the datatable
	var tabContent = 	'<div class="dataSetResultTableTabContent" id="tabs-'+poiCollection.collectionName+'">'+
							'<div class="removeDataSetSearchButtons" id="removeDataSetSearchButtons'+poiCollection.collectionName+'">'+
								'<input class="showDataSetBtn btn" type="button" value="Show Data Set" data-collectionName="'+poiCollection.collectionName+'"/>'+
								'<input class="removeDataSetTabBtn btn" type="button" value="Remove Data Set Tab" data-collectionName="'+ poiCollection.collectionName +'"/>'+
							'</div>'+
							'<div class="chartPanel" id="chartPane-'+poiCollection.collectionName+'">Here goes the charts</div>'+
							'<table cellpadding="0" cellspacing="0" border="0" width="100%" class="list display gp_dataTable" id="' + poiCollection.collectionName + '"></table>'+
						'</div>';

	jQuery("#gp_dataTableTabs").append(tabContent);	

	//Refresh the tab panel so jQuery UI relfects the newly added tab, fist store the scroll offset as refresh could cause scroll bars to jump
	jQuery("#gp_dataTableTabs").tabs("refresh");

	jQuery('#gp_dataTablesNoData').hide();
}

function gp_constructRecordActionsDD(thisPOIC, aData) {
	var poi = {
		"uniqueId": aData[gp_ColumnInfo.uniqueId],
		"recordId": aData[gp_ColumnInfo.recordId],
		"title": aData[gp_ColumnInfo.title],
		"title2": aData[gp_ColumnInfo.title2],
		"lat": aData[gp_ColumnInfo.latitude],
		"lng": aData[gp_ColumnInfo.longitude],
		"street": aData[gp_ColumnInfo.street],
		"city": aData[gp_ColumnInfo.city],
		"postalCode": aData[gp_ColumnInfo.postalCode],
		"state": aData[gp_ColumnInfo.state],
		"country": aData[gp_ColumnInfo.country],
		"sfdcObject": thisPOIC.qo.mapObjectName,
	};
	return '<i class="fa fa-caret-square-o-down recordActionsDropDownIcon" title="View Record Actions" alt="View Record Actions"></i><div class="recordActionsDropDown" id="gpActionDD-' + aData[gp_ColumnInfo.uniqueId] + '">'
	  + buildPOIActions(thisPOIC,poi,'all')
	  + '<a href="#" onclick="gp_zoomToStreet(' + aData[gp_ColumnInfo.latitude] + ',' + aData[gp_ColumnInfo.longitude] + ',16);event.preventDefault();">' + gp_translations.Zoom_and_Center+'</a>'
	  + '</div>';
}

// Define the Data Table Columns array
function gp_defineDataTableColumns(thisPOIC){
	
	// Create column structure for jQuery Table
	var tableCols = new Array();
		
		// Hidden columns
		/* 0 */ tableCols.push({"sTitle" : "Unique Id", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "uniqueId"});
		/* 1 */ tableCols.push({"sTitle" : gp_translations.Record_Id, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "recordId"});
		/* 2 */ tableCols.push({"sTitle" : "Map Icon URL Data Table", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "mapIconURLDataTable"});
		/* 3 */ tableCols.push({"sTitle" : "Map Icon URL", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "mapIconURL"});
		/* 4 */ tableCols.push({"sTitle" : "Map Icon Color", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "mapIconColor"});
		/* 5 */ tableCols.push({"sTitle" : "Map Icon Size", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "mapIconSize"});
		/* 6 */ tableCols.push({"sTitle" : "Latitude", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "latitude"});
		/* 7 */ tableCols.push({"sTitle" : "Longitude", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "longitude"});
		/* 8 */ tableCols.push({"sTitle" : "Latitude (display)", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "latitudeDisplay"});
		/* 9 */ tableCols.push({"sTitle" : "Longitude (display)", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "longitudeDisplay"});
		/* 10 */ tableCols.push({"sTitle" : "Uses Customer Geocodes", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "usesCustomerGeocode"});
		
		// Displayed Columns
		var actionColWidth = '82px';
		var markerHeight = '23px';
		if(isTouchDevice){
			actionColWidth = '160px';
			markerHeight = '30px';	
		} 

		/* 11 */ tableCols.push({"sTitle" : "Actions", "bSearchable": false, "bSortable": false, "sClass": "dataCell", "sWidth": actionColWidth, "bUseRendered": false, "gpName" : "actions",
						"fnRender": function(obj) {
							
							var checkbox = "<input type=\"checkbox\" onclick=\"gp_toggleRecordSelection('"+obj.aData[gp_ColumnInfo.uniqueId]+"')\"";

							if(gp_selectedRecords[obj.aData[gp_ColumnInfo.uniqueId]]){
								checkbox += " checked ";
							}
							checkbox += "/>";

							var mapIcon = "<img style=\"cursor: pointer;\" height=\""+markerHeight+"\" onclick=\"javascript:gp_openPoiInfoMarker(\'" + obj.aData[gp_ColumnInfo.uniqueId] + "\'); return false;\" src=\"" + obj.aData[gp_ColumnInfo.mapIconURLDataTable] + "\"  title=\"Open Info Bubble on map\" alt=\"Open Info Bubble on map\" />";
							var recActions = gp_constructRecordActionsDD(thisPOIC, obj.aData) //obj.aData[gp_ColumnInfo.uniqueId]);
							var removePOI = "<i class='fa fa-times removeRecord' onclick=\"javascript:gp_removeMarkerTable(\'" + obj.aData[gp_ColumnInfo.uniqueId] + "\',\'" + obj.oSettings.sTableId + "\'); "+
											"gp_removeMarkerMap(\'" + obj.aData[gp_ColumnInfo.uniqueId] + "\'); "+
											"updateChartAfterMarkerRemoval(\'" + obj.oSettings.sTableId + "\'); "+
											"return false;\" title='Remove from Map' alt='Remove from Map'></i>";
							return checkbox + "&nbsp;" + mapIcon + "&nbsp;" + recActions + "&nbsp;" + removePOI;
						}
						});
		
		// Used to display the # column when map pins are numbered
		/* 12 */ tableCols.push({"sTitle" : "#", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "rowNum"});
		
		/* 13 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.titleLabel, "sClass": "dataCell notranslate", "sType": "html", "sWidth": "120px", "bUseRendered": false, "gpName" : "title", 
						"fnRender": function(obj) {
							var url = '';

							//Add url prefix, typically for Communities if it is present
							if(gp_orgSettings.urlPrefix){
								url = gp_orgSettings.urlPrefix + '/' + obj.aData[gp_ColumnInfo.recordId];
							}else{
								url = '/' + obj.aData[gp_ColumnInfo.recordId];
							}

							var sReturn = "<a href=\'" + url + "\' target=\'_blank\'>" + obj.aData[ obj.iDataColumn ] + "</a>";
							return sReturn;
						}
						});
		
		if (thisPOIC.hasTitle2) {
			/* 14 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.title2Label, "sClass": "dataCell notranslate", "sType": "string", "sWidth": "120px", "gpName" : "title2"});
		} else {
			/* 14 */ tableCols.push({"sTitle" : "Title 2", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "title2"});
		}
		
		 
		if (thisPOIC.displayFormattedAddress) {
			/* 15 */ tableCols.push({"sTitle" : gp_translations.Address, "sClass": "dataCell notranslate", "sType": "string", "sWidth": "160px", "gpName" : "fulladdress"});
			/* 16 */ tableCols.push({"sTitle" : gp_translations.Street, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "street"});
			/* 17 */ tableCols.push({"sTitle" : gp_translations.City, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "city"});
			/* 18 */ tableCols.push({"sTitle" : gp_translations.State_Province, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "state"});
			/* 19 */ tableCols.push({"sTitle" : gp_translations.Postal_Code, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "postalCode"});
			/* 20 */ tableCols.push({"sTitle" : gp_translations.Country, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "country"});
			/* 21 */ tableCols.push({"sTitle" : gp_translations.Country+" ISO", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "countryISO"});
		} else {
			/* 15 */ tableCols.push({"sTitle" : gp_translations.Address, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "fulladdress"});
			/* 16 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.streetLabel, "sClass": "dataCell notranslate", "sType": "string", "sWidth": "100px", "gpName" : "street"});
			/* 17 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.cityLabel, "sClass": "dataCell notranslate", "sType": "string", "gpName" : "city"});
			/* 18 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.stateLabel, "sClass": "dataCell notranslate", "sType": "string", "gpName" : "state"});
			/* 19 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.postalCodeLabel, "sClass": "dataCell notranslate", "sType": "string", "gpName" : "postalCode"});
			/* 20 */ tableCols.push({"sTitle" : thisPOIC.columnLabels.countryLabel, "sClass": "dataCell notranslate", "sType": "string", "gpName" : "country"});
			/* 21 */ tableCols.push({"sTitle" : gp_translations.Country+" ISO", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "countryISO"});
		}

		//Create dynamic columns based on additional fields selected in the dataset
		var numberOfFieldsToDisplay = angular.element('.dataSetController').scope().selectedDataSet.numOfFieldsDisplayedInTable - 1;

		for(var i = 0; i < thisPOIC.columnLabels.additionalFields.length; i++){
			var additionalField = thisPOIC.columnLabels.additionalFields[i];

			//Set is visible attribute, true for first 5 cols, false for remaining, also track if col is additional hidden field
			var isVisible = true;
			var isAdditionalHiddenField = false;
			if(i > numberOfFieldsToDisplay){
				isVisible = false;
				isAdditionalHiddenField = true;
			}

			//Create the type col
			tableCols.push({"sTitle" : "Column "+ i +" Type", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "col"+i+"Type"});
			tableCols.push({"sTitle" : additionalField.label, "sClass": "dataCell notranslate", "bUseRendered": false, "bVisible": isVisible, "isAdditionalHiddenField": isAdditionalHiddenField, "gpName" : "col"+i+"Value", "gpAPIname": additionalField.name,"gpFieldType": additionalField.datatype, "gpPrecision": additionalField.precision,"fnRender": function(obj) { return gp_renderInDataTable(obj); } });
		}

		if (thisPOIC.searchType == 'nearby') {
			/* 32 */ tableCols.push({"sTitle" : gp_translations.Distance + " (" + thisPOIC.distanceUnitsLabel + ")", "sClass": "dataCell", "sType": "numeric", "gpName" : "distance"});
		} else {
			/* 32 */ tableCols.push({"sTitle" : gp_translations.Distance, "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "distance"});
		}
		
		/* 33 */ tableCols.push({"sTitle" : gp_translations.Drive_Distance + " (" + thisPOIC.distanceUnitsLabel + ")", "sClass": "dataCell", "bVisible": false, "sType": "gpNumeric", "gpName" : "distanceDrive"});
		
		/* 34 */ 
		tableCols.push({"sTitle" : gp_translations.Geocode_Quality, "sClass": "dataCell", "sType": "string", "bUseRendered": false, "gpName" : "geocodeQuality",
						"fnRender": function(obj) {
							return gp_renderGeocodeQuality(obj);
						}
						});
		
		/* 35 */
		tableCols.push({"sTitle" : "Info Content", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell", "gpName" : "infoContent"});

		/* 36 & 37 Color By Field Type Type and Color By Value*/
		tableCols.push({"sTitle" : "Color by Field Type", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "colorByFieldType"});
		tableCols.push({"sTitle" : "Color by Value", "bSearchable": false, "bSortable": false, "bVisible": false, "sWidth": "0px", "sClass": "dataCell notranslate", "gpName" : "colorByValue"});
		
		//Create object that stores column name to column number, also create array that tracks the column number of additional fields that were hidden
		var columnInfo = {};
		var additionalHiddenFieldColNumbers = [];
		var apiNameToColNumber = {};
		var colNumToApiName = {};

		for(var i = 0; i < tableCols.length; i++){
			columnInfo[tableCols[i].gpName] = i;

			//populate list of additional fields that are hidden
			if(tableCols[i].isAdditionalHiddenField == true){
				additionalHiddenFieldColNumbers.push(i);
			}

			//populate object that keeps track of API name to column number, also populate object that stores colNumToApiName
			if(typeof tableCols[i].gpAPIname != 'undefined'){
				apiNameToColNumber[tableCols[i].gpAPIname] = i;
				colNumToApiName[i] = tableCols[i].gpAPIname;
			}
		}

		//Using jQuery data function attach the columnInfo object and list of additionalHiddenFieldColNumbers to the correct <table>
		jQuery("#" + thisPOIC.collectionName).data('columnInfo',columnInfo);
		jQuery("#" + thisPOIC.collectionName).data('additionalHiddenFieldColNumbers',additionalHiddenFieldColNumbers);
		jQuery("#" + thisPOIC.collectionName).data('apiNameToColNumber',apiNameToColNumber);
		jQuery("#" + thisPOIC.collectionName).data('colNumToApiName',colNumToApiName);

		// Define the sorting for the gpnumeric column (used for driving distance)
		jQuery.fn.dataTableExt.oSort['gpNumeric-asc'] = function(a,b) {
		    var x = Number(a);
		    var y = Number(b);
		    if (isNaN(x) && isNaN(y)) return 0;
		    if (isNaN(x)) return 1;
		    if (isNaN(y)) return -1;
		    return (x < y) ? -1 : x > y ? 1 : 0;
		};
		jQuery.fn.dataTableExt.oSort['gpNumeric-desc'] = function(a,b) {
		    var x = Number(a);
		    var y = Number(b);
		    if (isNaN(x) && isNaN(y)) return 0;
		    if (isNaN(x)) return -1;
		    if (isNaN(y)) return 1;
		    return (x < y) ? 1 : (x > y) ? -1 : 0;
		};

		return tableCols;
}

//Define a Data Table Row array
function gp_defineDataTableRow(thisPOIC, thisPOI){

	var tableRow = new Array();
		//tableRow.DT_RowId = thisPOI.uniqueId; // Set the Row Id
		/* 0 */ tableRow.push	(thisPOI.uniqueId); //Unique Id
		/* 1 */ tableRow.push	(thisPOI.recordId); //Record Id
		/* 2 */ tableRow.push	(thisPOI.mapIconURL); //Map Icon for Data Table
		/* 3 */ tableRow.push	(thisPOI.mapIconURL); //Map Icon
		/* 4 */ tableRow.push	(thisPOI.mapIconColor); //Map Icon Color
		/* 5 */ tableRow.push	(thisPOI.mapIconWidth + 'x' + thisPOI.mapIconHeight) ; //Map Icon Size
		/* 6 */ tableRow.push	(thisPOI.lat); //Latitude
		/* 7 */ tableRow.push	(thisPOI.lng); //Longitude
		/* 8 */ tableRow.push	(thisPOI.latDisplay); //Latitude (display)
		/* 9 */ tableRow.push	(thisPOI.lngDisplay); //Longitude (display)
		/* 9 */ tableRow.push	(thisPOI.usesCustomerGeocode); //Uses Customer Geocode
		
		/* 11 */ tableRow.push	('actions'); //Actions
		/* 12 */ tableRow.push	(thisPOI.mapIconText);
		/* 13 */ tableRow.push(thisPOI.title);
		
		if (thisPOIC.hasTitle2) {
			/* 14 */ tableRow.push(thisPOI.title2);
		} else {
			/* 14 */ tableRow.push('');
		}
		
		/* 15 */ tableRow.push(thisPOI.formattedAddr);
		/* 16 */ tableRow.push(thisPOI.street);
		/* 17 */ tableRow.push(thisPOI.city);
		/* 18 */ tableRow.push(thisPOI.state);
		/* 19 */ tableRow.push(thisPOI.postalCode);
		/* 20 */ tableRow.push(thisPOI.country);
		/* 21 */ tableRow.push(thisPOI.countryISO);
		
		//Create dynamic columns based on additional fields selected in the dataset
		for(var i = 0; i < thisPOI.additionalFields.length; i++){
			var additionalField = thisPOI.additionalFields[i];

			var typeValue = additionalField.datatype;
			var dataValue = additionalField.value;

			//Make values empty string if undefined
			if(!typeValue) typeValue = '';
			if(typeof dataValue == 'undefined' || dataValue == null){
				dataValue = '';
			}
		
			tableRow.push(typeValue);
			tableRow.push(dataValue);
		}
		
		if (thisPOIC.searchType == 'nearby') {
			/* 32 */ tableRow.push(thisPOI.distanceFromCenter);
		} else {
			/* 32 */ tableRow.push('');
		}
		
		/* 33 */ //tableRow.push('<img src="' + gpImg.loading + '"/>'); // Loading image
		/* 33 */ tableRow.push('-'); 
		
		/* 34 */ tableRow.push(thisPOI.geocodeQuality);
		
		/* 35 */ tableRow.push(thisPOI.baseInfoContentHTML);

		/* 36 */ 
		if(thisPOI.colorByFieldType){
			tableRow.push(thisPOI.colorByFieldType);
		}else{
			tableRow.push('');
		}

		/* 37 */ 
		if(thisPOI.colorByFieldValue){
			tableRow.push(thisPOI.colorByFieldValue);
		}else{
			tableRow.push('');
		}
		
	return tableRow;
}

// Returns formatted value based on data type
// Is Passed in "obj" from the fnRender function at http://www.datatables.net/usage/columns
function gp_renderInDataTable(obj){

	//Attempt to find the precision value
	var precision;
	try{
		precision = obj.oSettings.aoColumns[ obj.iDataColumn  ].gpPrecision;
	}catch(e){
		console.log(e);
	}
	
	//(fieldType,fieldValue,recordId,recordName,decimalPrecision)
	return gp_formatOutputField(
		obj.aData[gp_ColumnInfo.recordId],
		obj.aData[obj.iDataColumn-1],
		obj.aData[obj.iDataColumn],
		obj.aData[gp_ColumnInfo.recordId],
		obj.aData[gp_ColumnInfo.title],
		precision
	); 
}

function gp_formatOutputField(sfdcRecordId,fieldType,fieldValue,recordId,recordName,precision){

	//Special handling for shape fields
	if(fieldType == 'REFERENCE' && fieldValue.indexOf(gp_shapeObjectPrefix) == 0 && mapProvider == 'Google'){
		return '<a href="#" onclick="gp_goToShapeField(\''+sfdcRecordId+'\',\''+fieldValue+'\'); return false;">View Shape</a>';
	}

	var sReturn = '';
	switch (fieldType){
		case "DOUBLE":
		case "INTEGER":
			if(typeof fieldValue != 'number' && (fieldValue == null || typeof fieldValue == 'undefined' || fieldValue == '')){
				sReturn = '';
			}else{
				var decimalPlaces = precision;
				if(typeof decimalPlaces == 'undefined' || decimalPlaces == null || decimalPlaces == ''){
					sReturn = angular.injector(["ng"]).get("numberFilter")(fieldValue);
				}else{
					sReturn = angular.injector(["ng"]).get("numberFilter")(fieldValue,decimalPlaces);
				}
			}
			break;
		case "CURRENCY":
			if(fieldValue == null || typeof fieldValue == 'undefined' || fieldValue == ''){
				sReturn = '';
			}else{
				sReturn = angular.injector(["ng"]).get("currencyFilter")(fieldValue,gp_userSettings.userInfo.userCurrency.symbol);
			}
			break;
		case "URL":
			sReturn = fieldValue;
			if (fieldValue.indexOf('http') != 0){ sReturn = 'http://' + sReturn; }
			sReturn = "<a href=\'" + sReturn + "\' target=\'_blank\'>" + fieldValue + "</a>";
			break;
		case "EMAIL":
			sReturn = "<a href=\'mailto:" + fieldValue + "\'>" + fieldValue + "</a>";
			break;
		case "BOOLEAN":
			if (fieldValue == "true" || fieldValue == true){
				sReturn = "<img src=\'" + gpImg.checkbox_checked + "\' alt=\'true\' />";
			} else {
				sReturn = "<img src=\'" + gpImg.checkbox_unchecked + "\' alt=\'false\' />";
			}
			break;
		case "PHONE":
			sReturn = fieldValue;
			var currVal = fieldValue;
			if(typeof(gp_orgSettings) != "undefined"){
				if(typeof(gp_orgSettings.descByKeyPref) != "undefined"){
					var theId = recordId;
					var prefix = theId.substring(0,3);
					if(typeof(gp_orgSettings.descByKeyPref[prefix]) != "undefined"){
						if(typeof(Sfdc) != "undefined"){
							if(typeof(Sfdc.cti) != "undefined"){
								//if(typeof(Sfdc.cti.ctiondemand) != "undefined"){
									//if(Sfdc.cti.ctiondemand.initialized){
										sReturn = '<a href="javascript:sendCTIMessage(\'/CLICK_TO_DIAL?DN=' + encodeURIComponent(currVal) + '&ID=' + recordId + '&ENTITY_NAME=' + gp_orgSettings.descByKeyPref[prefix].name + '&OBJECT_NAME=' + encodeURIComponent(recordName) + '\')">' + 
										currVal + 
										'<img width="16" height="10" title="Click to dial" alt="Click to dial" src="/img/btn_dial_inline.gif">' + 
										'</a>';
									//}
								//}
							}
						}
					}
				}
			}
			break;
		default:
			//Render formula field URLs as html, unescape them
			if(fieldValue && typeof fieldValue == 'string' && fieldValue.startsWith('&lt;')){
				sReturn = jQuery('<span>').html(fieldValue).text();
			}else{
				sReturn = fieldValue;
			}
			
			break;
	}
	
	return sReturn;
}

//Returns formatted value for the Geocode Quality column
//Is Passed in "obj" from the fnRender function at http://www.datatables.net/usage/columns
function gp_renderGeocodeQuality(obj){
	var theValue = obj.aData[ obj.iDataColumn ];
	return gp_renderGeocodeQualityFromValue(theValue);
}
function gp_renderGeocodeQualityFromValue(theValue){
	if (theValue == ''){ theValue = 'CUSTOM' };
	var preImage = '';
	if (theValue == 'POINT' || theValue == 'ADDRESS' || theValue == 'STREET' || theValue == 'INTERSECTION' || theValue == 'ROOFTOP' || theValue == 'CUSTOM'){
		preImage = "<img src=\"" + gpImg.confirm12 + "\"  title=\"Good Geocode Quality!\" />";
	} else if (theValue == 'CITY' || theValue == 'ZIP' || theValue == 'ZIP_EXTENDED' || theValue == 'RANGE_INTERPOLATED'){
		preImage = "<img src=\"" + gpImg.warning12 + "\"  title=\"Average Geocode Quality!\"  />";
	} else if (theValue == 'COUNTY' || theValue == 'STATE' || theValue == 'COUNTRY' || theValue == 'GEOMETRIC_CENTER' || theValue == 'APPROXIMATE'){
		preImage = "<img src=\"" + gpImg.error12 + "\"  title=\"Poor Geocode Quality!\"  />";
	}
	return preImage + " " + theValue;
}

// Remove Marker from a Table
function gp_removeMarkerTable(markerID, tableId) {
	
	// Find and remove the data table row
	var aoData = jQuery('#' + tableId).dataTable().fnGetData();
	var gp_ColumnInfo = jQuery('#' + tableId).data('columnInfo');

	for(var i = 0, iLen = aoData.length; i < iLen; i++) {
		if (aoData[i][gp_ColumnInfo.uniqueId] == markerID){
			jQuery('#' + tableId).dataTable().fnDeleteRow(i);
			break;
		}
	}

	//Recalculate the number of records in shapes
	try{ calcRecordsInShapes(); }catch(e){} //function doesn't exist for MQ

	//Decrement the record count in the data table tab
	var $countBubble = jQuery("#countBubble-"+tableId);
	var newCount = parseInt($countBubble.text()) - 1;
	$countBubble.text(newCount);

	//Decrement number in layers list
	gp_dataSetSearches[tableId].numOfRecords--;
	if(mapProvider == 'Google') angular.element('.layersController').scope().$broadcast('layersChanged',{doApply: true}); 
}

//Select all records in a datatable
function gp_toggleAllInDataTable(collectionName){

	var aoData = jQuery('#' + collectionName).dataTable().fnGetData();
	var aiDisplay = jQuery('#' + collectionName).dataTable().fnSettings().aiDisplay;
	var gp_ColumnInfo = jQuery('#' + collectionName).data('columnInfo');

	//Get selectAllCheckBox value
	var selectAll = jQuery('#toggleAllInDataTable'+collectionName).is(':checked');

	for(var i = 0; i < aiDisplay.length; i++) {
		var rowNum = aiDisplay[i];
		var row = aoData[rowNum];
		var poiId = row[gp_ColumnInfo.uniqueId];

		if(selectAll == true && (typeof gp_selectedRecords[poiId] == 'undefined' || gp_selectedRecords[poiId] == false )){
			gp_toggleRecordSelection(poiId);

		}else if(selectAll == false && gp_selectedRecords[poiId] == true){
			gp_toggleRecordSelection(poiId);
		}
	}
}

//Initialize the Data Table
function gp_initDataTable(thisPOIC, tableCols, tableData){
	
	// Create the Data Table
	jQuery('#' + thisPOIC.collectionName).dataTable( {
		"bPaginate": true,
		"sPaginationType": "full_numbers",
		"bLengthChange": true,
		"aLengthMenu": [[5, 10, 25, 50, 100, 250, 500, -1], [5, 10, 25, 50, 100, 250, 500, gp_translations.All]],
		"iDisplayLength": 25,
		"bProcessing": false, 
		"bDeferRender": true,
		"aaSorting": [],
		"bSortClasses": false,
		"asStripClasses": [ 'dataRow odd', 'dataRow even' ], // add classes to alternating rows
		"bJQueryUI": false, 
		"sDom": '<"gp_tablecontrols"pfl> rt', // inject table components into the DOM
		"aaData": tableData, // the data
		"bInfo": false,
		"aoColumns": tableCols, // the columns
		"bAutoWidth": false,
		"fnInfoCallback": 	function( oSettings, iStart, iEnd, iMax, iTotal, sPre ) {
								return "<b>" + sPre + "</b>";
							},
		"oLanguage": gp_dataTableTranslations
	} );

	//Add a select all checkbox, timeout becuase creation of table is delay and we need to add checkbox after table has been rendered
	setTimeout(function(){
		jQuery('#'+thisPOIC.collectionName).find('tr.headerRow').find('th:first').prepend('<input type="checkbox" id="toggleAllInDataTable'+thisPOIC.collectionName+'" onclick="gp_toggleAllInDataTable(\''+thisPOIC.collectionName+'\');"/>&nbsp;&nbsp;');
	},1)
	//Add a chart button to the table control pane
	jQuery('#' + thisPOIC.collectionName + '_wrapper .gp_tablecontrols').append('<div class="btn showChartBtn" onclick="showChartPane(\''+ thisPOIC.collectionName +'\');"><img src="'+chartIconURL+'"/></div>');
	
	//Show Heatmap button for google
	if(gp_orgSettings.settings__c[nameSpacePrefix + 'Mapping_Provider__c'] == 'Google'){
		jQuery('#' + thisPOIC.collectionName + '_wrapper .gp_tablecontrols').append(
			'<div class="showHeatMapWrapper">'+
				'<div class="btn showHeatMapBtn" onclick="toggleHeatMap(this,\''+ thisPOIC.collectionName +'\');">'+
					'<img src="'+heatMapIconURL+'"/>'+
				'</div>'+
				'<div id="heatMapSlider-'+thisPOIC.collectionName+'" class="heatMapSliderWrapper">'+
					'<img src="'+heatIntensityLowIconURL+'" class="heatMapLowIntensityIcon"/>'+
					'<div id="heatmapSlider-'+thisPOIC.collectionName+'" class="heatMapRadiusSlider"></div>'+
					'<img src="'+heatIntensityHighIconURL+'" class="heatMapHighIntensityIcon"/>'+
					'<div class="btn toggleMarkersBtn" onclick="toggleMapMarkers(this,\''+ thisPOIC.collectionName +'\');">'+
						'<img src="'+showHidePinsIconURL+'"/>'+
					'</div>'+
				'</div>'+
			'</div>'
		);

		//Enable slider
		jQuery( "#heatmapSlider-"+thisPOIC.collectionName).slider({
			value: 40,
			min: 5,
			max: 100,
			step: 5,
			slide: function( event, ui ) {
				gp_heatmaps[thisPOIC.collectionName].set('radius',ui.value);
			}
		});
	}

	//Init the charting controls
	buildChartControls(thisPOIC);

	/* Fix up the table with Salesforce CSS that cannot be applied through the data tables plugin */
	// header row
	jQuery('#' + thisPOIC.collectionName + ' thead tr').removeClass('dataRow');
	jQuery('#' + thisPOIC.collectionName + ' thead tr').addClass('headerRow');

	//"click" that data set tab for the current search
	jQuery("#gp_dataTableTabs ul li.dataSetResultTableTab:last a").click();

	// Add properties to the table
	var oSettings = jQuery('#' + thisPOIC.collectionName).dataTable().fnSettings();
	oSettings.gp_collectionName = thisPOIC.collectionName;
	oSettings.gp_dataSetName = thisPOIC.dataSetName;
	oSettings.gp_sfdcObject = thisPOIC.sfdcObject;
	oSettings.gp_mapIconColor = thisPOIC.mapIconColor;

	//If this was a radial search sort the table by distance
	if(thisPOIC.searchType == 'nearby'){
		//Find the index of the distance column and sort by this
		var distanceCol = jQuery("#" + thisPOIC.collectionName).data('columnInfo')['distance'];
		jQuery("#" + thisPOIC.collectionName).dataTable().fnSort([[distanceCol,'asc']]);
	
	}else if(!thisPOIC.qo.orderBy){ //sort by name if no order by specified
		//Find the index of the distance column and sort by this
		var nameCol = jQuery("#" + thisPOIC.collectionName).data('columnInfo')['title'];
		jQuery("#" + thisPOIC.collectionName).dataTable().fnSort([[nameCol,'asc']]);
	}
}

// Read table data, create CSV and send to server
function gp_writeCSV(){
	
	gp_clearHiddenFields();
	
	var csv = '';
	var exportHiddenCols = [gp_ColumnInfo.recordId]; // Id
	var ignoreVisibleCols = [gp_ColumnInfo.actions]; // actions
	var newline = navigator.userAgent.match(/Windows/) ? "\r\n" : "\n";
	var applyToVal = jQuery("#applyActionTo").val();
	var numberPins = jQuery("#mySettingsNumberPins").is(':checked');
	
	// Get all data tables
	var allTables = gp_getTablesToProcess();
	
	// Don't continue if there's no data
	if (allTables.length == 0){ return false; }
	
	// Loop through each table
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		// Get Table Settings Object
		var oSettings = jQuery(allTables[i]).dataTable().fnSettings();
		
		// Get the Table Data
		var aoData = jQuery(allTables[i]).dataTable().fnGetData();
		var additionalHiddenFieldColNumbers = jQuery(allTables[i]).data('additionalHiddenFieldColNumbers');
		var columnInfo = jQuery(allTables[i]).data('columnInfo');

		var numOfAddedRows = 0;
		
		// Build header row by looping through each column definition
		var headerRow = '';

		//Add a number column if mapped pins are numbered
		if(numberPins){
			headerRow = '"#"';
		}

		for ( var j=0, jLen=oSettings.aoColumns.length ; j<jLen ; j++ ){
			
			// Get column
			var col = oSettings.aoColumns[j];

			//if visible, but not set to be ignored                          OR it's in the list to always export 						   OR it is a hidden additional field
			if ( (col.bVisible && jQuery.inArray(j,ignoreVisibleCols) == -1) || (!col.bVisible && jQuery.inArray(j,exportHiddenCols) > -1) || jQuery.inArray(j,additionalHiddenFieldColNumbers) > -1 ){
				if (headerRow != '') { headerRow += ','; } 
				headerRow += gp_CSVBoundData(col.sTitle);
				
				// Add data set name and sfdc object right after the ID column
				if (j == 1){
					headerRow += ',' + gp_CSVBoundData(gp_translations.Object_Name);
					headerRow += ',' + gp_CSVBoundData(gp_translations.Data_Set_Name);
				}
			}
			
		}
		
		// Add header row to CSV string
		csv += headerRow + newline;
		
		// Build data rows, get the correct data structure to loop over displayed or all
		var dataArrayToLoop = oSettings.aiDisplay;
		if(jQuery("#applyActionTo").val() == 'selectedRecords'){ //If we are exporting selected records loop over all data, not just displayed
			dataArrayToLoop = aoData;
		}

		for ( var j = 0; j < dataArrayToLoop.length; j++ ){
						
			var row = aoData[j];

			if( ( applyToVal == 'selectedRecords' && gp_selectedRecords[ row[gp_ColumnInfo.uniqueId] ] ) || jQuery("#applyActionTo").val() != 'selectedRecords'){

				var dataRow = '';

				//If pin is numbered, export the number
				var iconURL;

				if(jQuery("#applyActionTo").val() != 'selectedRecords'){
					iconURL = aoData[dataArrayToLoop[j]][columnInfo.mapIconURL];
				}else{ //selected records
					iconURL = row[columnInfo.mapIconURL];
				}

				if(numberPins && iconURL.indexOf('text=') > -1){

					var rowNum = iconURL.substring(iconURL.indexOf('text=')+5,iconURL.length);

					//Make sure rowNom is a valid number
					if(!isNaN(rowNum)){
						dataRow = '"'+ rowNum + '"';
					}
				}
				
				// Loop through each column in the row
				for ( var k=0, kLen=oSettings.aoColumns.length ; k<kLen ; k++ ){
					
					// Get column definition
					var col = oSettings.aoColumns[k];
					
					//if visible, but not set to be ignored							 OR		it's in the list to always export 					   OR it is a hidden additional field
					if ( (col.bVisible && jQuery.inArray(k,ignoreVisibleCols) == -1) || (!col.bVisible && jQuery.inArray(k,exportHiddenCols) > -1) || jQuery.inArray(k,additionalHiddenFieldColNumbers) > -1 ){
						
						// Get data from Column
						var colData;
						if(jQuery("#applyActionTo").val() != 'selectedRecords'){
							colData = aoData[ oSettings.aiDisplay[j] ][k];
						}else{
							colData = aoData[j][k]; 
						}
						
						if ( typeof colData == "string" ){
							colData = gp_CSVCleanData(colData);
						} else {
							colData = colData+"";
						}
						
						/* Trim and clean the data */
						colData = colData.replace(/^\s+/, '').replace(/\s+$/, '');
						if (colData.indexOf( '&' ) != -1 ){
							colData = gp_htmlDecodeForCSV( colData );
						}
						
						if (dataRow != '') { dataRow += ','; }
						dataRow += gp_CSVBoundData(colData);
						
						// Add data set name and sfdc object right after the ID column
						if (k == 1){
							dataRow += ',' + gp_CSVBoundData(oSettings.gp_sfdcObject);
							dataRow += ',' + gp_CSVBoundData(oSettings.gp_dataSetName);
						}
					}
				}

				csv += dataRow + newline;

				numOfAddedRows++;
			}
			
			
			
		} // END OF Rows Loop
		
		// Add a newline between tables 
		csv += newline;
		
	} // END OF tables loop
	
	/* Remove the last new line */
	csv.slice( 0, -1 );
	
	/* Write CSV data to hidden form field and submit the form to the export CSV page */
	jQuery("#gp_csvData").val(csv);
	document.forms.gp_getCSV.submit();
	
	return true;
	
}

//Read table data, create KML and send to server
function gp_writeKML(){
	
	gp_clearHiddenFields();
	
	var kml = '';
	var newline = navigator.userAgent.match(/Windows/) ? "\r\n" : "\n";
	var applyToVal = jQuery("#applyActionTo").val();
	
	// Clean up the hidden data
	jQuery(gp_UIElem.hidden_kmlExport).val('');
	
	// Get all data tables
	var allTables = gp_getTablesToProcess();
	
	// Don't continue if there's no data
	if (allTables.length == 0){ return false; }
	
	var colorList = [];
	var colorKeyList = [];

	var markerURLs = {};

	// Loop through each table and get the unique colors/symbols for the markers
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		// Get Table Settings Object on column info
		var oSettings = jQuery(allTables[i]).dataTable().fnSettings();
		var gp_ColumnInfo = jQuery(allTables[i]).data('columnInfo');
		
		// Loop through the rows and get the various colors
		for ( var j=0, jLen=oSettings.aiDisplay.length ; j<jLen ; j++ ){
			var markerURL = oSettings.aoData[ oSettings.aiDisplay[j] ]._aData[gp_ColumnInfo.mapIconURL];

			markerURLs[markerURL] = '';
		}
	}

	//Build the KML styles
	for(url in markerURLs) {
		kml += '<Style id="Style_' + url + '">' + newline;
			kml += '<IconStyle>' + newline;
				kml += '<Icon>' + newline;
					kml += '<href><![CDATA['+url+']]></href>' + newline;
				kml += '</Icon>' + newline;
				kml += '<scale>0.5</scale>' + newline;
				kml += '<hotSpot x="0.5" y="0" xunits="fraction" yunits="fraction"/>' + newline;
			kml += '</IconStyle>' + newline;
			kml += '<LabelStyle>' + newline;
				kml += '<scale>0.8</scale>' + newline;
			kml += '</LabelStyle>' + newline;
		kml += '</Style>' + newline;
	}
	
	
	// Loop through each table to do the placemarks
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		// Get Table Settings Object
		var oSettings = jQuery(allTables[i]).dataTable().fnSettings();
		var gp_ColumnInfo = jQuery(allTables[i]).data('columnInfo');
		
		// Get the Table Data
		var aoData = jQuery(allTables[i]).dataTable().fnGetData();
		
		kml += '<Folder>' + newline;
		kml += '<name>' + oSettings.gp_dataSetName + '</name>' + newline;

		var numOfAddedRows = 0;

		// Build data rows, get the correct data structure to loop over displayed or all
		var dataArrayToLoop = oSettings.aiDisplay;
		if(jQuery("#applyActionTo").val() == 'selectedRecords'){ //If we are exporting selected records loop over all data, not just displayed
			dataArrayToLoop = aoData;
		}
		
		// Loop through the rows
		for ( var j = 0; j < dataArrayToLoop.length; j++ ){
			
			var thisRow = aoData[j];

			if( ( applyToVal == 'selectedRecords' && gp_selectedRecords[ thisRow[gp_ColumnInfo.uniqueId] ] ) || jQuery("#applyActionTo").val() != 'selectedRecords'){
				
				var row;
				if(jQuery("#applyActionTo").val() != 'selectedRecords'){
					row = aoData[ oSettings.aiDisplay[j] ];
				}else{
					row = aoData[j]; 
				}

				kml += '<Placemark>' + newline;
				kml += '<name><![CDATA[' + row[gp_ColumnInfo.title] + ']]></name>' + newline;
				kml += '<description><![CDATA[';
				
				// Info Content
				kml += '<div style="margin:10px 0;">' + row[gp_ColumnInfo.infoContent] + '</div>';
				kml += '<div style="margin:10px 0;"><a href="javascript:window.open(\'about:blank\');" onclick="window.open(\'' + gp_baseURL + '/' + row[gp_ColumnInfo.recordId] + '\');" target="_blank">'+gp_translations.View_in_Salesforce+'</a></div>';
				
				// End the Placemark tag after each row
				kml += ']]></description>' + newline;
				kml += '<styleUrl>#Style_' + row[gp_ColumnInfo.mapIconURL] + '</styleUrl>';
				kml += '<Point>' + newline;
				kml += '<coordinates>' + row[gp_ColumnInfo.longitude] + ',' + row[gp_ColumnInfo.latitude] + ',0</coordinates>' + newline;
				kml += '</Point>' + newline;
				kml += '</Placemark>' + newline;

				numOfAddedRows++;
			}
			
		} // END OF Rows Loop
		
		// End the Folder tag after each table
		kml += '</Folder>' + newline;
		
	} // END OF tables loop
	
	/* Write KML data to hidden form field and submit the form to the export KML page */
	jQuery("#gp_kmlData").val(kml);
	document.forms.gp_getKML.submit();

	return true;
	
}

//Wrap data up in double quotes and escape double quotes inside the data
function gp_CSVBoundData(sData) {
	var regex = new RegExp("\"", "g");
	sBoundary = "\"";
	//Add a quote to each end of the string and replace any " with two ""
	return sBoundary + sData.replace(regex, "\"\"") + sBoundary;
}

function gp_CSVCleanData(sData) {
	
	var sReturn;
	
	/* Strip newlines, replace img tags with alt attr. and finally strip html... */
	sReturn = sData.replace(/\n/g," ");
	sReturn = sReturn.replace(/<img.*?\s+alt\s*=\s*(?:"([^"]+)"|'([^']+)'|([^\s>]+)).*?>/gi, '$1$2$3')
	sReturn = sReturn.replace( /<.*?>/g, "" );
	
	return sReturn;
}

// Decode HTML entities
function gp_htmlDecodeForCSV(sData) {
	var 
		aData = gp_ChunkData( sData, 2048 ),
		n = document.createElement('div'),
		i, iLen, iIndex,
		sReturn = "", sInner;
	
	/* nodeValue has a limit in browsers - so we chunk the data into smaller segments to build
	 * up the string. Note that the 'trick' here is to remember than we might have split over
	 * an HTML entity, so we backtrack a little to make sure this doesn't happen
	 */
	for ( i=0, iLen=aData.length ; i<iLen ; i++ )
	{
		/* Magic number 8 is because no entity is longer then strlen 8 in ISO 8859-1 */
		iIndex = aData[i].lastIndexOf( '&' );
		if ( iIndex != -1 && aData[i].length >= 8 && iIndex > aData[i].length - 8 )
		{
			sInner = aData[i].substr( iIndex );
			aData[i] = aData[i].substr( 0, iIndex );
		}
		
		n.innerHTML = aData[i];
		sReturn += n.childNodes[0].nodeValue;
	}
	
	return sReturn;
}

// Break a string up into an array of smaller strings
function gp_ChunkData( sData, iSize ) {
	var asReturn = [];
	var iStrlen = sData.length;
	
	for ( var i=0 ; i<iStrlen ; i+=iSize )
	{
		if ( i+iSize < iStrlen )
		{
			asReturn.push( sData.substring( i, i+iSize ) );
		}
		else
		{
			asReturn.push( sData.substring( i, iStrlen ) );
		}
	}
	
	return asReturn;
}

/*************************
* jQuery Route Data Tables functions
*************************/
function __JQUERY_DATA_TABLE_ROUTING_FUNCTIONS__(){}

//Create the route tab for the directions
function gp_createRouteTab(){
	if(jQuery("#routeDirectionsTab").length == 0){
		var tabLabel = '<li id="routeDirectionsTab">'+
							'<a href="#tabs-route">'+
								'<span id="routeTabLabel">'+gp_translations.Route_Detail+'</span>'+
								'<img id="routeDirectionsIcon" src="'+directionsURL+'"/>'+
								'<img class="tabShowHideIcon tabHideIcon" id="removeRouteIcon" src="'+blackXiconURL+'" title="'+gp_translations.Remove_route_from_map+'"/>'+
								'<img class="tabShowHideIcon tabShowIcon" id="showRouteIcon" src="'+blackPlusIconURL+'" title="'+gp_translations.Show_route_on_map+'"/>'+
							'</a>'+
						'</li>'; 
		jQuery("#gp_dataTableTabs ul").append(tabLabel);
	}

	if(jQuery(".routeDirectionsTabContent").length == 0){
		//Create the tab content which is the datatable
		var tabContent = '<div class="routeDirectionsTabContent" id="tabs-route">'+
							'<div id="removeRouteButtons">'+
								'<input id="showRouteBtn" type="button" class="btn" value="'+gp_translations.Show_Route+'"/>'+
								'<input id="removeRouteTabBtn" type="button" class="btn" value="'+gp_translations.Remove_Route_Tab+'"/>'+
							'</div>'+
							'<div id="routeNarrativeDIVWrapper">'+
								'<div id="routeNarrativeDIV"></div>'+
							'</div>'+
						 '</div>';
		jQuery("#gp_dataTableTabs").append(tabContent);	
	}

	//Remove any hidden tab styles that ay be present
	jQuery("#routeTabLabel").removeClass('tabDataHidden');

	//Hide the remove route buttons and show the route narrative
	jQuery("#removeRouteButtons").hide();
	jQuery("#routeNarrativeDIVWrapper").show();

	//Refresh the tab panel so jQuery UI relfects the newly added tab, fist store the scroll offset as refresh could cause scroll bars to jump
	jQuery("#gp_dataTableTabs").tabs("refresh");
	
	//Hide the no data message
	jQuery('#gp_dataTablesNoData').hide();

	//Make sure the route tab has focus by "clicking" it, only do this if there are no other tabs
	if(jQuery(".dataSetResultTableTab").length == 0){
		jQuery("#routeDirectionsTab a").click();
	}

	//Show the table tabs
	jQuery("#gp_dataTables").show();	

	//Set the left and right padding for the tabs, varies due to translations
	var $tabsList = jQuery("#gp_dataTableTabs ul:first");
	$tabsList.css({'padding-left': jQuery("#mappedDataTitle").width() + 17, 'padding-right': jQuery("#mappedDataButtons").width() + 13});
}

//Remove the route detail tab
function gp_removeRouteTab(){
	
	//Check to see if the route tab is the currently selected tab
	var wasRouteTabSelected = jQuery("#routeDirectionsTab").hasClass('ui-tabs-active');

	jQuery("#routeDirectionsTab").remove();
	jQuery(".routeDirectionsTabContent").remove();

	//If there are no other tabs, show the no data message
	if(jQuery(".dataSetResultTableTab").length == 0){
		jQuery("#gp_dataTablesNoData").show();
		jQuery("#gp_dataTables").hide();

	}else if(wasRouteTabSelected == true){ //Select the first tab if the open tab as the route tab
		jQuery(".dataSetResultTableTab:first a").click();
	}
}

// Add to Route from the Data Table
function gp_addToRouteFromDataTable(markerId, tableId){
	
	// Find the data table row
	var aoData = jQuery('#' + tableId).dataTable().fnGetData();
	var gp_ColumnInfo = jQuery('#' + tableId).data('columnInfo');
	var thisRow;
	for(var i = 0, iLen = aoData.length; i < iLen; i++) {
		if (aoData[i][gp_ColumnInfo.uniqueId] == markerId){
			thisRow = aoData[i];
			break;
		}
	}

	var routeStop = {
		id: guid(),
		source: 'sfdc',
		sourceId: thisRow[gp_ColumnInfo.recordId],
		name: '', //set below
		street: thisRow[gp_ColumnInfo.street],
		city: thisRow[gp_ColumnInfo.city],
		state: thisRow[gp_ColumnInfo.state],
		postalCode: thisRow[gp_ColumnInfo.postalCode],
		country: thisRow[gp_ColumnInfo.country],
		countryISO: thisRow[gp_ColumnInfo.countryISO],
		lat: thisRow[gp_ColumnInfo.latitude],
		lng: thisRow[gp_ColumnInfo.longitude],
		geocodeQuality: thisRow[gp_ColumnInfo.geocodeQuality],
	    typeOfRecord: 'routeStop',
	    sfdcId: thisRow[gp_ColumnInfo.recordId],
	    mapObjectName: (typeof(gp_orgSettings) != "undefined" && typeof(gp_orgSettings.descByKeyPref) != "undefined") ? gp_orgSettings.descByKeyPref[thisRow[gp_ColumnInfo.recordId].substring(0,3)]["name"].toLowerCase() : '',
	}

	//Set name value on the routeStop
	if (thisRow[gp_ColumnInfo.title2] == ''){
		routeStop.name = thisRow[gp_ColumnInfo.title];
	} else {
		routeStop.name = thisRow[gp_ColumnInfo.title] + ' | ' + thisRow[gp_ColumnInfo.title2];
	}

	//Add an item to the route in our angular routecontroller
	angular.element(jQuery('#routePanel')).scope().addToRouteFromExternal(routeStop);

	//Show growl message
    jQuery.jGrowl("<i ignore>" + routeStop.name + '</i> '+ gp_translations.was_succesfully_added_to_Route);
}

function gp_addToRouteRightClick(){
	
	//If the google javascript api is not loaded, load it for this search, and call this function again after it has loaded
	if(typeof google =='undefined'){
		gp_loadGoogScript('gp_addToRouteRightClick');
		return false;
	}

	//Create geocode request with lat and long for reverse geocode
	var latlng = new google.maps.LatLng(rightClickLatLng.lat,rightClickLatLng.lng)

	//Do the reverse geocode 
	var geocoder = new google.maps.Geocoder();
	geocoder.geocode({'latLng': latlng}, function(results, status) {

		if (status == google.maps.GeocoderStatus.OK) {
			
			//Hide the context menu.
	 		jQuery("#mapContextMenu").hide();

			//Parse google geocode
			var address = gp_parseGoogleGeocode(results[0]);

			//build a poi object
			routePOI = {
				lat: results[0].geometry.location.lat(),
				lng: results[0].geometry.location.lng(),
				countryISO: address.country,
				title: address.title,
				street: address.street,
				city: address.city,
				state: address.state,
				postalCode: address.postalCode,
				country: address.country,
				geocodeQuality: 'CUSTOM',
				usesCustomerGeocode: '',
				recordId: ''
			};

			//Add the poi object to the route
			gp_addToRouteSearchOrCenterPOI(routePOI,'rightClick');

		}else{
			alert(gp_translations.Unable_to_add_location);
			if(console && console.log){
				console.log(status);
			}
		}

		//Called to reset the ActionFunction bug		
		gp_emptyActionFunction(); 
	});

	gp_trackRightClick('Add to Route');
}

function gp_addToRouteSearchOrCenterPOI(poi,type){

	if(poi){
		
		var routeStop = {
			id: guid(),
			source: 'sfdc',
			sourceId: poi.recordId,
			name: poi.title, 
			street: poi.street,
			city: poi.city,
			state: poi.state,
			postalCode: poi.postalCode,
			country: poi.country,
			countryISO: poi.countryISO,
			lat: poi.lat,
			lng: poi.lng,
			geocodeQuality: poi.geocodeQuality,
		    typeOfRecord: type
		}

		//Add an item to the route in our angular routecontroller
		angular.element(jQuery('#routePanel')).scope().addToRouteFromExternal(routeStop);
		
		//Show confirmation message
		if(type == 'search' || type == 'rightClick'){
			//jQuery.jGrowl(gp_translations.Location_successfully_added_to_the_Current_Route_list);
		}else{
			//Center point message
			jQuery.jGrowl("<i ignore>" + gp_htmlEncode(poi.title) + '</i> ' + gp_translations.was_succesfully_added_to_Route);
		}
	}
}

// Adds all data table data to the route
function gp_addAllToRoute(idArray){
	var allTables = gp_getTablesToProcess();
	if (allTables.length == 0){ return false; }
	
	var recordsToAdd = [];

	var applyToVal = jQuery("#applyActionTo").val();
	var idMap = [];
	if (typeof idArray != 'undefined' && idArray.length > 0) {
		applyToVal = 'idArray';
		for (i=0, stop = idArray.length; i<stop; i++) 
			idMap[idArray[i]] = 1;
	}
	
	// Loop thru all tables
	for(var i = 0, iLen = allTables.length; i < iLen; i++) {
		
		//Use the column info object attached to the data table as each table could have different number of columns
		var gp_ColumnInfo = jQuery(allTables[i]).data('columnInfo');

		var oSettings = jQuery(allTables[i]).dataTable().fnSettings();
		
		// Get the Table Data
		var aoData = jQuery(allTables[i]).dataTable().fnGetData();
		var dataArrayToLoop = oSettings.aiDisplay;
		if(jQuery("#applyActionTo").val() == 'selectedRecords'){ //If we are exporting selected records loop over all data, not just displayed
			dataArrayToLoop = aoData;
		}
		
		// Loop through the rows
		for ( var j = 0; j < dataArrayToLoop.length; j++ ){

			var thisRow;
			if(jQuery("#applyActionTo").val() != 'selectedRecords'){
				thisRow = aoData[ dataArrayToLoop[j] ];
			}else{
				thisRow = aoData[j]; 
			}
			
			if( (applyToVal == 'idArray' && idMap[ thisRow[gp_ColumnInfo.recordId] ] ) || 
				(applyToVal == 'selectedRecords' && gp_selectedRecords[ thisRow[gp_ColumnInfo.uniqueId] ] ) || 
				(applyToVal != 'selectedRecords' && applyToVal != 'idArray')) {

				var routeStop = {
					id: guid(),
					source: 'sfdc',
					sourceId: thisRow[gp_ColumnInfo.recordId],
					name: '', //set below
					street: thisRow[gp_ColumnInfo.street],
					city: thisRow[gp_ColumnInfo.city],
					state: thisRow[gp_ColumnInfo.state],
					postalCode: thisRow[gp_ColumnInfo.postalCode],
					country: thisRow[gp_ColumnInfo.country],
					countryISO: thisRow[gp_ColumnInfo.countryISO],
					lat: thisRow[gp_ColumnInfo.latitude],
					lng: thisRow[gp_ColumnInfo.longitude],
					geocodeQuality: thisRow[gp_ColumnInfo.geocodeQuality],
				    typeOfRecord: 'routeStop',
				    sfdcId: thisRow[gp_ColumnInfo.recordId],
	    			mapObjectName: (typeof(gp_orgSettings) != "undefined" && typeof(gp_orgSettings.descByKeyPref) != "undefined") ? gp_orgSettings.descByKeyPref[thisRow[gp_ColumnInfo.recordId].substring(0,3)]["name"].toLowerCase() : '',
				}

				//Set name value on the routeStop
				if (thisRow[gp_ColumnInfo.title2] == ''){
					routeStop.name = thisRow[gp_ColumnInfo.title];
				} else {
					routeStop.name = thisRow[gp_ColumnInfo.title] + ' | ' + thisRow[gp_ColumnInfo.title2];
				}

				recordsToAdd.push(routeStop);
			}
		}
	}

	if(recordsToAdd.length > 40){
		jQuery.jGrowl(gp_translations.There_are_too_many_points_mapped_to_add);
		return false; 
	}else{
		//Add stops to the route in our angular routeController
		angular.element(jQuery('#routePanel')).scope().addToRouteFromExternal(recordsToAdd);
	}
	
	gp_trackRouteAddAll(recordsToAdd.length);
		
	jQuery.jGrowl(gp_translations.All_Records_were_successfully_added_to_the_Current_Route_list);
	
	return true;
}

//Accepts the routingPOIs object from map controller and adds them to the data table
function gp_addToRouteFromRPOIs(routingPOIs){
	
	if (routingPOIs != null){
		var routeStops = [];

		jQuery.each(routingPOIs, function(key, value) { 
			// change null to '' for all properties 
			jQuery.each(value, function(key, propvalue) { 
				if (propvalue == null){ value[key] = '';}
			}); 
			if (value.stopVia == '') { value.stopVia = 's'; }
			
			routeStops.push({
				id: guid(),
				source: value.source,
				sourceId: value.sourceId,
				name: value.title, 
				street: value.street,
				city: value.city,
				state: value.state,
				postalCode: value.postalCode,
				country: value.country,
				countryISO: value.countryISO,
				lat: value.lat,
				lng: value.lng,
				geocodeQuality: value.geocodeQuality,
			    typeOfRecord: 'routeStop'
			});
		}); 

		//Add stops to the route in our angular routeController
		angular.element(jQuery('#routePanel')).scope().addToRouteFromExternal(recordsToAdd);
	}
}

// Add an external POI to the route list
function gp_addToRouteExternalPOI(name,street,city,state,zip,country,lat,lng,src,srcId){
	
	var routeStop = {
		id: guid(),
		source: src,
		sourceId: srcId,
		name: name, 
		street: street,
		city: city,
		state: state,
		postalCode: zip,
		country: country,
		countryISO: country,
		lat: lat,
		lng: lng,
		geocodeQuality: 'CUSTOM',
	    typeOfRecord: 'routeStop'
	};

	//Add stops to the route in our angular routeController
	angular.element(jQuery('#routePanel')).scope().addToRouteFromExternal(routeStop);
		
	jQuery.jGrowl('<i ignore>' + gp_htmlEncode(name) + '</i> ' + gp_translations.was_succesfully_added_to_Route);
}

//Method that can be called after google script is loaded async for gp_addToRouteMyLocation() method
var gpTempLocationId;
function gp_addToRouteMyLocationAsyncScript(){
	gp_addToRouteMyLocation(gpTempLocationId);
}

function gp_addToRouteMyLocation(locationId){

	//Get the address from the location Id
	var $addressElement = jQuery(".locationAddress[data-locationAddressId='"+locationId+"']");
	var locationName = jQuery(".locationName[data-locationNameId='"+locationId+"']").text();

	//If lat/lng are present on the location, use these.
	if($addressElement.attr('data-lat') && $addressElement.attr('data-lng') ){

		//Build a route poi object 
		routePOI = {
			lat: $addressElement.attr('data-lat'),
			lng: $addressElement.attr('data-lng'),
			countryISO: $addressElement.attr('data-country'),
			title: locationName,
			street: $addressElement.attr('data-street'),
			city: $addressElement.attr('data-city'),
			state: $addressElement.attr('data-state'),
			postalCode: $addressElement.attr('data-postalcode'),
			country: $addressElement.attr('data-country'),
			geocodeQuality: 'CUSTOM',
			usesCustomerGeocode: '',
			recordId: ''
		};

		//Add the poi object to the route
		gp_addToRouteSearchOrCenterPOI(routePOI,'location');

	}else{
		
		//If the google javascript api is not loaded, load it, and call this function again after it has loaded
		if(typeof google == 'undefined'){
			//Store the argument of this method is a global var that can be used in script load call back
			gpTempLocationId = locationId;
			gp_loadGoogScript("gp_addToRouteMyLocationAsyncScript");
			return false;
		}

		//Do a geocode to get the lat lng
		
		var latlng = new google.maps.LatLng($addressElement.attr('data-lat'),$addressElement.attr('data-lng'));
		searchReq = {'address': $addressElement.text()};

		//Do a reverse geocode to get updated information and lat/lng
		var geocoder = new google.maps.Geocoder();
		geocoder.geocode( searchReq, function(results, status) {

			if (status == google.maps.GeocoderStatus.OK) {

				//Parse google geocode
				var address = gp_parseGoogleGeocode(results[0]);

				//Set the title as the location name
				address.title = locationName;
				
				//Build a route poi object
				routePOI = {
					lat: results[0].geometry.location.lat(),
					lng: results[0].geometry.location.lng(),
					countryISO: address.country,
					title: address.title,
					street: address.street,
					city: address.city,
					state: address.state,
					postalCode: address.postalCode,
					country: address.country,
					geocodeQuality: 'CUSTOM',
					usesCustomerGeocode: '',
					recordId: ''
				};

				//Add the poi object to the route
				gp_addToRouteSearchOrCenterPOI(routePOI,'location');

			} else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
				jQuery.jGrowl(gp_translations.Unable_to_locate_accurate_position_for +' '+ locationName +' '+ gp_translations.and_it_could_not_be_added_to_the_route, { life: 5000 });

			}else{
				alert(gp_translations.Unable_to_route_location);
				if(console && console.log){
					console.log(status);
				}
			}

			// called to reset the ActionFunction bug		
			gp_emptyActionFunction(); 
		});
	}
}

// Array Remove - By John Resig (MIT Licensed)
Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};

/*************************
* Share Map Functions
*************************/
function __SHARED_MAP_FUNCTIONS__(){}

function gp_clearHiddenFields(){
	// Clear the hidden data so we don't keep sending it to server
 	jQuery(gp_UIElem.hidden_routeLocXML).val('');
 	jQuery(gp_UIElem.hidden_htmlDirections).val('');
}

// Finish POI Object
function gp_finishPOIObject(iPOI){
	
	var oPOI = iPOI;
	
	// change null to '' for all properties 20ms
	for(var key in oPOI) {
	    if(oPOI[key] == null) {
	        oPOI[key] = '';
	    }
	}
	
	if(oPOI.lat == null) {
		oPOI.isBlankLat = true;
	} else {
		oPOI.isBlankLat = false;
	}
	
	if(oPOI.lng == null) {
		oPOI.isBlankLng = true;
	} else {
		oPOI.isBlankLng = false;
	}
	
	oPOI.formattedAddr = '';
		if (oPOI.street != ''){ oPOI.formattedAddr += oPOI.street + '<br/>'; }
		if (oPOI.city != ''){ oPOI.formattedAddr += oPOI.city; }
		if (oPOI.city != '' && oPOI.state != ''){ oPOI.formattedAddr += ', '; }
		if (oPOI.state != ''){ oPOI.formattedAddr += ' ' + oPOI.state; } 
		if (oPOI.postalCode != ''){ oPOI.formattedAddr += ' ' + oPOI.postalCode; }
		if (oPOI.country != ''){ oPOI.formattedAddr += '<br/>' + oPOI.country; }
	
	if (oPOI.mapIconURL == '') { oPOI.isBlankMapIconURL = true; }
	if (oPOI.mapIconWidth == '' || oPOI.mapIconHeight == ''){ oPOI.isBlankMapIconSize = true; }
	
	oPOI.distanceFromCenter = '';
	if (oPOI.distanceFromCenterRaw){
		oPOI.distanceFromCenter = '' + Math.round(oPOI.distanceFromCenterRaw*100)/100 + '';
	} 
	
	oPOI.distanceInfo = '';
	if(oPOI.distanceFromCenterRaw){
		var unitsLabel = gp_translations.Kilometers.toLowerCase();
		if(oPOI.distanceUnits == 'miles'){
			unitsLabel = gp_translations.Miles.toLowerCase();
		}

		oPOI.distanceInfo = '<br/><b>' + oPOI.distanceFromCenter + ' ' + unitsLabel + '</b>';
	}

	/*
	if (oPOI.title != '') { oPOI.title = gp_htmlEncode(oPOI.title); }
	if (oPOI.title2 != '') { oPOI.title2 = gp_htmlEncode(oPOI.title2); }
	
	oPOI.formattedAddr = '';
		if (oPOI.street != ''){ oPOI.formattedAddr += gp_htmlEncode(oPOI.street) + '<br/>'; }
		if (oPOI.city != ''){ oPOI.formattedAddr += gp_htmlEncode(oPOI.city); }
		if (oPOI.city != '' && oPOI.state != ''){ oPOI.formattedAddr += ', '; }
		if (oPOI.state != ''){ oPOI.formattedAddr += ' ' + gp_htmlEncode(oPOI.state); } 
		if (oPOI.postalCode != ''){ oPOI.formattedAddr += ' ' + gp_htmlEncode(oPOI.postalCode); }
		if (oPOI.country != ''){ oPOI.formattedAddr += '<br/>' + gp_htmlEncode(oPOI.country); }
	
	if (oPOI.mapIconURL == '') { oPOI.isBlankMapIconURL = true; }
	if (oPOI.mapIconWidth == '' || oPOI.mapIconHeight == ''){ oPOI.isBlankMapIconSize = true; }
	
	oPOI.distanceFromCenter = '';
	if (oPOI.distanceFromCenterRaw){
		oPOI.distanceFromCenter = '' + Math.round(oPOI.distanceFromCenterRaw*100)/100 + '';
	} 
	
	oPOI.distanceInfo = '';
	if(oPOI.distanceFromCenterRaw){
		oPOI.distanceInfo = '<br/><b>' + oPOI.distanceFromCenter + ' ' + gp_htmlEncode(oPOI.distanceUnits) + '</b>';
	}
	*/
	oPOI.baseInfoContentHTML = gp_buildBaseInfoContent(oPOI);
	
	return oPOI;
	
}

// Stored in Data Table for use in things like KML export
function gp_buildBaseInfoContent(thisPOI){
	
	var tmpInfoContentHTML = '';
	if(thisPOI.title2 != ''){
		tmpInfoContentHTML += '<b style="font-size: 1.1em;">' + thisPOI.title2 + '</b><br/>';
	}
	tmpInfoContentHTML += thisPOI.formattedAddr;
	if (thisPOI.distanceInfo != ''){
		tmpInfoContentHTML += thisPOI.distanceInfo;
	}
	if (thisPOI.geocodeQuality != ''){
		tmpInfoContentHTML += '<br/><b>'+gp_translations.Geocode_Quality+'</b>: ' + thisPOI.geocodeQuality;
	}
	if(typeof(thisPOI.additionalFields) != "undefined"){
		if(thisPOI.additionalFields != null){
			tmpInfoContentHTML += '<hr/>';
			jQuery.each(thisPOI.additionalFields, function(key, value) { 
				tmpInfoContentHTML += '<b>' + value.label + '</b>: ' + value.value + '<br/>';
			});
		}
	}
	
	return tmpInfoContentHTML;
}

// Perform Route Matrix Search
function gp_calcDriveTimes(tableId, units){
	
	if (typeof(gp_radialSearchCenter) == 'undefined') return;
	
	var oTable = jQuery('#' + tableId).dataTable();
	var aoData = jQuery('#' + tableId).dataTable().fnGetData();
	var gp_ColumnInfo = jQuery('#' + tableId).data('columnInfo');
	var oSettings = oTable.fnSettings();		

	if (oSettings.aiDisplay.length == 0) return;

	oTable.fnSetColumnVis(gp_ColumnInfo.distanceDrive, true );

	if (true) { // google 
		var service = new google.maps.DistanceMatrixService();
		var origin = new google.maps.LatLng(gp_radialSearchCenter.lat, gp_radialSearchCenter.lng);
		var destinations = [new google.maps.LatLng(-1, -1)];  // Use the first point to keep track of range (i.e. the first index)

		// hit the OVER_QUERY_LIMIT exception when requesting more than 94 results
		for (var i=0, maxPoints = (oSettings.aiDisplay.length > 90) ? 90 : oSettings.aiDisplay.length; i<maxPoints ; i++ ) {
			destinations.push(new google.maps.LatLng(aoData[ oSettings.aiDisplay[i] ][gp_ColumnInfo.latitude], aoData[ oSettings.aiDisplay[i] ][gp_ColumnInfo.longitude])); 

			if (i != 0 & (i % 23 == 0 || i == maxPoints-1)) {
				service.getDistanceMatrix(
					{
						origins: [origin],
						destinations: destinations,
						travelMode: google.maps.TravelMode.DRIVING,
						unitSystem: google.maps.UnitSystem.IMPERIAL,
					}, 
					function(response, status) {
						if (status == google.maps.DistanceMatrixStatus.OK) {
							var origins = response.originAddresses;
							var destinations = response.destinationAddresses;
							var firstIndex = parseInt(destinations[0].split(",")[0]);
							for (var i = 0; i < origins.length; i++) {
								var results = response.rows[i].elements;
								for (var j = 1; j < results.length; j++) {
									if (results[j].status == google.maps.DistanceMatrixStatus.OK) {
										var distance = results[j].distance.value
										if (units == "kilometers") distance = (distance/1000).toFixed(2);
										else distance = (distance*0.000621371).toFixed(2);  // distance comes back in meters.  convert to miles
										oTable.fnUpdate(distance, oSettings.aiDisplay[firstIndex+j], gp_ColumnInfo.distanceDrive, false, false);
									}
								}
							}
						} else {
							geopointeAjaxEnd();
							jQuery.jGrowl(gp_translations.There_was_an_error_processing_the_Drive_Distance_request + ': ' + status, { life: 5000 });
						}
					}
				);
				destinations = [new google.maps.LatLng(i, i)];  // Use the first point to keep track of range (i.e. the first index)
			}
		}

	}


	if (false) { // mapquest	open api
		var locJSON = '';
		
		for (var i=0, iLen=oSettings.aiDisplay.length ; i<iLen ; i++ ){
			locJSON += ',{latLng:{lat:' + aoData[ oSettings.aiDisplay[i] ][gp_ColumnInfo.latitude] + ',lng:' + aoData[ oSettings.aiDisplay[i] ][gp_ColumnInfo.longitude] +'}}';
			if (i == 59){ break; } // as of 6/11/2015, this can only support 62 results.
		}
		
		locJSON = '{latLng:{lat:' + gp_radialSearchCenter.lat + ',lng:' + gp_radialSearchCenter.lng +'}}' + locJSON;
		
		jQuery.ajax({
			url: 'https://open.mapquestapi.com/directions/v2/routematrix?key=' + gp_MQApiKey,
			dataType: 'jsonp',
			type: 'GET',
			data:	{json: '{locations:[' + locJSON + '],options:{allToAll:false}}'},
			
			success: function(data, textStatus, XMLHttpRequest){
				if(data.distance){
					for (var i=0, iLen=data.distance.length ; i<iLen ; i++ ){
						if (i>0){
							var j = data.distance[i];
							if(units == "kilometers") { j = (j * 1.609344).toFixed(2); }
							if(j > 0)
								oTable.fnUpdate(j, oSettings.aiDisplay[i-1], gp_ColumnInfo.distanceDrive, false, false);
						}
					}
					oTable.fnDraw();
				}
				
				geopointeAjaxEnd();
				
			},
			
			error: function (XMLHttpRequest, textStatus, errorThrown){
				geopointeAjaxEnd();
				jQuery.jGrowl(gp_translations.There_was_an_error_processing_the_Drive_Distance_request, { life: 5000 });
			}
			});
	}
}

//Runs a Search Nearby querying using the bounds of the map
function gp_searchNearbyRecordsInBoundsWrapper(minZoom,isRemote){
	
	geopointeAjaxStart('body',gp_translations.Loading_records_within_the_map_bounds + '...'); 

	if (gp_getZoomLevel() < minZoom){
		geopointeAjaxEnd();
		gp_alert('To perform a search you must be zoomed into at least level <var>' + minZoom + '</var>. You are currently on zoom level <var>'+ gp_getZoomLevel() + '</var>.');
		return false;
	}
	
	// Clear the hidden data so we don't keep sending it to server
	gp_clearHiddenFields();

	//Remove the center marker
	gp_removeCenterMarker();

	//Wipe out the old center point poi
	try{gp_removeCenterPOIshapes();}catch(e){} //Only google has this method
	gp_centerPOI = {};
	loadWithCenterPOI = false;
 	
	gp_trackViewableAreaSearch();
	
	var bounds = gp_getBoundsObject();
	
	if(isRemote != true){
		gp_searchNearbyRecordsInBounds(bounds.minLat,bounds.maxLat,bounds.minLng,bounds.maxLng,gp_getZoomLevel()); //actionFunction that does search
	}
	
}

//Wrapper before gp_mapRecords
function gp_mapRecordsWrapper(isRemote){
	geopointeAjaxStart('body',gp_translations.Loading_all_records_in_the_Data_Set + '...'); 
	gp_trackEntireDataSetSearch();
	gp_clearHiddenFields();

	//Remove the center marker
	gp_removeCenterMarker();

	//Wipe out the old center point poi
	try{gp_removeCenterPOIshapes();}catch(e){} //Only google has this method
	gp_centerPOI = {};
	loadWithCenterPOI = false;
	
	if(isRemote != true){
		gp_mapRecords(); //Action function that does search
	}
}

// Take user to the location selected
function gp_goToMyLocationWrapper(locationId){
	
	//Get the address from the location Id
	var $addressElement = jQuery(".locationAddress[data-locationAddressId='"+locationId+"']");

	//Build gp_addressSearch object and update the map marker 
	gp_searchAddress = {
		city: $addressElement.attr('data-city'),
		country: $addressElement.attr('data-country'),
		fullAddress: "",
		lat: Number($addressElement.attr('data-lat')),
		lng: Number($addressElement.attr('data-lng')),
		name: "",
		postalCode: $addressElement.attr('data-postalCode'),
		singleLineAddress: jQuery.trim($addressElement.text()),
		state: $addressElement.attr('data-state'),
		street: $addressElement.attr('data-street'),
		title:  jQuery(".locationName[data-locationNameId='"+locationId+"']").text()
	}

	buildMultilineAddress(gp_searchAddress);

	//Update the gp_search poi object
	gp_searchPOI = {
		lat: $addressElement.attr('data-lat'),
		lng: $addressElement.attr('data-lng'),
		countryISO: gp_searchAddress.country,
		title: gp_searchAddress.title,
		street: gp_searchAddress.street,
		city: gp_searchAddress.city,
		state: gp_searchAddress.state,
		postalCode: gp_searchAddress.postalCode,
		country: gp_searchAddress.country,
		geocodeQuality: 'CUSTOM',
		usesCustomerGeocode: '',
		recordId: ''
	};

	//If lat lng are present update the search marker
	if(gp_searchAddress.lat && gp_searchAddress.lng){ 
		gp_updateSearchMarker(gp_searchAddress,true);
	}else{
		//No lat lng on location record, need to geocode address to get lat lng, true flag means this is goto my location
		gp_addressSearch(gp_searchAddress,true);
	}

	//Since user is mapping saved location make sure search center title reflects address of location
	gp_centerPointKeepAddress = true;
}

function gp_addToMyLocationsRightClick(){

	//If the google javascript api is not loaded, load it for this search, and call this function again after it has loaded
	if(typeof google =='undefined'){
		gp_loadGoogScript('gp_addToMyLocationsRightClick');
		return false;
	}

	//Create geocode request with lat and long for reverse geocode
	var latlng = new google.maps.LatLng(rightClickLatLng.lat,rightClickLatLng.lng)

	//Do the reverse geocode 
	var geocoder = new google.maps.Geocoder();
	geocoder.geocode({'latLng': latlng}, function(results, status) {

		if (status == google.maps.GeocoderStatus.OK) {
			
			//Hide the right click context menu.
	 		jQuery("#mapContextMenu").hide();

			//Parse google geocode
			var address = gp_parseGoogleGeocode(results[0]);

			//Add to location
			gp_addToMyLocations(address);

		}else{
			alert(gp_translations.Unable_to_add_location);
			if(console && console.log){
				console.log(status);
			}
		}

		//Called to reset the ActionFunction bug		
		gp_emptyActionFunction(); 
	});

	gp_trackRightClick('Add to My Locations');
}

//Function that adds a point to My Locations
function gp_addToMyLocations(address){ //Receives a parsed google address geocode
	//Ask the user for a location name
	jQuery('<div></div>')
			.append('<p>'+gp_translations.Please_enter_a_name_for_this_Location+': <input id="newLocationName" type="text" value="'+address.name+'" size="50"/></p>')
			.dialog({
					modal: true, 
					draggable: false, 
					width: '515px', 
					title: gp_translations.Save_Location + ' - ' + address.singleLineAddress, 
					position: { my: "bottom", at: "center", of: window },
					open: function() {
				      	//Create Enter event listner
				      	jQuery('#newLocationName').keypress(function(e) {
						    if (e.keyCode == 13) {
						    	//Click the first button in this modal, which is the OK button
						    	jQuery(this).parents(".ui-dialog").find("button").first().click();
						    }
						});
				    },
					buttons: { 
						OK: function() {
								//Get name entered
								var locationName = jQuery("#newLocationName").val();

								if(locationName){
									address.name = locationName;
									
									//Convert the object to a JSON string
									var locationJSON = JSON.stringify(address);				

									//Call an actionFunction that will handle the creation of location
									gp_saveNewLocation(locationJSON);

									//Close this dialog
									jQuery( this ).remove();

									geopointeAjaxStart('body',gp_translations.Saving_Location+'...');
								}	
							}, 
						Cancel: function() {jQuery( this ).remove();} }
					});
}

// Opens a jQuery Dialog with the record's related lists
function gp_displayRelatedRecords(recordId, sfdcObject, recordTypeId){
	
	jQuery( "#relatedListsDialog" ).remove();
	var html = '';
	var relatedLists = [];
	var arrayOfRelatedListArrays = []; //contains arrays of 20 related lists each
	var results;
	var relatedListsTruncated = false;

	try{
		
		if(!gp_userSettings.apiEnabled){
			jQuery.jGrowl(gp_translations.API_Access_is_not_enabled_for_your_user_account);
			return;
		}
		
		// Describe layout
		if (typeof(gp_userSettings.layouts[sfdcObject + '_' + recordTypeId]) == "undefined"){
			var tmpDesc = sforce.connection.describeLayout(sfdcObject,[recordTypeId]);
			gp_userSettings.layouts[sfdcObject + '_' + recordTypeId] = tmpDesc.layouts;
		}
		
		//Populate array of related lists
		var tmpArray = gp_userSettings.layouts[sfdcObject + '_' + recordTypeId].getArray("relatedLists");
		for(var i = 0; i < tmpArray.length; i++){
			if(gp_userSettings.userInfo && gp_userSettings.userInfo.userLicenseName == 'Salesforce Platform'){
				if(tmpArray[i].sobject == 'OpenActivity' || tmpArray[i].sobject == 'ActivityHistory'){ continue; }
			}
			relatedLists.push(tmpArray[i]);
		}
		
		
		//List the array into smaller arrays of 20 each as we can only query 20 related lists at a time
		tmpArray = [];
		for(var i = 0; i < relatedLists.length; i++){
			tmpArray.push(relatedLists[i]);

			if(tmpArray.length == 20){
				arrayOfRelatedListArrays.push(tmpArray);
				tmpArray = [];
			}
		}
		arrayOfRelatedListArrays.push(tmpArray);

		// Generate SOQL for each set of 20 related lists
		var soqlArray = [];

		for(var i = 0; i < arrayOfRelatedListArrays.length; i++)	{

			//Get a set of 20 related lists and build the soql for this
			var rls = arrayOfRelatedListArrays[i];
             
			var soql = 'SELECT Id'; 
			jQuery.each(rls, function(key, rl) {
				var fields = [];
				soql += ', (SELECT ';
				jQuery.each(rl.getArray("columns"), function(key, value) { 
					if (key > 0){ soql+=','}
					//__c. replacement is for describe bug http://success.salesforce.com/issues_view?id=a1p30000000SYkZAAW	
					soql += value.name.replace('__c.','__r.');
				});
				if(jQuery.inArray("Id",fields)==-1){ soql += ',Id'; }
				if(rl.sobject=="AccountTeamMember"){soql += ',UserId'; }
				if(rl.sobject=="OpportunityContactRole"){soql += ',ContactId';}
				soql += ' FROM ' + rl.name;
				if(rl.sobject=="OpenActivity"){soql += ' ORDER BY ActivityDate ASC, LastModifiedDate DESC'; }
				else if(rl.sobject=="ActivityHistory"){soql += ' ORDER BY ActivityDate DESC, LastModifiedDate DESC'; }
				else {
					jQuery.each(rl.getArray("sort"), function(key, value) { 
						if(key == 0){ soql += ' ORDER BY '; }
						if(key > 0){ soql += ','; }
						soql += value.column;
						if(value.ascending=="true"){ soql+=' ASC'; } else { soql+=' DESC'};
					});
				}
				soql += ' LIMIT 11)';
			});
			soql += ' FROM ' + sfdcObject + ' WHERE Id =\'' + recordId + '\' LIMIT 1';
			
			soqlArray.push(soql);
		}

		// Tab markup
		if (arrayOfRelatedListArrays.length == 0){
			html += gp_translations.This_record_has_no_related_data_on_its_Page_Layout;
		} else {
			
			//Query the related lists
			for(var i = 0; i < soqlArray.length; i++){
				if(!results){
					//First query
					results = sforce.connection.query(soqlArray[i]);
				}else{
					//Subsequent queries, add results to original result object
					var res = sforce.connection.query(soqlArray[i]);
					jQuery.extend(results.records,res.records);
				}
			}
			
			var lis=''; 
			var divs='';
			html +='<div id="relatedListsTabs" style="display: none; font-size: 9pt; font-family: Arial;"><ul notranslate>';
			for(var i = 0; i < relatedLists.length; i++){
				lis +='<li><a href="#relatedListsTabs-' + (i+1) + '">' + gp_cleanStringForHTML(relatedLists[i].label) + '</a></li>';
				divs +='<div id="relatedListsTabs-' + (i+1) + '"></div>';
			}
			html += lis;
			html += '</ul>';
			html += divs;
			html += '</div>';
		}
				
	} catch (e) {
		html = '<p>'+gp_translations.There_was_an_error_processing_your_request_If_this_issue+' <a href="mailto:support@arrowpointe.com">support@arrowpointe.com</a>.</p>';
		
		if(console && console.log){
			console.log(e.message);
		}

		//html += '<p>' + e.detail.UnexpectedErrorFault.exceptionCode + '<p>';
	}
	
	
	jQuery('<div id="relatedListsDialog" class="pbBody"></div>')
	.append(html)
	.append('<p style="margin: 10px; font-size: .9em;" >' + 
			'<img src="' + gpImg.link_newwindow + '"/>' + 
			'&nbsp;<a href="/' + recordId + '" target="_blank" style="cursor:pointer; text-decoration:underline;">'+gp_translations.Go_to_Parent_Record+'</a>' + 
			'</p>')
	.append('<p style="margin: 0 10px; font-size: .8em; font-style: italic;" >'+gp_translations.The_tabs_and_fields_shown_here_are_driven_by_the_configuration+'</p>')
	.dialog({
			modal: true, 
			draggable: true, 
			width: '1000px', 
			position:['middle',125],
			title: 'Related Data', 
			buttons: { 
				Close: function() { 
					jQuery( this ).dialog( "close" );
				} 
			},
			open: function(event, ui) {
				jQuery( "#relatedListsTabs" ).tabs({
													selected: 0,
													show: function(event, ui) {
														if(jQuery(ui.panel).html() == ''){
															
															try{
																var rl = relatedLists[ui.index];

																var html = '';
																var noResultsText = gp_translations.No_records_were_found;
																var records = [];
																var labels = [];
																var fields = [];
																var formats = [];

																jQuery.each(rl.getArray("columns"), function(key, value) { 
																	labels.push(value.label);
																	fields.push(value.name);
																	formats.push(value.format);
																});

																if(results.records[rl.name] != null){
																	records = results.records[rl.name].getArray("records");
																}

																html += '<table width="100%" class="list display"><thead><tr class="headerRow">';
																jQuery.each(labels, function(key, value) { 
																	html += '<th class="dataCell"><b>' + gp_cleanStringForHTML(value) + '</b></th>';
																});
																html += '</tr></thead><tbody>';

																if (records.length > 0){
																	jQuery.each(records, function(key, value) {
																		html += '<tr class="dataRow">';
																		jQuery.each(fields, function(key2, value2) {
																			//__c. replacement is for describe bug http://success.salesforce.com/issues_view?id=a1p30000000SYkZAAW
																			value2 = value2.replace("toLabel","").replace("convertCurrency","").replace("(","").replace(")","").replace('__c.','__r.');
																			try{
																				var linkKey=0;
																				var linkVal=value.Id;
																				if(rl.sobject=="NoteAndAttachment"){linkKey=1;}
																				if(rl.sobject=="AccountTeamMember"){linkVal=value.UserId;}
																				if(rl.sobject=="OpportunityContactRole"){linkVal=value.ContactId;}
																				if(rl.sobject=="OpportunityCompetitor" 
																					|| rl.name.indexOf('Histories') != -1 
																					|| rl.sobject=="EmailStatus" 
																					|| rl.sobject=="ProcessInstanceHistory" 
																					){ linkKey=1000; }
																				if(rl.sobject=="ActivityHistory"){linkKey=0;}
																				var tmp = '<td class="dataCell">';
																				if(eval("value." + value2) == null){
																					tmp += '&nbsp;';
																				} else {
																					if (key2 == linkKey){ tmp += '<a href="/' + linkVal + '" target="_blank" style="cursor:pointer; text-decoration:underline;">'; }
																					tmp += gp_displayRelatedRecordsValue(gp_cleanStringForHTML(eval("value." + value2)), formats[key2]);
																					if (key2 == linkKey){ tmp += '</a>'; }
																				}
																				tmp += '</td>';
																				html += tmp;
																			} catch(e) { html += '<td class="dataCell">&nbsp;</td>'; }
																		});
																		html += '</tr>';
																	});
																} else {
																	html += '<tr><td colspan="' + labels.length + '">' + noResultsText + '</td></tr>';
																}
																html += '</tbody></table>';
																if (records.length > 10){
																	html += '<p>'+gp_translations.There_are_more_related_records_than_displayed_here+'<br/><br/><a href="/' + recordId + '" target="_blank">View Parent Record</a></p>';
																}
																jQuery(ui.panel).html(html);
															} catch (e) {
																jQuery(ui.panel).html('<p>'+gp_translations.Error_loading_related_data+'</p>');
															}
														}
													}
				});
				jQuery( "#relatedListsTabs" ).show();
			}
	});
	
}

function gp_displayRelatedRecordsValue(val, format){
	if(val.indexOf('http') == 0 || val.indexOf('https') == 0){//Starts with http/s
		return '<a href="'+val+'" target="_blank">'+val+'</a>';
	}
	if(val.startsWith('&lt;')){
		return jQuery('<span>').html(val).text();
	}
	if(val == "true"){ return "<img src=\'" + gpImg.checkbox_checked + "\' alt=\'true\' />"; }
	if(val == "false"){ return "<img src=\'" + gpImg.checkbox_unchecked + "\' alt=\'false\' />"; }
	if(format == "date"){ return sforce.internal.stringToDate(val).toDateString(); }
	if(format == "datetime"){ return sforce.internal.stringToDateTime(val).toDateString() + " " + sforce.internal.stringToDateTime(val).toLocaleTimeString(); }
	return val;
}

//Search wrapper function
function gp_search(){
	//Determine the search type and execute the proper search method
	var searchType = jQuery('input:radio[name=searchType]:checked').val();

	if(searchType == 'places'){
		gp_placesSearch();
	}else if(searchType == 'address'){
		gp_addressSearch( {street: jQuery('#gp_placesSearchString').val().trim()} );
	}
}

//Vars and function to rerun gp_addressSearch after google api is loaded on the page
var gp_addressTemp;
var gp_isGotoMyLocationTemp;

function gp_addressSearchAsync(){
	gp_addressSearch(gp_addressTemp,gp_isGotoMyLocationTemp)
}

//Do an address search and and update the center context, this is also called from Go To saved location
function gp_addressSearch(address,isGotoMyLocation){

	//If the google javascript api is not loaded, load it, and call this function again after it has loaded
	if(typeof google == 'undefined'){
		//Store the argument of this method is a global var that can be used in script load call back
		gp_addressTemp = address;
		gp_isGotoMyLocationTemp = isGotoMyLocation;
		gp_loadGoogScript("gp_addressSearchAsync");
		return false;
	}
	
	//Get the map bounds
	var mapBounds = gp_getBoundsObject();

	//Bias the viewable area
	var neLatLng = new google.maps.LatLng(mapBounds.maxLat,mapBounds.maxLng);
	var swLatLng = new google.maps.LatLng(mapBounds.minLat,mapBounds.minLng);
	var searchBounds = new google.maps.LatLngBounds(swLatLng,neLatLng);

	//Create the search request
	var searchReq = {
		address: address.street,
		bounds: searchBounds
	};

	//If goto my location use the single line address
	if(isGotoMyLocation){
		searchReq.address = address.singleLineAddress;
	}

	var geocoder = new google.maps.Geocoder();
	geocoder.geocode( searchReq, function(results, status) {

		if (status == google.maps.GeocoderStatus.OK) {

			//Parse google geocode and store result in var, store in case user wants to add to their saved locations
			
			if(isGotoMyLocation){
				//Only update the lat lng on gp_searchAddress object as this was already created in gp_GotoMyLocatoin and we just need the lat lng
				gp_searchAddress.lat = results[0].geometry.location.lat();
				gp_searchAddress.lng = results[0].geometry.location.lng();

				//Update lat lng on gp_searchPOI
				gp_searchPOI.lat = results[0].geometry.location.lat();
				gp_searchPOI.lng = results[0].geometry.location.lng();

				//Update the center location 
				gp_updateSearchMarker(gp_searchAddress,isGotoMyLocation);

				//Set gp_centerPointKeepAddress to true
				gp_centerPointKeepAddress = true;

			}else{ //Normal address search
				
				//Update gp_searchAddress object with geocode response
				gp_searchAddress = gp_parseGoogleGeocode(results[0]);

				//Update the gp_search poi object
				gp_searchPOI = {
					lat: results[0].geometry.location.lat(),
					lng: results[0].geometry.location.lng(),
					countryISO: gp_searchAddress.country,
					title: gp_searchAddress.title,
					street: gp_searchAddress.street,
					city: gp_searchAddress.city,
					state: gp_searchAddress.state,
					postalCode: gp_searchAddress.postalCode,
					country: gp_searchAddress.country,
					geocodeQuality: 'CUSTOM',
					usesCustomerGeocode: '',
					recordId: ''
				};

				gp_centerPointKeepAddress = true;
				gp_searchAddress.keepAddress = true;

				//Update the center location 
				gp_updateSearchMarker(gp_searchAddress,isGotoMyLocation);
				
			}

		} else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
			jQuery.jGrowl(gp_translations.No_results_found_for +' "'+ address.street +'".', { life: 5000 });

		}else{
			alert(gp_translations.Unable_to_search_locations);
			if(console && console.log){
				console.log(status);
			}
		}

		//Track the search in mixpanel
		if(isGotoMyLocation != true){
			gp_trackSearch(address.street,'Address');
		}
		
		// called to reset the ActionFunction bug		
		gp_emptyActionFunction(); 
	});

}

function gp_parseGoogleGeocode(geocode){
	//Parse the response into name, street, city, state/prove, postal code, country, 
	var address = {name: '', title: '', street: '',city: '',state: '', postalCode: '', country: '', lat: '', lng: '', fullAddress: '', singleLineAddress: ''};

	address.lat = geocode.geometry.location.lat();
	address.lng = geocode.geometry.location.lng();
	address.singleLineAddress = geocode.formatted_address;

	for(var i = 0; i < geocode.address_components.length; i++){

		var addressType = geocode.address_components[i].types[0];
		var shortName = geocode.address_components[i].short_name;
		
		if(!addressType){
			address.name = shortName;
		}else if(addressType == 'street_number'){
			address.street = shortName;
		}else if(addressType == 'route'){	
			address.street += ' ' + shortName
		}else if(addressType == 'locality'){ //City
			address.city = shortName;
		}else if(addressType == 'administrative_area_level_1'){ //State/Prov
			address.state = shortName;
		}else if(addressType == 'country'){
			address.country = shortName;
		}else if(addressType == 'postal_code'){
			address.postalCode = shortName;
		}
	}

	//Set the title field for route if address returned a name use that, otherwise use street address
	if(!geocode.address_components[0].types[0]){
		address.title = geocode.address_components[0].short_name;
	}else if(address.street){ //Use street address
		address.title = address.street;
	}

	//Buld multiline full address
	buildMultilineAddress(address);
	
	return address;
}

function gp_parseMQGeocode(geocode){

	//Parse the response into name, street, city, state/prove, postal code, country, 
	var address = {name: '', title: '', street: '',city: '',state: '', postalCode: '', country: '', lat: '', lng: '', fullAddress: '', singleLineAddress: ''};

	address.lat = geocode.displayLatLng.lat;
	address.lng = geocode.displayLatLng.lng;
	address.name = address.street;
	address.street = geocode.street;
	address.city = geocode.adminArea5;
	address.state = geocode.adminArea3;
	address.postalCode = geocode.postalCode;
	address.country = geocode.adminArea1;
	address.title = address.street;
	
	//Buld multiline full address
	buildMultilineAddress(address);

	//Set single line address
	address.singleLineAddress = address.fullAddress.split('<br/>').join(', ');
	
	return address;
}

//Receives and address object and constructs full address property 
function buildMultilineAddress(address){
	address.fullAddress = '';

	if(address.street){
		if(address.fullAddress.length > 0)  address.fullAddress += '<br/>';
		address.fullAddress += address.street;
	}
	if(address.city && address.state){
		if(address.fullAddress.length > 0)  address.fullAddress += '<br/>';
		address.fullAddress += address.city + ', ' + address.state;	
	}else if(address.city){
		if(address.fullAddress.length > 0)  address.fullAddress += '<br/>';
		address.fullAddress += address.city
	}
	if(address.postalCode){
		address.fullAddress += ' '+address.postalCode;
	}
	if(address.country){
		if(address.fullAddress.length > 0)  address.fullAddress += '<br/>';
		address.fullAddress += address.country;
	}
}

// Starting method for performing a Places search
function gp_placesSearch(){
	
	var s = jQuery('#gp_placesSearchString').val().trim();
	if (s == ''){ return; }
	
	geopointeAjaxStart('body',gp_translations.Searching + '...');
	
	var center = gp_getCenterObject();
	var bounds = gp_getBoundsObject();
	var zoom = gp_getZoomLevel();
	jQuery.ajax({
		url: 'https://places.nlp.nokia.com/places/v1/discover/search',
		dataType: 'jsonp',
		type: 'GET',
		crossDomain: true,
		headers: {
				"X-Map-Viewport": bounds.minLng + ',' + bounds.minLat + ',' + bounds.maxLng + ',' + bounds.minLat + ',' + zoom,
				"X-Mobility-Mode": 'none'
				},
		data:{
			q: s,
			at: center.lat + ',' + center.lng + ';cgen=map;u=0',
			size: 30,
			app_id:'AGXMHzsI27SaMzy5UMMI',
			app_code:'8TMwIEvWot3yW5Es-cZ5bg'
			},
		
		// on success
		success: function(data, textStatus, XMLHttpRequest){
			gp_addPlaces(data);
			geopointeAjaxEnd();
			gp_trackSearch(s,'Places');
			gp_emptyActionFunction(); // called to reset the ActionFunction bug
		},
		
		// on failure
		error: function (XMLHttpRequest, textStatus, errorThrown){
			geopointeAjaxEnd();
			jQuery.jGrowl(gp_translations.There_was_an_error_processing_your_request, { life: 5000 });
		}
	});
	
}

// Accepts a Places result and returns the HTML for an Info Bubble
function gp_buildPlacesInfoContent(data,srcObject){

	var html = 	'<div style="font-size: 8pt;">' + 
				'<div style="font-size: 9pt;"><b>' + data.name + '</b></div>';
	
	if(typeof(data.location)!="undefined"){
		if(typeof(data.location.address)!="undefined"){
			html+='<div>'+data.location.address.text+'</div><hr/>';
		}
	}
	if(typeof(data.contacts)!="undefined"){
		jQuery.each(data.contacts, function(key, obj) {
			jQuery.each(obj, function(key2, val) {
				if(key=="website"){
					html += '<div style="margin-top:3px;"><b>' + val.label + '</b>: <a href="' + val.value + '" target="_blank">' + val.value + '</a></div>';
				} else {
					html += '<div style="margin-top:3px;"><b>' + val.label + '</b>: ' + val.value + '</div>';
				}
			});
		});
	}
	if(typeof(data.extended)!="undefined"){
		jQuery.each(data.extended, function(key, val) {
			html += '<div style="margin-top:3px;"><b>' + val.label + '</b>: ' + val.text + '</div>';
		});
	}
	if(typeof(data.categories)!="undefined"){
		html+='<div style="margin-top:15px;">';
		jQuery.each(data.categories, function(key, cat) { 
			html+='<div><em>' + cat.title + '</em></div>';
		});
		html+='</div>';
	}
	
	if(srcObject.gp_placeSponsored){
		html+='<div style="margin-top:10px;"><b>*** '+gp_translations.Sponsored_Result+' ***</b></div>';
	}
	
	if(typeof(data.attribution)!="undefined"){
		html+='<div style="margin-top:10px;">' + data.attribution + '</div>';
	}
	
	html+='<div style="margin-top:8px;">';
	html+='<input class="btn" onclick="gp_zoomToStreet(' + srcObject.gp_placeLat + ',' + srcObject.gp_placeLng + ',16);" value="'+gp_translations.Zoom_and_Center+'" type="button" />';
	
	if(typeof(data.location)!="undefined"){
		if(typeof(data.location.address)!="undefined"){
			html+='<input class="btn" onclick="gp_addToRouteExternalPOI(\'' + gp_cleanStringForJSINHTML(data.name) + '\',\'' + gp_cleanStringForHTML(data.location.address.street) + '\',\'' + gp_cleanStringForHTML(data.location.address.city) + '\',\'' + gp_cleanStringForHTML(data.location.address.state) + '\',\'' + gp_cleanStringForHTML(data.location.address.zip) + '\',\'' + gp_cleanStringForHTML(data.location.address.country) + '\',' + srcObject.gp_placeLat + ',' + srcObject.gp_placeLng + ',\'nokiaplaces\',\'' + data.view + '\');" value="'+gp_translations.Add_to_Route+'" type="button" />';
		}
	}
	
	if (eval('gp_orgSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Mapping_Provider__c') == "Google"){
		html+='<input class="btn" onclick="gp_enableStreetView(' + srcObject.gp_placeLat + ',' + srcObject.gp_placeLng + ')" value="'+gp_translations.Street_View+'" type="button" />';
	}
	
	if(typeof(data.view)!="undefined"){
		html+='<a href="' + data.view + '" target="_blank" style="text-decoration:none;"><input class="btn" value="'+gp_translations.View_Details+'" type="button" /></a>';
	}
	html+='</div>';
	
	html+='</div>';
	
	return html;
}

// True/false whether the lat/lon passed in is within the bounds of the map
function gp_latLngInBounds(lat,lng){
	
	var bounds = gp_getBoundsObject();
	
	if(lat < bounds.minLat) { return false; }
	if(lat > bounds.maxLat) { return false; }
	
	if (bounds.minLng <= bounds.maxLng){
		if(lng < bounds.minLng) { return false; }
		if(lng > bounds.maxLng) { return false; }
	} else {
		if (lng > bounds.maxLng && lng < bounds.minLng) { return false; }
	}
	
	return true;
}


// Initializes a color picker
function gp_initColorPicker(id,type){
	jQuery(type + '[id*="' + id + '"]').minicolors({
		defaultValue: '#1797C0',
		letterCase: 'uppercase',
		theme: 'geopointe',
		changeDelay: 200,
		change: function(hex, opacity) {
			        //Special handling for map page to keep the two color inputs in sync
			        if(jQuery(this).attr('id') == 'editDataSetColor'){
						jQuery("input[id$='gp_selectedcolor']").minicolors('destroy').attr('maxlength',7);
						jQuery("input[id$='gp_selectedcolor']").val( jQuery('#editDataSetColor').val() );	
						gp_initColorPicker('gp_selectedcolor','input');
					}else{
						jQuery('#editDataSetColor').minicolors('destroy').attr('maxlength',7);
						jQuery('#editDataSetColor').val(jQuery("input[id$='gp_selectedcolor']").val() );
						gp_initColorPicker('editDataSetColor','input');
					}
			    }
	});
}

//Function called to reset certain variables whenever a user many adjusts the position of the map
function gp_mapManualMove(){
	//gp_centerPointKeepAddress = false;
}

/*************************
* MixPanel
*************************/
function __MIXPANEL_FUNCTIONS__(){}

function gp_trackMapLoad(){
	gp_track('Map Loaded', {"URL":window.location.href});
}
function gp_trackDemographics(ds,m){
	gp_track('Demographics', { "Data Source": ds,
								"Metric": m
								});
}
function gp_trackSearch(searchValue,type){ 
	gp_track('Places Search', { "Search Term": searchValue,
						 "Restrict to Map Area": jQuery('#gp_placesRestrictSearchArea').is(':checked'),
						 "Search Type": type
						});
}
function gp_trackLayerToggle(ltype,onoff){ 
	gp_track('Layer', {	"Layer Type": ltype, 
						"Layer Status": onoff 
						});
}
function gp_trackRoute(route){ 
	gp_track('Route', {
						"Route Type": route.type,
						"Route Stops": route.routeStops.length,
						"Route Optimize": route.optimize,
						"Route Units": route.units,
						"Status": route.status
						});
}
function gp_trackRouteAddAll(dlen){
	gp_track('Add All To Route', {"Stops Added": dlen, "Selection": jQuery("#applyActionTo").val() });
}
function gp_trackRouteMQ(){ 
	gp_track('Route @ MQ', null);
}
function gp_trackRouteGOOG(){ 
	gp_track('Route @ GOOG', null);
}
function gp_trackRoutePDF(){ 
	gp_track('Route PDF', null);
}
function gp_trackRouteSaved(){
	gp_track('Route Saved', null);
}
function gp_trackRouteDeleted(){
	gp_track('Route Deleted', null);
}
function gp_trackRightClick(action){
	gp_track('Right Click', {'Action': action});
}

//Export tracking not currently used, weird visualforce issues with actionFunction
function gp_trackExportCSV(){
	gp_track('Export CSV', {"Selection": jQuery("#applyActionTo").val()});
}
function gp_trackExportKML(){
	gp_track('Export KML', {"Selection": jQuery("#applyActionTo").val()});
}
function gp_trackChangeOwner(){
	gp_track('Change Owner', {"Selection": jQuery("#applyActionTo").val() });
}
function gp_trackAddToCampaign(){
	gp_track('Change Owner', {"Selection": jQuery("#applyActionTo").val() });
}

function gp_trackEntireDataSetSearch(){ 
	var obj = 'Unknown';
	
	var dataSet = angular.element('.dataSetController').scope().selectedDataSet;
	if (dataSet && dataSet.mapObjectName){
		obj = dataSet.mapObjectName
	} 
	gp_track('Map Search', {
							"Search Type": 'Entire Data Set',
							"Map Object": obj,
							"Color Markers": jQuery("#gp_ColorMarkersBy").val() != '',
							"Clear Existing": jQuery("input[id$='clearExisting']").prop('checked'),
							//"Override Color": gp_isColorOverride(),
							"Number of Filters": jQuery(".dataFilterTable tbody tr").length,
							"Number of Fields": jQuery("#dataSetFieldList li").length,
							"Number of Open Searches": jQuery(".dataSetResultTableTab").length,
							"Chart Visible": jQuery(".chartPanel").is(":visible"),
							"Number Map Pins": jQuery("#mySettingsNumberPins").is(':checked'),
							"Has URL Filters": (getURLparams().ff1) ? true : false
							});
}
function gp_trackViewableAreaSearch(){ 
	var obj = 'Unknown';
	
	var dataSet = angular.element('.dataSetController').scope().selectedDataSet;
	if (dataSet && dataSet.mapObjectName){
		obj = dataSet.mapObjectName
	} 
	gp_track('Map Search', {
							"Search Type": 'Viewable Area',
							"Map Object": obj,
							"Color Markers": jQuery("#gp_ColorMarkersBy").val() != '',
							"Clear Existing": jQuery("input[id$='clearExisting']").prop('checked'),
							//"Override Color": gp_isColorOverride(),
							"Zoom Level": gp_getZoomLevel(),
							"Number of Filters": jQuery(".dataFilterTable tbody tr").length,
							"Number of Fields": jQuery("#dataSetFieldList li").length,
							"Number of Open Searches": jQuery(".dataSetResultTableTab").length,
							"Chart Visible": jQuery(".chartPanel").is(":visible"),
							"Number Map Pins": jQuery("#mySettingsNumberPins").is(':checked'),
							"Has URL Filters": (getURLparams().ff1) ? true : false
							});
}
function gp_trackRadialSearch(){ 
	var obj = 'Unknown';
	
	var dataSet = angular.element('.dataSetController').scope().selectedDataSet;
	if (dataSet && dataSet.mapObjectName){
		obj = dataSet.mapObjectName
	} 
	gp_track('Map Search', {
							"Search Type": 'Radial',
							"Map Object": obj,
							"Color Markers": jQuery("#gp_ColorMarkersBy").val() != '',
							"Clear Existing": jQuery("input[id$='clearExisting']").prop('checked'),
							//"Override Color": gp_isColorOverride(),
							"Range": jQuery("input[id$='radialSearchRange']").val(),
							"Units": jQuery("select[id$='radialSearchUnit']").val(),
							"Show Radius": jQuery("input[id$='radialSearchShowRadius']").prop('checked'),
							"Calc Drive Distance": jQuery("input[id$='radialSearchCalcDriveDistance']").prop('checked'),
							"Number of Filters": jQuery(".dataFilterTable tbody tr").length,
							"Number of Fields": jQuery("#dataSetFieldList li").length,
							"Number of Open Searches": jQuery(".dataSetResultTableTab").length,
							"Chart Visible": jQuery(".chartPanel").is(":visible"),
							"Number Map Pins": jQuery("#mySettingsNumberPins").is(':checked'),
							"Has URL Filters": (getURLparams().ff1) ? true : false
							});
}

function gp_trackShapeSearch(){ 
	var obj = 'Unknown';
	
	var dataSet = angular.element('.dataSetController').scope().selectedDataSet;
	if (dataSet && dataSet.mapObjectName){
		obj = dataSet.mapObjectName
	} 

	//Get the number of shapes on the map
	var shapeCount = 0;
	for(key in polygonObjects){
		shapeCount++;
	}

	gp_track('Map Search', {
							"Search Type": 'Shape',
							"Map Object": obj,
							"Color Markers": jQuery("#gp_ColorMarkersBy").val() != '',
							"Clear Existing": jQuery("input[id$='clearExisting']").prop('checked'),
							//"Override Color": gp_isColorOverride(),
							"Number of Filters": jQuery(".dataFilterTable tbody tr").length,
							"Number of Fields": jQuery("#dataSetFieldList li").length,
							"Shape Count": shapeCount,
							"Number of Open Searches": jQuery(".dataSetResultTableTab").length,
							"Chart Visible": jQuery(".chartPanel").is(":visible"),
							"Number Map Pins": jQuery("#mySettingsNumberPins").is(':checked'),
							"Has URL Filters": (getURLparams().ff1) ? true : false
							});
}

function gp_trackVisualizeLoad(data){
	gp_track('Visualize Loaded', data);
}
function gp_trackLaunchSK(source,type){
	gp_track('Launch Spatial Key', {'Source':source,'Type': type});
}
function gp_trackDeleteSKDataSet(source,type){
	gp_track('Delete SpatialKey Data Set', {});
}
function gp_trackDeleteSKReport(source,type){
	gp_track('Delete SpatialKey Report', {});
}

function gp_trackGoogleViz(){ 
	var obj = 'Unknown';
	if (typeof(gp_dataSetInfo[jQuery(gp_UIElem.googViz_DataSet).val()]) != "undefined"){obj = gp_dataSetInfo[jQuery(gp_UIElem.googViz_DataSet).val()].mapObjectName;}
	var sumBy = 'Unknown';
	if(jQuery(gp_UIElem.googViz_SumBy)!= null) { sumBy = jQuery(gp_UIElem.googViz_SumBy).val(); }
	
	gp_track('Google Visualization', {	"Map Object": obj,
										"Summarize By": sumBy,
										"Region": jQuery(gp_UIElem.googViz_Region).val(),
										"Show Data Table": jQuery(gp_UIElem.googViz_showData).is(':checked')
									});
}
function gp_track(evt, eventData){
	
	if(typeof(evt)=="undefined"){return;}
	if(typeof(gp_userSettings)=="undefined"){return;}
	if(typeof(gp_userSettings.userInfo)=="undefined"){return;}
	if(typeof(gp_userSettings.settings__c)=="undefined"){return;}
	if(typeof(gp_orgSettings)=="undefined"){return;}
	if(typeof(gp_orgSettings.settings__c)=="undefined"){return;}
	if(jQuery.trim(evt)==""){return;}

	//Stop if mixpanel object is not defined, some browser extensions will block it
	if(!mixpanel){return;}

	var userAgent = 'Unknown';
	if(navigator){
		userAgent = navigator.userAgent;
	}

	var obj = {
		"$bucket": gp_userSettings.userInfo.orgId,
		"Org Id": gp_userSettings.userInfo.orgId, 
		"Org Name": eval('gp_orgSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Organization_Name__c'),
		"User Name": gp_userSettings.userInfo.userFullName,
		"User Id": gp_userSettings.userInfo.userId,
		"Username": gp_userSettings.userInfo.userName,
		"Email": gp_userSettings.userInfo.email,
		"Map Provider": eval('gp_orgSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'Mapping_Provider__c'),
		"License Status": eval('gp_orgSettings.settings__c.' + gp_orgSettings.fieldPrefix + 'License_Status__c'),
		"Environment": gp_orgSettings.environment,
		"Version": gp_orgSettings.version,
		"Client": 'Web',
		"User Agent": userAgent
	};	

	var peopleData = {
		"User Type": gp_userSettings.userInfo.userType,
		"Language": gp_userSettings.userInfo.language,
		"Number Map Pins": jQuery("#mySettingsNumberPins").is(':checked'),
		"Close Tabs on Search": jQuery("#mySettingsCloseTabsOnSearch").is(':checked'),
		"Start Tab": jQuery("#mySettingsStartTab").val(),
		"Map Height": jQuery("#mySettingsMapHeight").val(),
		"SK Org ID":  gp_orgSettings.settings__c[gp_orgSettings.fieldPrefix + 'SK_Organization_Id__c__c'], 
		"Tier":  gp_userSettings.settings__c[gp_orgSettings.fieldPrefix + 'SK_User_Tier__c'],
		"Can Push Org Wide Data Sets":  gp_userSettings.settings__c[gp_orgSettings.fieldPrefix + 'SK_Push_Org_Data_Sets__c']
	};
	jQuery.extend(peopleData,obj); 

	if(eventData != null){
		jQuery.extend(eventData,obj); 
	} else {
		eventData = obj;
	}

	
	if(typeof mixpanel != 'undefined'){
		if(!gp_orgSettings.managed){
			
			mixpanel.dev.identify(gp_userSettings.userInfo.userId);
			mixpanel.dev.name_tag(gp_userSettings.userInfo.userFullName + ' (' + eval("gp_orgSettings.settings__c." + gp_orgSettings.fieldPrefix + "Organization_Name__c") + ')');
			
			mixpanel.dev.people.set("$first_name", gp_userSettings.userInfo.userFirstName);
			mixpanel.dev.people.set("$last_name", gp_userSettings.userInfo.userLastName);
			mixpanel.dev.people.set("$username", gp_userSettings.userInfo.userName);
			mixpanel.dev.people.set("$last_login", new Date());
			mixpanel.dev.people.set("$created", new Date(gp_userSettings.settings__c.CreatedDate));
			mixpanel.dev.people.set(peopleData);
			try{ mixpanel.dev.people.identify(gp_userSettings.userInfo.userId); } catch (e) {}
			try{ mixpanel.dev.track(jQuery.trim(evt),eventData); } catch (e) {}
			
		} else {
		
			mixpanel.identify(gp_userSettings.userInfo.userId);
			mixpanel.name_tag(gp_userSettings.userInfo.userFullName + ' (' + eval("gp_orgSettings.settings__c." + gp_orgSettings.fieldPrefix + "Organization_Name__c") + ')');
			
			mixpanel.people.set("$first_name", gp_userSettings.userInfo.userFirstName);
			mixpanel.people.set("$last_name", gp_userSettings.userInfo.userLastName);
			mixpanel.people.set("$username", gp_userSettings.userInfo.userName);
			mixpanel.people.set("$last_login", new Date());
			mixpanel.people.set("$created", new Date(gp_userSettings.settings__c.CreatedDate));
			mixpanel.people.set(peopleData);
			try{ mixpanel.people.identify(gp_userSettings.userInfo.userId); } catch (e) {}
			try{ mixpanel.track( jQuery.trim(evt),eventData); } catch (e) {}
			
		}
	}
			
	
}

/*************************
* DOM functions
*************************/
function __UTIL_FUNCTIONS__(){}
if (typeof String.prototype.startsWith !== 'function') {
	String.prototype.startsWith = function(prefix) {
	    return this.indexOf(prefix) === 0;
	};
}
if (typeof String.prototype.endsWith !== 'function') {
    String.prototype.endsWith = function(suffix) {
        return this.indexOf(suffix, this.length - suffix.length) !== -1;
    };
}

Object.getSize = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

function gp_milesToMeters(miles){ return miles * 1.609 * 1000; }
function gp_kmToMeters(km){ return km * 1000; }

function gp_addCommasToNumber(nStr){
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}

// Encode and Decode HTML functions TODO perf, really slow
function gp_htmlEncode(value){ 
	return jQuery('<div/>').text(gp_htmlDecode(value)).html(); 
}
function gp_htmlDecode(value){ 
	return jQuery('<div/>').html(value).text(); 
}

function gp_cleanStringForJSON(str){
	if(typeof(str)=="undefined"){ return ''; }
	var retVal = str + '';
	return retVal
			.replace(/\\/gi, "")
			.replace(/"/gi, "\\\"")
			.replace(/\n/gi, " ")
			.replace(/\r/gi, " ");
}
function gp_cleanStringForXML(str){
	if(typeof(str)=="undefined"){ return ''; }
	var retVal = str + '';
	
	//Replace &amp; with 'and' first and then replace '&' with and
	retVal = retVal.replace(/&/gi, "&amp;");

	return retVal;
}
function gp_cleanStringForHTML(str) {
	if(typeof(str)=="undefined"){ return ''; }
	var retVal = str + '';
	return retVal
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/"/g, "&quot;")
		.replace(/'/g, "&#039;");
}
function gp_cleanStringForJSINHTML(str) {
	if(typeof(str)=="undefined"){ return ''; }
	var retVal = str + '';
	return retVal
		.replace(/'/g, "\\'")
		.replace(/"/g, '\\"');
}
function gp_cleanNewLines(str){
	if(typeof(str)=="undefined"){ return ''; }
	var retVal = str + '';
	return retVal.replace(/\n/gi, " ").replace(/\r/gi, " ");
}
// Presses the button passed into the function when the enter key is pressed
function gp_DoClick(event, buttonName) {

	event = event || window.event;
	if (event.keyCode == 13 || event.which == 13) {
		
		var btn = document.getElementById(buttonName);
            if (btn != null) {
				btn.click();
				gp_stopSubmit = true; // stop the submit action from taking place
            }

		return false;
	}
	return true;
}

//Clear a select element of its options
function gp_clearlistbox(lb){
	for (var i=lb.options.length-1; i>=0; i--){
		lb.options[i] = null;
	}
	
	lb.selectedIndex = -1;
}

// Sort a select element by label
function gp_sortlistbox(selElem, starterOption) {
    
    //Do not proceed if there is no select element to process
	if(!selElem) return false;

	var buildingGroup = false; // indicator to know if we are building a group
    var tmpAry = new Array(); // init an array
    var theOptGroups = new Array(); // init an array
    var j = 0;
    
    for (var i=0;i<selElem.options.length;i++) {
    
    	// Close out an existing grouping since we found the next one
    	if (buildingGroup && selElem.options[i].disabled){ 
    		buildingGroup = false; // set back to false
    		tmpAry.sort(); // sort array and put it away
    		theOptGroup.sortedOptions = tmpAry;
    		theOptGroups.push(theOptGroup);
    	}
    	
    	// Setup a new grouping
    	if (selElem.options[i].disabled){ 
    		buildingGroup = true;
    		tmpAry = new Array(); // reset array
    		j = 0;
    		theOptGroup = new Object();
    		theOptGroup.label = selElem.options[i].text
		} else {
	    	tmpAry[j] = new Array();
	        tmpAry[j][0] = selElem.options[i].text;
	        tmpAry[j][1] = selElem.options[i].value;
	        j++;
        }
    }
    
    // Add the last grouping
    if (tmpAry.length > 0){
    	tmpAry.sort();
    	theOptGroup.sortedOptions = tmpAry;
    	theOptGroups.push(theOptGroup);
	}
    
    gp_clearlistbox(selElem);

    // Add the initial selection
    if (starterOption != '' && starterOption != null){
    	selElem.options[selElem.options.length] = new Option(starterOption, '');
    }
    
    // Loop through each grouping of items
    for (var i=0;i<theOptGroups.length;i++) {
    	var theOption = new Option(theOptGroups[i].label, '');
		theOption.disabled = true;
		selElem.options[selElem.options.length] = theOption
		
		for (var j=0;j<theOptGroups[i].sortedOptions.length;j++) {
			selElem.options[selElem.options.length] = new Option(theOptGroups[i].sortedOptions[j][0], theOptGroups[i].sortedOptions[j][1]);
		}
    }
    
}

// functions to compress and decompress shapepoints
// obtained from http://www.mapquestapi.com/common/encodedecode.html
function gp_decompressShapes (encoded, precision) {
	precision = Math.pow(10, -precision);
	var len = encoded.length, index=0, lat=0, lng = 0, array = [];
	while (index < len) {
		var b, shift = 0, result = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		var dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = encoded.charCodeAt(index++) - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		var dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		array.push(lat * precision);
		array.push(lng * precision);
	}
	return array;
}

function gp_compressShapes(points, precision) {
	var oldLat = 0, oldLng = 0, len = points.length, index = 0;
	var encoded = '';
	precision = Math.pow(10, precision);
	while (index < len) {
		//  Round to N decimal places
		var lat = Math.round(points[index++] * precision);
		var lng = Math.round(points[index++] * precision);
		
		//  Encode the differences between the points
		encoded += gp_encodeNumber(lat - oldLat);
		encoded += gp_encodeNumber(lng - oldLng);
		  
		oldLat = lat;
		oldLng = lng;
	}
	return encoded;
}

function gp_encodeNumber(num) {
	var num = num << 1;
	if (num < 0) {
		num = ~(num);
	}
	var encoded = '';
	while (num >= 0x20) {
		encoded += String.fromCharCode((0x20 | (num & 0x1f)) + 63);
		num >>= 5;
	}
	encoded += String.fromCharCode(num + 63);
	return encoded;   
}
	


/*************************
* Meta Data Functions
*************************/
function __META_DATA_FUNCTIONS__(){}


// Fill in the Color By Field given the Data Set name
function gp_loadColorBySelectFromDataSetFuture(dataSetIdentifier, override){
	setTimeout("gp_loadColorBySelectFromDataSet('" + dataSetIdentifier + "'," + override + ")",1);
}

function gp_loadColorBySelectFromDataSet(dataSetIdentifier, override){
	if(typeof(gp_dataSetInfo[dataSetIdentifier]) != "undefined"){
		if(typeof(gp_dataSetInfo[dataSetIdentifier].mapObjectName) != "undefined"){
			
			var colorByValue = gp_dataSetInfo[dataSetIdentifier].colorMarkersByFieldName;
			if (typeof(colorByValue) == "undefined") { colorByValue = ''; }
			
			if (override){
				gp_loadColorBySelectFromObject(gp_dataSetInfo[dataSetIdentifier].mapObjectName, colorByValue);
			} else {
				// Only run it if we are changing the object we are dealing with
				if (gp_dataSetInfo[dataSetIdentifier].mapObjectName != gp_lastMapObject){
					gp_loadColorBySelectFromObject(gp_dataSetInfo[dataSetIdentifier].mapObjectName, colorByValue);
				} else {
					// We still want to change the color by value if its preset on the Data Set
					jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').val(colorByValue);
					gp_UIElem.hidden_colorMarkersBy.value = colorByValue;
					if(colorByValue == ''){
						jQuery('#gp_ColorMarkersBy')[0].selectedIndex = 0;
						jQuery('#editDataSetColorBy')[0].selectedIndex = 0;
					}
				}
			}
			
		}
	}
}

// Fill in the Color By Field given the object name
function gp_loadColorBySelectFromObject(objectName, colorByValue){

	if(	typeof(gp_objectMeta[objectName]) != "undefined" && document.getElementById('gp_ColorMarkersBy') != null){
		
		// Save the last Map Object into memory
		gp_lastMapObject = objectName;
		
		jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').empty();
		
		// Add for IE6 since we are not sorting
		if (jQuery.browser.msie && jQuery.browser.version.substr(0,1)<7) {
			jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').append(jQuery("<option></option>").prop("value",'').text('-- Select a Field --'));
		}
		
		// Add objects to array for inclusion in Color By list
		var metaObjects = [];
		metaObjects.push(gp_objectMeta[objectName]);
		if(objectName == 'contact'){
			metaObjects.push(gp_objectMeta['account']);
		} else if(objectName == 'opportunity'){
			metaObjects.push(gp_objectMeta['account']);
		} else if(objectName == 'case'){
			metaObjects.push(gp_objectMeta['contact']);
			metaObjects.push(gp_objectMeta['account']);
		} else if(objectName == 'campaignmember'){
			metaObjects.push(gp_objectMeta['lead']);
			metaObjects.push(gp_objectMeta['contact']);
		} else if(objectName == 'opportunitylineitem'){
			metaObjects.push(gp_objectMeta['product2']);
			metaObjects.push(gp_objectMeta['opportunity']);
			metaObjects.push(gp_objectMeta['account']);
		}
		
		// Add each object to the color by array
		jQuery.each(metaObjects, function(key, metaObject) { 
			if(metaObject){
				jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').append(jQuery("<option></option>").prop("value",'').prop("disabled",true).text('***' + metaObject.objectLabel + ' Fields ***'));
				for(var i in metaObject.metaFields) {
					
					var pref = '';
					if(objectName=='contact' && metaObject.objectName=='account'){ pref = 'account.'; }
					if(objectName=='opportunity' && metaObject.objectName=='account'){ pref = 'account.'; }
					if(objectName=='case' && metaObject.objectName=='account'){ pref = 'account.'; }
					if(objectName=='case' && metaObject.objectName=='contact'){ pref = 'contact.'; }
					if(objectName=='campaignmember' && metaObject.objectName=='lead'){ pref = 'lead.'; }
					if(objectName=='campaignmember' && metaObject.objectName=='contact'){ pref = 'contact.'; }
					if(objectName=='opportunitylineitem' && metaObject.objectName=='opportunity'){ pref = 'opportunity.'; }
					if(objectName=='opportunitylineitem' && metaObject.objectName=='account'){ pref = 'opportunity.account.'; }
					if(objectName=='opportunitylineitem' && metaObject.objectName=='product2'){ pref = 'pricebookentry.product2.'; }
					
					var theLabel = metaObject.metaFields[i].fieldLabel;
					if(metaObject.metaFields[i].dataType == 'REFERENCE'){ 
						if(theLabel.indexOf(' ID') == -1){ theLabel += ' ID'; }
					}
					
					jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').append(jQuery("<option></option>").prop("value",pref + metaObject.metaFields[i].fieldName).text(theLabel));
					
					if(metaObject.metaFields[i].dataType == 'REFERENCE'){
						jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').append(jQuery("<option></option>").prop("value",pref + metaObject.metaFields[i].relationshipName + '.name').text(theLabel.replace(' ID', ' Name')));
					}
					
				}
			}
		}); 

		// Sort list box for all browsers, but IE6
		if (!jQuery.browser.msie || (jQuery.browser.msie && jQuery.browser.version.substr(0,1)>=7)) {
			gp_sortlistbox(document.getElementById('gp_ColorMarkersBy'),'-- Select a Field --');
			gp_sortlistbox(document.getElementById('editDataSetColorBy'),'-- Select a Field --');
		}
		
		if(colorByValue != ''){
			jQuery('#gp_ColorMarkersBy,#editDataSetColorBy').val(colorByValue);
			gp_UIElem.hidden_colorMarkersBy.value = colorByValue;
		} else {
			gp_UIElem.hidden_colorMarkersBy.value = '';
			jQuery("#gp_ColorMarkersBy option:first").attr('selected', 'selected');
			jQuery("#editDataSetColorBy option:first").attr('selected', 'selected');
		}
		
	}
}

// Run logic when a user changes the DataSet selection
// *** Overridden in Penske org ***
function gp_handleDataSetChange(val, override){
	gp_loadColorBySelectFromDataSetFuture(val, override);
}


/*************************
* Custom Ajax Modal methods
*************************/
var $modalDiv;
var $modalImg;

jQuery(document).ready(function(){
	//Preload the ajax icon by adding a "visibile" div to the page so image loads, but the css should never make it display to the user
	jQuery('<div class="geopointeAjaxImg"></div>').css({
		'height': '0px',
	    'left': '-100px',
	    'position': 'absolute',
	    'top': '-100px',
	    'width': '0px'
	}).appendTo("body");
});

function geopointeAjaxStart(selector,title,verticalOffset){
	
	//Find the element where the modal box should go inside of
	var $container = jQuery(selector);	
	
	//Get the width and height of the container
	var containerWidth = $container.outerWidth(true);
	var containerHeight = $container.outerHeight(true);
	
	//If container is body make height of modal the entire document
	if(selector == 'body'){
		containerHeight = jQuery(document).height();
	}	
	
	//Create a div inside the container element
	$modalDiv = jQuery('<div class="geopointeAjaxModal"></div>').prependTo($container).css({
		'height': containerHeight,
		'width': containerWidth,
		'top': 	function(){
					if(selector == 'body'){ return 0};
				},
		'left': function(){
					if(selector == 'body'){ return 0};
				}
	});	
	
	//Determin the title
	if(title == undefined){
		title = 'Loading...';
	}
	
	//Create a div that has the image loading icon and supplied text
	$modalImg = jQuery('<div class="geopointeAjaxStatus"><div class="geopointeAjaxTitle">'+title+'</div><div class="geopointeAjaxImg"><div class="geopointeAjaxImgPercent"><div></div></div>').prependTo($container);

	//If this modal is for the entire body of the document center the status image in the middle of the screen
	if(selector == 'body'){
		
		jQuery( $modalImg ).position({
			my: "center bottom",
			at: "center",
			of: jQuery(window)
		});
			
	}else{
		//This modal is within a div, set the vertical offset based on argument if provided
		var atOffset = "top+" + verticalOffset;
		if(verticalOffset == undefined || verticalOffset == ''){
			atOffset = "center";
		}
		
		//If container width is less than 1280px center the loading icon in center of the screen, there is a slight offset for very large containers as this looks more natural
		var myPosition = "right";
		if(containerWidth <= 1280){
			myPosition = "center";
		}
		
		jQuery( $modalImg ).position({
			my: myPosition,
			at: atOffset,
			of: $modalDiv
		});
	}
	return true;
}

function geopointeAjaxEnd(){
	//Remove the geopointe modal divs			
	if($modalDiv != undefined){
		$modalDiv.remove();
	}
	if($modalImg != undefined){
		$modalImg.remove();
	}
	return true;
}

function gp_updateDataSearchesObject(jsAction){

	//Only proceed if there is a poiCollection
	if(jsAction.poiCollections.length > 0){
		var removeAllShapes = false;

		for(var i = 0; i < jsAction.poiCollections.length; i++){
			if(jsAction.poiCollections[i].removeAllShapes == true){
				removeAllShapes = true;
			}
		}

		//If clear existing box is checked wipe out the gp_dataSetSearches object
		if(removeAllShapes == true){
			gp_dataSetSearches = {};
		}

		for(var i = 0; i < jsAction.poiCollections.length; i++){
			var poic = jsAction.poiCollections[i];

			//Only create layer if there was more than one POI
			if(poic.POIs.length > 0){
				//Add a record to the gp_dataSetSearches with key as collection name
				var dataSetSearch = {
					objectName: poic.sfdcObject,
					searchType: poic.searchType,
					searchRadius: poic.searchNearbyRange,
					numOfRecords: poic.POIs.length
				};

				if(poic.ds){
					dataSetSearch.name = poic.ds['name']
				}

				if(poic.ds && poic.ds['markerType'] == 'dynamic'){
					dataSetSearch.icon = 'multi';
				}else{
					dataSetSearch.icon = poic.mapIconURL;
				}

				gp_dataSetSearches[poic.collectionName] = dataSetSearch; 
			}
		}
	}
}

function gp_getTablesToProcess(disableAlerts){
	//Based on the apply action to select list (selected tab or all tabs) return correct jQuery selection

	//First make sure there are tabs displayed
	var $tabs = jQuery(".dataSetResultTableTab");
	if($tabs.length == 0){
		if(!disableAlerts){
			gp_alert('Please perform a Data Set search before applying this action.');
		}

		return []; //Return empty array
	
	}else if(jQuery("#applyActionTo").val() == 'allTabs' || jQuery("#applyActionTo").val() == 'selectedRecords'){
		//Return all the tables that the user has not removed from the map
		var tables = [];

		//Loop through all of the tabs and check to see it it has been removed from the map
		jQuery(".dataSetResultTableTab").each(function(){
			var collectionName = jQuery(this).attr('data-collectionName');

			//If tab is not hidden from the map add the table to list of those that should be returned
			if(jQuery(this).find(".poiCollectionTabLabel").hasClass('tabDataHidden') == false){
				tables.push(jQuery("#" + collectionName));
			}
		});

		//If there where no visible tabs, show an alert
		if(tables.length == 0){
			if(!disableAlerts){
				alert(gp_translations.There_must_be_Data_Sets_visible_on_the_map+'\n\n' + gp_translations.Select_the_Show_Data_Set_button);
			}
			return tables;
		}else{
			return tables;
		}

	}else{
		//Find the current tab that has it's content displayed and visible
		var selectedDataSetResultTable = jQuery('.dataSetResultTableTabContent:visible').find('table.gp_dataTable:visible');

		if(selectedDataSetResultTable.length == 0){
			if(!disableAlerts){
				alert(gp_translations.This_action_could_not_be_applied_to_the_selected_tab +'\n\n'+ gp_translations.If_this_is_a_Data_Set_search_tab_please_ensure);
			}
			return []; //Return empty array
		}else{
			return selectedDataSetResultTable;
		}
	}
}

//PageMessage is a class in Mapping.cls
function buildMessageHTML(pageMessages){

	//Build object of severity to array of messages
	var messagesByType = {};
	for(var i = 0; i < pageMessages.length; i++){
		messagesByType[pageMessages[i].severity] = new Array();
	}

	for(var i = 0; i < pageMessages.length; i++){
		messagesByType[pageMessages[i].severity].push(pageMessages[i].message);
	}

	var html = '';

	for (var key in messagesByType) {

		//Determine the type of error message
		var type = key;
		if(type.toLowerCase() == 'fatal') type = 'error';

		//Build out the message HTML
		var message = '';
		if(messagesByType[key].length == 1){
			message = messagesByType[key][0];

		}else{
			message = '<ul style="padding-left:10px;padding-top:0px;margin:0px">';
			for(var i = 0; i < messagesByType[key].length; i++){
				message += '<li style="padding-top:5px">'+messagesByType[key][i]+'</li>';
			}
            message += '</ul>';
		}

		var messageHTML = ''+
		'<div class="message '+type.toLowerCase()+'M3">'+
		    '<button class="hideErrorMessage" type="button" onclick="updatePageMessages([]);">×</button>'+
		    '<table border="0" cellpadding="0" cellspacing="0" class="messageTable" style="padding:0px;margin:0px;">'+
		        '<tbody>'+
		            '<tr valign="top">'+
		                '<td><img alt="INFO" class="msgIcon" src="/s.gif" title="INFO" /></td>'+

		                '<td class="messageCell">'+
		                    '<div class="messageText">'+
		                        message +
		                    '</div>'+
		                '</td>'+
		            '</tr>'+
		            '<tr>'+
		                '<td></td>'+
		                '<td>'+
		                '</td>'+
		            '</tr>'+
		        '</tbody>'+
		    '</table>'+
		'</div>';

		html += messageHTML;
	}

	return html;
}
//http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values, answer: http://stackoverflow.com/a/2880929/965897
function getURLparams() {
    var urlParams;	
    var match,
        pl     = /\+/g,  // Regex for replacing addition symbol with a space
        search = /([^&=]+)=?([^&]*)/g,
        decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
        query  = window.location.search.substring(1);

    urlParams = {};
    while (match = search.exec(query)) urlParams[decode(match[1])] = decode(match[2]);
    return urlParams;
}

//Cookie methods: http://www.w3schools.com/js/js_cookies.asp
function gp_setCookie(c_name,value,exdays){
	var exdate=new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
	document.cookie=c_name + "=" + c_value;
}

function gp_getCookie(c_name){
	var i,x,y,ARRcookies=document.cookie.split(";");
	for (i=0;i<ARRcookies.length;i++){
		x=ARRcookies[i].substr(0,ARRcookies[i].indexOf("="));
		y=ARRcookies[i].substr(ARRcookies[i].indexOf("=")+1);
		x=x.replace(/^\s+|\s+$/g,"");
		if (x==c_name){
			return unescape(y);
		}
	}
}

function gp_loadGoogScript(callback){
  var script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = googJSsrc + '&callback=' + callback;
  document.body.appendChild(script);
}