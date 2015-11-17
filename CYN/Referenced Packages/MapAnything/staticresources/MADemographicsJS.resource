
MAData = {
	CensusLayer: null,

	domain: "https://product-api-prod.cloudbilt.com/demographicsv3",

	sandbox: false,

	//Initialize all of the goodies
	Init: function() {

		MAData.StopPropagation();
		MAData.GetCountries();
	},

	//Handles propagation of clicks on the menu
	StopPropagation: function() {

		//stop propagation of click events to avoid closing the menu
		$('#countryplaceholder, #datasourceplaceholder, #topicplaceholder, #groupbyplaceholder').on('click', function (e) {
			e.stopPropagation();
		});
	},

	//Handles clicks on the map
	HandleClick: function(e) {
		//console.log(e.latLng);

		//HIDE ALL TABS!
		//They'll be revealed later.
		$('#tab-housing').hide();
		$('#tab-ageGender').hide();
		$('#tab-race').hide();
		$('#tab-income').hide();
		$('#tab-education').hide();

		//create a new info bubble and show loading
		var $tooltipContent = $('#tooltip-demographic-template').clone().attr('id', 'tooltip-content').addClass('demographics').show();

		$tooltipContent.find('.tooltip-loader').show();

		MA.demographicsInfoBubble = MA.Map.InfoBubble.show({
			position: e.latLng,
			minWidth: 200,
			content: $tooltipContent.get(0)
		});

		//send request to get new demographic data
		//setTimeout (function () {
			var topic = $('#topic').val();
			var groupby = $('#groupby').val();
			var country = $('#country').val();
			var lat = e.latLng.lat();
			var lng = e.latLng.lng();

			$.getJSON( MAData.domain + '/info/index.php?action=getpointinfo&sandbox=' + MAData.sandbox + '&topic=' + topic + '&groupby=' + groupby + '&country=' + country + '&lat=' + lat + '&long=' + lng + '&callback=?&apikey=' + MA.APIKey, function( data ) {
				//console.log(data);

				if (data.success)
				{
				    var GroupArray = [];
				    
				    
					//loop over results and build tabs
					$.each(data.data, function( index, value ) {
                        
                        
                        
						//add headerinfo
						if(index == 'headerinfo') {
							$.each(value,function(index, info) {
								var formattedInfo;

								if(info.value == null || info.value == '') {
									formattedInfo = 'N/A';
								} else {
									formattedInfo = info.value;
								}

								var row = '<tr><td style="font-weight:bold; font-size: 12px; ">' + info.label + ':</td><td style="font-size: 12px;">' + formattedInfo + '</td></tr>';

								//append to table
								$tooltipContent.find('.tooltip-table').append(row);
							});
						}
                        else if(index == 'searchinfo') 
                        { 
                            //add searchinfo
							$.each(value,function(index, info) {
								//check if value is a valid number and format
								var formatedNumber;
								if(isNaN(info.value) == false) {
									formatedNumber = MAData.FormatNumber(info.value);
								}
								else {
									formatedNumber = info.value;
								}

								var row = '<tr><td style="font-weight:bold; font-size: 12px; ">' + info.label + ':</td><td style="font-size: 12px;">' + formatedNumber + '</td></tr>';

								//append to table
								$tooltipContent.find('.tooltip-table').append(row);
							});
						}
						else
						{
						    //console.log('this is info');
						    
					    	//check if value is a valid number and format
    						var formatedNumber;
    						if(isNaN(value.value) == false) {
    							formatedNumber = MAData.FormatNumber(value.value);
    						}
    						else {
    							formatedNumber = value.value;
    						}
    
    						var row = '<tr><td style="font-weight:bold; font-size: 12px;">' + value.label + ':</td><td style="float:right; font-size: 12px;">' + formatedNumber + '</td></tr>';
    						
    						//Is There a group?
    						if (value.group != null)
    						{
    						    var groupName = value.group.replace(/[^\w\s]/gi, '').replace(/[^\w\s]/gi, '').replace(/ /g, '_');
    						    
    						    //have we made a tab for this group yet?
    						    if ($.inArray(value.group,GroupArray) > -1)
    						    {
    						        
    						    }
    						    else
    						    {
    						        //not found, let's add a tab
    						        
    						        
    						        
    						        $tooltipContent.find('#madata-tabs').find('ul').append('<li><a href="#tab-' + groupName + '">' + value.group + '</a></li>');
    						        $tooltipContent.find('#madata-tabs').append('<div id="tab-' + groupName + '"><table id="'+ groupName + '-table"></table></div>');
    						        
    						        GroupArray.push(value.group);
    						    }
    						    
    						    $tooltipContent.find('#' + groupName + '-table').append(row);
    						    
    						    
    						}
    						else
    						{
    						    
    						}
    						
						    
						}

					

                        /*
						//build housing tab
						if(value.group == 'Housing' && value.value != null) {
							$('#tab-housing').show();
							$tooltipContent.find('.housing-table').append(row);
						}

						//build Age/Gender Tab
						if(value.group == 'Age/Gender' && value.value != null) {
							$('#tab-ageGender').show();
							$tooltipContent.find('.ageGender-table').append(row);
						}

						//build Race Tab
						if(value.group == 'Race' && value.value != null) {
							$('#tab-race').show();
							$tooltipContent.find('.race-table').append(row);
						}

						//build Income Tab
						if(value.group == 'Income' && value.value != null) {
							$('#tab-income').show();
							$tooltipContent.find('.income-table').append(row);
						}

						//build Education Tab
						if(value.group == 'Education' && value.value != null) {
							$('#tab-education').show();
							$tooltipContent.find('.education-table').append(row);
						}
						*/
					});

					//init tabs
					$tooltipContent.find('.tabs').tabs({
						activate: function( event, ui ) {
							setTimeout(function () {
								try { MA.demographicsInfoBubble.padding_changed(); MA.demographicsInfoBubble.panToView(); } catch (err) {}
							}, 500);
						}
					});

					//hide loading and adjust pan
					$tooltipContent.find('.tooltip-loader').hide();
					MA.demographicsInfoBubble.padding_changed();
					MA.demographicsInfoBubble.panToView();
				}
				else
				{
					MA.Map.InfoBubble.hide();
				}
			});
		//}, 1000);
	},


	//Makes the call to the PHP in order to get the countries
	GetCountries: function() {
		//console.log('Acquiring the countries...');

		$.getJSON( MAData.domain + "/info/index.php?action=getcountries&sandbox=" + MAData.sandbox + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var CountrySelectHTML = '<select id="country" onchange="MAData.GetDataSources()">';

				CountrySelectHTML += '<option value="" disabled selected>Please select a country</option>';

				$.each(data.data, function( index, value ) {

					CountrySelectHTML += '<option value="' + value.value + '">'+ value.label +'</option>';

				});

				CountrySelectHTML += '</select>';
				$('#countryplaceholder').html(CountrySelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},


	//Makes the call to the PHP in order to get the data sources
	GetDataSources: function() {
		//console.log('Acquiring the data sources...');

		var country = $('#country').val();

		$.getJSON( MAData.domain + "/info/index.php?action=getdatasources&sandbox=" + MAData.sandbox + "&country=" + country + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var DataSourceSelectHTML = '<select id="datasource" onchange="MAData.GetTopics()">';

				DataSourceSelectHTML += '<option value="" disabled selected>Please select a datasource</option>';

				$.each(data.data, function( index, value ) {
					
					DataSourceSelectHTML += '<option value="' + value.value + '">'+ value.label +'</option>';

				});

				DataSourceSelectHTML += '</select>';
				$('#datasourceplaceholder').html(DataSourceSelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},


	//Makes the call to the PHP in order to get the topics
	GetTopics: function() {
		//console.log('Acquiring the topics...');

		var datasource = $('#datasource').val();
		var country = $('#country').val();

		$.getJSON( MAData.domain + "/info/index.php?action=gettopics&sandbox=" + MAData.sandbox + "&country=" + country + "&datasource=" + datasource + "&callback=?&apikey=" + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				var TopicSelectHTML = '<select id="topic" onchange="MAData.GetLevels()">';

				TopicSelectHTML += '<option value="" disabled selected>Please select a topic</option>';

				$.each(data.data, function( index, value ) {
					
					TopicSelectHTML += '<option value="' + value.value + '">'+ value.label +'</option>';

				});

				TopicSelectHTML += '</select>';
				$('#topicplaceholder').html(TopicSelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},


	//Makes the call to the PHP in order to get the levels
	GetLevels: function() {
		//console.log('Acquiring the levels...');

		var datasource = $('#datasource').val();
		var country = $('#country').val();
		var topic = $('#topic').val();

		$.getJSON( MAData.domain + "/info/index.php?action=getlevels&sandbox=" + MAData.sandbox + "&country=" + country + "&datasource=" + datasource + "&topic=" + topic + "&callback=?&apikey=" + MA.APIKey, function( data ) {
			//console.log(data);

			if (data.success && data.data.length > 0)
			{
				var GroupBySelectHTML = '<select id="groupby">';

				$.each(data.data, function( index, value ) {
					
					GroupBySelectHTML += '<option value="' + value.value + '">'+ value.label +'</option>';

				});

				GroupBySelectHTML += '</select>';
				$('#groupbyplaceholder').html(GroupBySelectHTML);

			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
			}
		});
	},

	
	//Makes the call to the PHP in order to get the data
	GetData: function() {

		var topic = $('#topic').val();
		var groupby = $('#groupby').val();
		var country = $('#country').val();
		var usecache = true;

		//console.log('Acquiring legend...');

		$.getJSON( MAData.domain + '/info/index.php?action=getlegend&sandbox=' + MAData.sandbox + '&topic=' + topic + '&groupby='+ groupby + '&country=' + country + '&callback=?&apikey=' + MA.APIKey, function( data ) {

			if (data.success && data.data.length > 0)
			{
				MAData.ClearLayer();

				//remove previous data
				$('.DemographicTable').removeData('legendInfo');
				$('.DemographicTable').removeData('legendHead');

				//store data for legend recreate
				$('.DemographicTable').data('legendInfo', data.data);
				$('.DemographicTable').data('legendHead', $('.DemographicTable #topic').find(":selected").text());

				//create legend
				MAData.CreateDemoLegend(data.data);

				MAData.CensusLayer = new google.maps.ImageMapType({
					name: 'Census',
					maxZoom: 18,
					tileSize: new google.maps.Size(256, 256),
					opacity: $('.fill-opacity-slider').slider('value')/100,
					getTileUrl: function(coord, zoom) {
						return [ MAData.domain + '/tile/index.php?x=', coord.x, '&y=', coord.y, '&z=', zoom, '&sandbox=', MAData.sandbox, '&cache=', usecache, '&topic=', topic, '&groupby=', groupby, '&country=', country, '&legend=', encodeURIComponent(JSON.stringify(data.data))].join('');
					}

				});

				MA.map.overlayMapTypes.push(MAData.CensusLayer);

				$('.demo-legend-button').show().val('Hide Legend');

				//TURN ON CLICKS!
				google.maps.event.addListener(MA.map, 'click', function(event) {
					MAData.HandleClick(event);
				});
	
			}
			else
			{
				//Error! Read message property
				//console.log(data.message);
				//$('#legendplaceholder').html('No Census Data Available');
			}

		});

	},


	//Show or hide the legend
	ShowHideLegend: function() {
		if($('.demo-legend-button').val() == 'Hide Legend') {
			$('#mapcontainer').find('> .demo-legend').remove();
			$('.demo-legend-button').val('Show Legend');
		}
		else {
			MAData.CreateDemoLegend ($('.DemographicTable').data('legendInfo'));
			$('.demo-legend-button').val('Hide Legend');
		}
	},


	//Format a number
	FormatNumber: function(v) {
	    
	    if (v == null)
	    {
	        return 0;
	    }
	    else
	    {
    	    v = v.replace(/,/g, ''); //take away all commas just in case
    	    
    		var a = parseFloat(v).toString().split(".");
    		var b = a[0].split("").reverse().join("").replace(/.{3,3}/g, "$&,").replace(/\,$/, "").split("").reverse().join("");
    
    		if(parseFloat(v).toString().split(".").length == 1) {
    			return v = b;
    		}
    		else {
    			return v = b + "." + a[1];
    		}
	    }
	},


	//Refresh the slider
	RefreshSlider: function() {
		$(this).closest('td').find('.percent').text($(this).slider( "value" )+'%');
		if(MAData.CensusLayer != null) {
			MAData.CensusLayer.setOpacity($(this).slider( "value" )/100);
		}

		//update legend
		$.each($('.legend-table .demo-color'),function() {
			var opacity = $('.fill-opacity-slider').slider('value')/100;
			$(this).css('opacity', opacity);
		});
	},


	//Initialize the sliders
	InitializeSliders: function() {
		$('.DemographicTable .slider').slider({
			step: 5,
			range: "min",
			max: 100,
			min: 0,
			value: 50,
			slide: MAData.RefreshSlider(),
			change: MAData.RefreshSlider()
		});
	},


	//Removes the overlay
	RemoveOverlay: function (name) {
		$.each(MA.map.overlayMapTypes.getArray(), function (i, overlay) {
			if (overlay.name == name) {
				MA.map.overlayMapTypes.removeAt(i);
				return false;
			}
		});
	},


	//Creates the legend with the given legend data
	CreateDemoLegend: function(legend) {
		var $legend = $('.demo-legend').clone().draggable({ containment: "parent" });

		$.each(legend, function( index, value ) {
			var rgb = hexToRgb(value.color);
			var opacity = $('.fill-opacity-slider').slider('value')/100;

			var $row = '<tr><td class="demo-color" style="width:20px; height: 20px; background: rgba('+rgb.r+', '+rgb.g+', '+rgb.b+' , 1); opacity:'+opacity+';"></td><td style="padding-left: 5px;">' 
			+ MAData.FormatNumber(value.min) + '</td><td>-</td><td>' + MAData.FormatNumber(value.max) + '</td></tr>';
			
			$legend.find('.legend-table').append($row);
		});

		//append header
		$legend.find('.legend-head').text($('.DemographicTable').data('legendHead'));

		//show legend
		$legend.appendTo('#mapcontainer');

		//handle close button
		$legend.on('click', '.demo-legend-close', function () {
			$('#mapcontainer').find('> .demo-legend').remove();
			$('.demo-legend-button').val('Show Legend');
		});

		//adjust heighth of now attached table
		$('#mapcontainer > .demo-legend').css('height', $('#mapcontainer > .demo-legend .legend-table').height());
		$('#mapcontainer > .demo-legend').css('width', $('#mapcontainer > .demo-legend .legend-table').width());
	},


	//Clears the census layer
	ClearLayer: function() {
		if (MAData.CensusLayer != null)
		{
			//remove clicks
			google.maps.event.clearListeners(MA.map, 'click');

			//empty the census layer
			MAData.CensusLayer = null;

			//touch up the map
			MA.Map.InfoBubble.hide();
			MAData.RemoveOverlay('Census');

			$('#mapcontainer').find('> .demo-legend').remove();
			$('.demo-legend-button').hide();
		}
	}
}