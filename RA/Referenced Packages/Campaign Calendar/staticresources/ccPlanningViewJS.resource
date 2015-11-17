/**
 * Planning View for Campaign Calendar by Bracket Labs
 * Copyright (c) 2011 Bracket Labs - bracketlabs.com
 * Ken Hua 
 * 06/21/2011 - Modified list view
 * 07/05/2011 - Date block functionality completed
 * 07/06/2011 - Date blocks now obey the CC color settings. Changed to work with outputLinks and actionFunctions from the List page. 
 *				This allows specific parts of the page to load decreasing load times. Year manipulation is now local to this resource
 *				in order to avoid a distributed issue.
 * 07/07/2011 - The campaign description is now displayed in an expandable row for each campaign.
 * 07/08/2011 - Clickable name and date blocks for each campaign.
 * Erty Seidel  
 * 07/05/2011 - Changed to render view using tables with nested divs instead of straight divs
 * 
 * Jordan Baucke
 * 10/28/2011 - Optimize to the javascript, load *all* campaign data in a single request to the server and than render
 * 				the arrays seperately for each year (speeds up page response)
 * 				-Show/hide dates checkbox functionality improved, removed animations (overloaded browser on large page) -
 * 				-Set custom setting for 'show/hide date' checkbox value so it is now saved in the user database
 * 				-Added partial refresh to the page
 * 				-Loading masks, and hover intent on the 'date' text when it is deactiviated. 
 * 				-See various github commits and notes - Winter '12 hotfix, and patches as well as some MSIE bugs fixed.
 * 		
 */

var data = {};
var planningViewTable;
var planningViewPage = true;
var maskFlag = false;
var unselected = false;
var faultFlag = false;
var pageMessage = '';
var errorArray = [];	//array for storing error messages from the server

$j = jQuery.noConflict();

$j('document').ready(function(){
	attachPageClickHandlers();
	$j('.pageTitleIcon').attr('src',campaignCalendarIcon);
	if (blccFilterId == null || blccFilterId == '') {
		// No list view selected
		showMaskMessage('Please select a list view above', '#planningView', 'loadmask-warning', 0);
	}
	else {
		//Optimization for the scroll function
		loadAndRenderCampaignData('Loading...');
	}
});

//Keep the table head at the top of the page when the user scrolls down
$j(window).scroll(function(){
	planningViewTable = $j('#planningViewTable');
	if($j(window).scrollTop() > planningViewTable.offset().top){
		planningViewTable.children('thead').addClass('planningViewTableTheadFixed');
	} else{
		planningViewTable.children('thead').removeClass('planningViewTableTheadFixed');
	}
});

/*
 * loadAndRenderCampaignData()
 * 
 * Loads campaign data from the server (and renders it to the page.
 * 
 * Used on pageload, list view change, campaigns being added, or other items being changed.
 * 
 */
function loadAndRenderCampaignData(message){
	data = {}; //reset data array
	$j('#planningView').removeClass('loadmask-warning');
	$j('#planningView').removeClass('loadmask-error');
	$j('#planningViewData').html('');	//clear the datatable
	$j('#planningView').mask(message);
	setTimeout("getDataAndRenderMasked()",250);
}

function getDataAndRenderMasked(){
	getPlanningViewData(function(overTwoThousandFlag){
		if(overTwoThousandFlag)	{
			showMaskMessage('Some campaigns may be not be shown.<br />Please select a list view that contains less than 2,000 campaigns.', '#planningView', 'loadmask-warning', 5000);
		}
		if (data.hasOwnProperty($j('#year').text())) {
			renderPlanningViewYear(function(){
				var campaignsInYear = (data.hasOwnProperty($j('#year').text())) ? data[$j('#year').text()].length.toString() : '0';
				$j('.pageDescription').html('Planning View ' + $j('#year').text() +' - '+ campaignsInYear + ' Campaigns'); //update the page header
				if (!overTwoThousandFlag) {
					$j('#planningView').unmask();
				}
				overTwoThousandFlag = false; //reset the flag for next-time we try to reload the listview (;
			});
		}
		else{
			showMaskMessage('The current list view contains no campaigns that begin or end during the current year.<br /> Please select a different list view or year.', '#planningView', 'loadmask-warning', 0);
		}
	});
}

/*
 * renderView();
 * 
 * Renders the view without reloading campaign data from the server - (used from changing years)
 */
function renderView(){
	var campaignsInYear = (data.hasOwnProperty($j('#year').text())) ? data[$j('#year').text()].length.toString() : '0';
	$j('.pageDescription').html('Planning View ' + $j('#year').text() +' - '+ campaignsInYear + ' Campaigns'); //update the page header
	$j('#planningView').removeClass('loadmask-warning');
	$j('#planningView').removeClass('loadmask-error');
	$j('#planningViewData').html(''); //clear the datatable
	$j('#planningView').mask('Loading...');
	setTimeout("renderViewMasked()",250);
}

function renderViewMasked(){
		//the data array has some campaigns in this year so render the view
	if (data.hasOwnProperty($j('#year').text())) {
		renderPlanningViewYear(function(){
			$j('#planningView').unmask();
		});
	}
	else {
		showMaskMessage('The current list view contains no campaigns that begin or end during ' + $j('#year').text() + '.<br /> Please select a different list view or year.', '#planningView', 'loadmask-warning', 0);
	}
}

/*
 * Adds a slight delay to the loadAndRenderCampaign function to allow for the dialog box to close
 * before reloading the data
 * 
 * This function is defined here so as to set the scope correctly when the function is setTimeout
 * because otherwise the parent.____ wouldn't work with setTimeout in the dialog, Jordan, 10/24/11
 */
function loadAndRenderWithDelay(message)
{
	pageMessage = message;
	setTimeout("loadAndRenderCampaignData(pageMessage);",250);
}

function getPlanningViewData(callback){
	var overTwoThousandFlag = false;
	var results = [];
	var currentYear = parseInt($j('#year').text());
	var currentFilterId = $j('#filterId').val();
	if(currentFilterId == ''){
		showMaskMessage('Please select a list view above', '#planningView', 'loadmask-warning', 0);	
	}
	else{
		CAMPAIGNCAL.ccPlanningViewController.getCampaignsPV(currentFilterId+'-'+$j('#year').text(), function(event, result){
	            if(result.status == true){
					var events = [];
					$j.each(result.result, function(i, event){
						events.push({
							id: event.id,
							name: event.name,
							sortDate: new Date(event.startYear, event.startMonth-1, event.startDay),
							startDate: event.startDate,
							endDate: event.endDate,
							startYear: event.startYear,
							startMonth: event.startMonth,
							startDay: event.startDay,
							endYear: event.endYear,
							endMonth: event.endMonth,
							endDay: event.endDay,
							textColor: event.textColor,
							backgroundColor: event.color,
							borderColor: event.borderColor,
							type: event.campaignType,
							description: event.description,
	                                                endLocaleDate: event.endLocaleDate,
	                                                startLocaleDate: event.startLocaleDate
						});
					});
					events.sort(function(a, b){
						var dateA = new Date(a.sortDate), dateB = new Date(b.sortDate)
						return dateA - dateB //sort by date ascending
					});
					
					//organize the campaigns by year
					$j.each(events, function(i, event){
						if(event.startyear != event.endYear)
						{
							var i = parseInt(event.startYear);
							for(i; i <= parseInt(event.endYear); i++)
							{
								addCampaignToArray(event,i);
							}
						}
						else
							addCampaignToArray(event,event.startYear);		
					});
					
					if(events.length >= 2000){
						overTwoThousandFlag = true;
					}
	
					callback(overTwoThousandFlag);
	
				}
				else{
   		            $j('#planningView').unmask();
		           	errorArray.push(result);
		           	showMaskMessage('An error occured fetching information from the server.</br></br> Would you like to send an error report to Bracket Labs?</br></br><input class="btn" onclick="$j(\'.bracketLabsFeedbackButton\').click();" value="Report An Error" style="width:100px; text-align: center;"/>&nbsp;&nbsp;<input class="btn" onclick="$j(\'#planningView\').unmask();" value="Dismiss" style="width:100px; text-align: center;">', '#planningView', 'loadmask-top loadmask-error', 0);
	           }
		});
	}
}	

/*
 * addCampaignToArray()
 * 
 * Adds the campaign to the array based on the year target
 */
function addCampaignToArray(event,yearTarget)
{
	if (data.hasOwnProperty(yearTarget)) {
		data[yearTarget].push(event);
	}
	else {
		var array = [];
		array.push(event);
		data[yearTarget] = array; //add the year array to the object
	}	
}

function getLocaleShortgetLocaleShortDateStringDateString(d)
{
    var f={"ar-SA":"dd/MM/yy","bg-BG":"dd.M.yyyy","ca-ES":"dd/MM/yyyy","zh-TW":"yyyy/M/d","cs-CZ":"d.M.yyyy","da-DK":"dd-MM-yyyy","de-DE":"dd.MM.yyyy","el-GR":"d/M/yyyy",
    "en-US":"M/d/yyyy","fi-FI":"d.M.yyyy","fr-FR":"dd/MM/yyyy","he-IL":"dd/MM/yyyy","hu-HU":"yyyy. MM. dd.","is-IS":"d.M.yyyy","it-IT":"dd/MM/yyyy","ja-JP":"yyyy/MM/dd",
    "ko-KR":"yyyy-MM-dd","nl-NL":"d-M-yyyy","nb-NO":"dd.MM.yyyy","pl-PL":"yyyy-MM-dd","pt-BR":"d/M/yyyy","ro-RO":"dd.MM.yyyy","ru-RU":"dd.MM.yyyy","hr-HR":"d.M.yyyy",
    "sk-SK":"d. M. yyyy","sq-AL":"yyyy-MM-dd","sv-SE":"yyyy-MM-dd","th-TH":"d/M/yyyy","tr-TR":"dd.MM.yyyy","ur-PK":"dd/MM/yyyy","id-ID":"dd/MM/yyyy","uk-UA":"dd.MM.yyyy",
    "be-BY":"dd.MM.yyyy","sl-SI":"d.M.yyyy","et-EE":"d.MM.yyyy","lv-LV":"yyyy.MM.dd.","lt-LT":"yyyy.MM.dd","fa-IR":"MM/dd/yyyy","vi-VN":"dd/MM/yyyy","hy-AM":"dd.MM.yyyy",
    "az-Latn-AZ":"dd.MM.yyyy","eu-ES":"yyyy/MM/dd","mk-MK":"dd.MM.yyyy","af-ZA":"yyyy/MM/dd","ka-GE":"dd.MM.yyyy","fo-FO":"dd-MM-yyyy","hi-IN":"dd-MM-yyyy","ms-MY":"dd/MM/yyyy",
    "kk-KZ":"dd.MM.yyyy","ky-KG":"dd.MM.yy","sw-KE":"M/d/yyyy","uz-Latn-UZ":"dd/MM yyyy","tt-RU":"dd.MM.yyyy","pa-IN":"dd-MM-yy","gu-IN":"dd-MM-yy","ta-IN":"dd-MM-yyyy","te-IN":"dd-MM-yy",
    "kn-IN":"dd-MM-yy","mr-IN":"dd-MM-yyyy","sa-IN":"dd-MM-yyyy","mn-MN":"yy.MM.dd","gl-ES":"dd/MM/yy","kok-IN":"dd-MM-yyyy","syr-SY":"dd/MM/yyyy","dv-MV":"dd/MM/yy","ar-IQ":"dd/MM/yyyy",
    "zh-CN":"yyyy/M/d","de-CH":"dd.MM.yyyy","en-GB":"dd/MM/yyyy","es-MX":"dd/MM/yyyy","fr-BE":"d/MM/yyyy","it-CH":"dd.MM.yyyy","nl-BE":"d/MM/yyyy","nn-NO":"dd.MM.yyyy","pt-PT":"dd-MM-yyyy",
    "sr-Latn-CS":"d.M.yyyy","sv-FI":"d.M.yyyy","az-Cyrl-AZ":"dd.MM.yyyy","ms-BN":"dd/MM/yyyy","uz-Cyrl-UZ":"dd.MM.yyyy","ar-EG":"dd/MM/yyyy","zh-HK":"d/M/yyyy","de-AT":"dd.MM.yyyy",
    "en-AU":"d/MM/yyyy","es-ES":"dd/MM/yyyy","fr-CA":"yyyy-MM-dd","sr-Cyrl-CS":"d.M.yyyy","ar-LY":"dd/MM/yyyy","zh-SG":"d/M/yyyy","de-LU":"dd.MM.yyyy","en-CA":"dd/MM/yyyy",
    "es-GT":"dd/MM/yyyy","fr-CH":"dd.MM.yyyy","ar-DZ":"dd-MM-yyyy","zh-MO":"d/M/yyyy","de-LI":"dd.MM.yyyy","en-NZ":"d/MM/yyyy","es-CR":"dd/MM/yyyy","fr-LU":"dd/MM/yyyy","ar-MA":"dd-MM-yyyy",
    "en-IE":"dd/MM/yyyy","es-PA":"MM/dd/yyyy","fr-MC":"dd/MM/yyyy","ar-TN":"dd-MM-yyyy","en-ZA":"yyyy/MM/dd","es-DO":"dd/MM/yyyy","ar-OM":"dd/MM/yyyy","en-JM":"dd/MM/yyyy","es-VE":"dd/MM/yyyy",
    "ar-YE":"dd/MM/yyyy","en-029":"MM/dd/yyyy","es-CO":"dd/MM/yyyy","ar-SY":"dd/MM/yyyy","en-BZ":"dd/MM/yyyy","es-PE":"dd/MM/yyyy","ar-JO":"dd/MM/yyyy","en-TT":"dd/MM/yyyy","es-AR":"dd/MM/yyyy",
    "ar-LB":"dd/MM/yyyy","en-ZW":"M/d/yyyy","es-EC":"dd/MM/yyyy","ar-KW":"dd/MM/yyyy","en-PH":"M/d/yyyy","es-CL":"dd-MM-yyyy","ar-AE":"dd/MM/yyyy","es-UY":"dd/MM/yyyy","ar-BH":"dd/MM/yyyy",
    "es-PY":"dd/MM/yyyy","ar-QA":"dd/MM/yyyy","es-BO":"dd/MM/yyyy","es-SV":"dd/MM/yyyy","es-HN":"dd/MM/yyyy","es-NI":"dd/MM/yyyy","es-PR":"dd/MM/yyyy","am-ET":"d/M/yyyy","tzm-Latn-DZ":"dd-MM-yyyy",
    "iu-Latn-CA":"d/MM/yyyy","sma-NO":"dd.MM.yyyy","mn-Mong-CN":"yyyy/M/d","gd-GB":"dd/MM/yyyy","en-MY":"d/M/yyyy","prs-AF":"dd/MM/yy","bn-BD":"dd-MM-yy","wo-SN":"dd/MM/yyyy","rw-RW":"M/d/yyyy",
    "qut-GT":"dd/MM/yyyy","sah-RU":"MM.dd.yyyy","gsw-FR":"dd/MM/yyyy","co-FR":"dd/MM/yyyy","oc-FR":"dd/MM/yyyy","mi-NZ":"dd/MM/yyyy","ga-IE":"dd/MM/yyyy","se-SE":"yyyy-MM-dd","br-FR":"dd/MM/yyyy",
    "smn-FI":"d.M.yyyy","moh-CA":"M/d/yyyy","arn-CL":"dd-MM-yyyy","ii-CN":"yyyy/M/d","dsb-DE":"d. M. yyyy","ig-NG":"d/M/yyyy","kl-GL":"dd-MM-yyyy","lb-LU":"dd/MM/yyyy","ba-RU":"dd.MM.yy",
    "nso-ZA":"yyyy/MM/dd","quz-BO":"dd/MM/yyyy","yo-NG":"d/M/yyyy","ha-Latn-NG":"d/M/yyyy","fil-PH":"M/d/yyyy","ps-AF":"dd/MM/yy","fy-NL":"d-M-yyyy","ne-NP":"M/d/yyyy","se-NO":"dd.MM.yyyy",
    "iu-Cans-CA":"d/M/yyyy","sr-Latn-RS":"d.M.yyyy","si-LK":"yyyy-MM-dd","sr-Cyrl-RS":"d.M.yyyy","lo-LA":"dd/MM/yyyy","km-KH":"yyyy-MM-dd","cy-GB":"dd/MM/yyyy","bo-CN":"yyyy/M/d","sms-FI":"d.M.yyyy",
    "as-IN":"dd-MM-yyyy","ml-IN":"dd-MM-yy","en-IN":"dd-MM-yyyy","or-IN":"dd-MM-yy","bn-IN":"dd-MM-yy","tk-TM":"dd.MM.yy","bs-Latn-BA":"d.M.yyyy","mt-MT":"dd/MM/yyyy","sr-Cyrl-ME":"d.M.yyyy",
    "se-FI":"d.M.yyyy","zu-ZA":"yyyy/MM/dd","xh-ZA":"yyyy/MM/dd","tn-ZA":"yyyy/MM/dd","hsb-DE":"d. M. yyyy","bs-Cyrl-BA":"d.M.yyyy","tg-Cyrl-TJ":"dd.MM.yy","sr-Latn-BA":"d.M.yyyy",
    "smj-NO":"dd.MM.yyyy","rm-CH":"dd/MM/yyyy","smj-SE":"yyyy-MM-dd","quz-EC":"dd/MM/yyyy","quz-PE":"dd/MM/yyyy","hr-BA":"d.M.yyyy.","sr-Latn-ME":"d.M.yyyy","sma-SE":"yyyy-MM-dd","en-SG":"d/M/yyyy",
    "ug-CN":"yyyy-M-d","sr-Cyrl-BA":"d.M.yyyy","es-US":"M/d/yyyy"};

    var l=navigator.language?navigator.language:navigator['userLanguage'],y=d.getFullYear(),m=d.getMonth()+1,d=d.getDate();
    f=(l in f)?f[l]:"MM/dd/yyyy";
    function z(s){s=''+s;return s.length>1?s:'0'+s;}
    f=f.replace(/yyyy/,y);f=f.replace(/yy/,String(y).substr(2));
    f=f.replace(/MM/,z(m));f=f.replace(/M/,m);
    f=f.replace(/dd/,z(d));f=f.replace(/d/,d);
    return f;
}


/* 
 * renderPlanningView()
 * 
 * Takes an array of campaign data and renders HTML representing the planning view for that page
 * and appends it to the DOM
 * 
 */
function renderPlanningViewYear(callback){
	/*
	 * Check the faultFlag if the data loader returned an error
	 */
	var selYear = $j('#year').text();
	var temp = [];
	var tableContainer = $j('#planningViewData');
	var displayDateClass = (displayDates) ? '' : 'hidden';
	
	for (var j = 0; j < data[selYear].length; j++) {
		var startDate = data[selYear][j].startDate;
		startDate = startDate.split(" ");
		startDate = startDate[0];
                
		var endDate = data[selYear][j].endDate;
		endDate = endDate.split(" ");
		endDate = endDate[0];
                
		var startMonth = data[selYear][j].startMonth;
		var endMonth = data[selYear][j].endMonth;
		var startYear = data[selYear][j].startYear;
		var endYear = data[selYear][j].endYear;
		var startDay = data[selYear][j].startDay;
		var endDay = data[selYear][j].endDay;
		
        /*startDate=getLocaleShortDateString(new Date(startYear,startMonth-1,startDay));
        endDate=getLocaleShortDateString(new Date(endYear,endMonth-1,endDay));*/
        startDate=data[selYear][j].startLocaleDate;
        endDate=data[selYear][j].endLocaleDate;
        
        var name = data[selYear][j].name;
		var id = data[selYear][j].id;
		//var campaignRow = $j(document.createElement('tr'));
		var rowId = 'row' + j;
		var startOffset = ((100 * startDay) / 31); //Percentage from the left
		if (startOffset > 90) 
			startOffset = 90; //Make sure there's always 10% width
		var endOffset = (100 - ((100 * endDay) / 31)); //Percentage from the right
		if (endOffset > 90) 
			endOffset = 90; //Make sure there's always 10% width
		//campaignRow.attr('id', rowId);
		//campaignRow.attr('class', 'master');
		temp[j] = '<tr id="'+rowId+'" class="master">';
		temp[j] += '<td class="name" style="text-align: left;" id="' + id + '">' + name + '</td>';
		// Out of year start, in year end
		if (startYear < selYear && endYear == selYear) {
			temp[j] += '<td><div class="tdWrapper"><div class="campaignStart campaignBracket block' + id + '" style="left: 0; background-color: '+data[selYear][j].backgroundColor+';"><div style="color:'+data[selYear][j].textColor+';" class="'+displayDateClass+' inlineTextDate textDateStart">' + startDate + '</div></div>' + '&nbsp;' + '</div></td>';
			for (i = 0; i < 13; i++) {
				if (i < endMonth - 1) {
					temp[j] += '<td><div class="tdWrapper"><div class="campaignMid block' + id + '" style="background-color: '+data[selYear][j].backgroundColor+';"></div>' + '&nbsp;' + '</div></td>';
				}
				else 
					if (i == endMonth - 1) {
						temp[j] += '<td><div class="tdWrapper"><div class="campaignEnd campaignBracket block' + id + '" style="right: ' + endOffset + '%; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' textDate textDateEnd">' + monthString(endMonth) + " " + endDay + '</div></div>' + '&nbsp;' + '</div></td>';
					}
					else {
						temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
					}
			}
		}
		// In year start, out of year end
		else 
			if (startYear == selYear && endYear > selYear) {
				temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
				for (i = 0; i < 12; i++) {
					if (i < startMonth - 1) {
						temp[j] +='<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
					}
					else 
						if (i == startMonth - 1) {
							temp[j] +='<td><div class="tdWrapper"><div class="campaignStart campaignBracket block' + id + '" style="left: ' + startOffset + '%; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' textDate textDateStart">' + monthString(startMonth) + " " + startDay + '</div></div>' + '&nbsp;' + '</div></td>';
						}
						else {
							temp[j] += '<td><div class="tdWrapper"><div class="campaignMid block' + id + '" style="background-color: '+data[selYear][j].backgroundColor+';"></div>' + '&nbsp;' + '</div></td>';
						}
				}
				temp[j] += '<td><div class="tdWrapper"><div class="campaignEnd block' + id + '" style="right: 0; background-color: '+data[selYear][j].backgroundColor+';"><div style="color:'+data[selYear][j].textColor+';" class="'+displayDateClass+' inlineTextDate textDateEnd">' + endDate + '</div></div>' + '&nbsp;' + '</div></td>';
			}
			// Out of year start and end
			else 
				if (startYear < selYear && endYear > selYear) {
					temp[j] += '<td><div class="tdWrapper"><div class="campaignStart block' + id + '" style="left: 0; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' inlineTextDate textDateStart" style="color:'+data[selYear][j].textColor+';">' + startDate + '</div></div>' + '&nbsp;' + '</div></td>';
					for (i = 0; i < 12; i++) {
						temp[j] += '<td><div class="tdWrapper"><div class="campaignMid block' + id + '" style="background-color: '+data[selYear][j].backgroundColor+';"></div>' + '&nbsp;' + '</div></td>';
					}
					temp[j] += '<td><div class="tdWrapper"><div class="campaignEnd block' + id + '" style="right: 0; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' inlineTextDate textDateEnd" style="color:'+data[selYear][j].textColor+';" >' + endDate + '</div></div>' + '&nbsp;' + '</div></td>';
				}
				// In year start and end, single month
				else 
					if (startYear == selYear && endYear == selYear && startMonth == endMonth) {
						temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
						for (i = 0; i < 12; i++) {
							if (i == startMonth - 1) {
								//temp[j] += '<td><div class="tdWrapper"><div class="campaignOne campaignBracket block' + id + '" style="left: ' + startOffset + '%; right:' + (95 - startOffset) + '%; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' textDate textDateStart">' + monthString(startMonth) + " " + startDay + '</div><div class="'+displayDateClass+' textDate textDateEnd">' + monthString(endMonth) + " " + endDay + '</div></div>' + '&nbsp;' + '</div></td>';
								temp[j] += '<td><div class="tdWrapper"><div class="campaignOne campaignBracket block' + id + '" style="left: ' + startOffset + '%; right:' + (endOffset) + '%; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' textDate textDateStart">' + monthString(startMonth) + " " + startDay + '</div><div class="'+displayDateClass+' textDate textDateEnd">' + monthString(endMonth) + " " + endDay + '</div></div>' + '&nbsp;' + '</div></td>';
							}
							else 
								temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
						}
						temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
					}
					// In year start and end, multiple months		
					else {
						temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
						for (i = 0; i < 13; i++) {
							if (i == startMonth - 1) {
								temp[j] += '<td><div class="tdWrapper"><div class="campaignStart campaignBracket block' + id + '" style="left: ' + startOffset + '%; background-color: '+data[selYear][j].backgroundColor+';+"><div class="'+displayDateClass+' textDate textDateStart">' + monthString(startMonth) + " " + startDay + '</div></div>' + '&nbsp;' + '</div></td>';
							}
							else 
								if (i > startMonth - 1 && i < endMonth - 1) {
									temp[j] += '<td><div class="tdWrapper"><div class="campaignMid block' + id + '" style="background-color: '+data[selYear][j].backgroundColor+';"></div>' + '&nbsp;' + '</div></td>';
								}
								else 
									if (i == endMonth - 1) {
										temp[j] += '<td><div class="tdWrapper"><div class="campaignEnd campaignBracket block' + id + '" style="right: ' + endOffset + '%; background-color: '+data[selYear][j].backgroundColor+';"><div class="'+displayDateClass+' textDate textDateEnd">' + monthString(endMonth) + " " + endDay + '</div></div>' + '&nbsp;' + '</div></td>';
									}
									else 
										temp[j] += '<td><div class="tdWrapper">' + '&nbsp;' + '</div></td>';
						}
					}
		var descriptionLength = data[selYear][j].description.length;
		var campaignDescription = data[selYear][j].description;
		if (descriptionLength > 90) {
			campaignDescription = campaignDescription.substring(0, 75) + '&hellip; <span class="readMore">Read More</span>';
		}
		temp[j] += '<td class="click" id="' + id + '"><div style="max-height: 60px; overflow: hidden; text-align: left;">' + campaignDescription + '</div></td>';
		temp[j] += '</tr>';
		
		if((j % 25) == 0){
			tableContainer.append(temp.join(''));
			temp = []; //clear the array
		}
	}
	
	//append the last 25 records
	tableContainer.append(temp.join(''));
	temp = []; //clear the array
	
	//after the loop append the data
	
	// Handling for when the description is clicked.
	$j('.click').click(function(){
		campaignID = $j(this).attr('id');
		dialog = $j.FrameDialog.create({
			url: campaignDescriptionPage + '?Id=' + campaignID,
			title: "Description",
			buttons: false,
			minHeight: 300,
			minWidth: 400
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});
	
	// Handling for when the campaign name is clicked.
	$j('.name').click(function(){
		campaignID = $j(this).attr('id');
		dialog = $j.FrameDialog.create({
			url: campaignEditPage + '?Id=' + campaignID,
			buttons: false,
			title: "",
			minHeight: 580,
			minWidth: 835
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});
	
	// Handling for when a date block is clicked.
	$j('.campaignStart').click(function(){
		campaignID = $j(this).attr('class').campaignID = $j(this).attr('class').replace("campaignOne","").replace("campaignStart","").replace("campaignMid","").replace("campaignEnd","").replace("campaignBracket","").replace("block","").replace(/\s/g,"");
		dialog = $j.FrameDialog.create({
			url: campaignEditPage + '?Id=' + campaignID,
			buttons: false,
			title: "",
			minHeight: 580,
			minWidth: 835
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});
	
	$j('.campaignMid').click(function(){
		campaignID = $j(this).attr('class').replace("campaignOne","").replace("campaignStart","").replace("campaignMid","").replace("campaignEnd","").replace("campaignBracket","").replace("block","").replace(/\s/g,"");
		dialog = $j.FrameDialog.create({
			url: campaignEditPage + '?Id=' + campaignID,
			buttons: false,
			title: "",
			minHeight: 580,
			minWidth: 835
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});
	
	$j('.campaignEnd').click(function(){
		campaignID = $j(this).attr('class').replace("campaignOne","").replace("campaignStart","").replace("campaignMid","").replace("campaignEnd","").replace("campaignBracket","").replace("block","").replace(/\s/g,"");
		dialog = $j.FrameDialog.create({
			url: campaignEditPage + '?Id=' + campaignID,
			buttons: false,
			title: "",
			minHeight: 580,
			minWidth: 835
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});
	$j('.campaignOne').click(function(){
		campaignID = $j(this).attr('class').replace("campaignOne","").replace("campaignStart","").replace("campaignMid","").replace("campaignEnd","").replace("campaignBracket","").replace("block","").replace(/\s/g,"");
		dialog = $j.FrameDialog.create({
			url: campaignEditPage + '?Id=' + campaignID,
			buttons: false,
			title: "",
			minHeight: 580,
			minWidth: 835
		});
		$j('.ui-dialog-content').mask('Loading...');
		return false;
	});

	// hover intent	 
	var config = {   
	 interval: 175,
     over: function(){  
		if(!displayDates){
			$j(this).children().find('.textDate, .inlineTextDate').removeClass('hidden');
		}	
	 }, // function = onMouseOver callback (REQUIRED)    
     timeout: 0, // number = milliseconds delay before onMouseOut    
     out: function(){
	 			if(!displayDates){
			$j(this).children().find('.textDate, .inlineTextDate').addClass('hidden');
		}
	 } // function = onMouseOut callback (REQUIRED)    
	};
	 
	$j('tr.master').hoverIntent(config);

	callback();
}

function monthString(i){
	months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
	return months[i - 1];
}

function attachPageClickHandlers(){	
	    // Handle the new campaign button lightbox
    $j('.newCampaignButton').click(function() {
        dialog = $j.FrameDialog.create({
            url: campaignNewPage,
			title: "",
            buttons: false,
            minHeight: 580,
            minWidth: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;
    });
	
	// Handle the feedback button lightboxw
    $j('.bracketLabsFeedbackButton').click(function() {
        dialog = $j.FrameDialog.create({
            url: feedbackPage,
			title: "",
            buttons: false,
            minHeight: 580,
            minWidth: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;
    });
	
	$j('.colorSettingsButton').click(function(){
        dialog = $j.FrameDialog.create({
            url: colorSettingsPage,
			title: "",
            buttons: false,
            minHeight: 580,
            minWidth: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;		
	});
	
	/*
	 * Move the page text that contains the year to the previous year
	 */
	$j('.campaignCalendarPrevButton').click(function(e){
		e.preventDefault();
		var currentYear = parseInt($j('#year').text());	
		$j('#year').text(currentYear-1);
		//renderView();
		loadAndRenderCampaignData('Loading...');
	});
	
	/*
	 * Move the page text that contains the year to the next year
	 */		
	$j('.campaignCalendarNextButton').click(function(e){
		e.preventDefault();
		var currentYear = parseInt($j('#year').text());	
		$j('#year').text(currentYear+1);
		//renderView();
		loadAndRenderCampaignData('Loading...');
	});	
}

/**
 * Update a user's chatter status.
 * 9/15/2011 - Jordan, Can be moved to shared.
 */
function updateChatterStatus() {
	CAMPAIGNCAL.ccPlanningViewController.updateChatterStatus($j('#campaignCalendarPublisherField').val(),function(event,result){
			if(result.status == true){
			    var statusField = $j('#campaignCalendarPublisherField');
				statusField.val(""), statusField.blur(), showMaskMessage("Your chatter status has been updated.", "body", "loadmask-top loadmask-warning", 2500)
			    statusField.val('');
			    statusField.blur();
			    showMaskMessage('Your chatter status has been updated.', 'body', 'loadmask-top loadmask-warning', 2500);
			}
			else{
				errorArray.push(result);
				showMaskMessage('The Chatter status update failed, please ensure you are logged in and connected to the Internet.</br></br> Would you like to send an error report to Bracket Labs?</br></br><input class="btn" onclick="$j(\'.bracketLabsFeedbackButton\').click();" value="Report An Error" style="width:100px; text-align: center;"/>&nbsp;&nbsp;<input class="btn" onclick="$j(\'#planningView\').unmask();" value="Dismiss" style="width:100px; text-align: center;">', '#planningView', 'loadmask-top loadmask-error', 0);	
			}
	});
}

/**
 * Display a warning or error message to the user.
 */
function showMaskMessage(text, element, classNames, timeout) {
    $j(element).addClass(classNames);
    $j(element).mask(text);
	if (timeout > 0) {
        setTimeout(function() {
            $j(element).unmask();
            $j(element).removeClass(classNames);
        }, timeout);
    }
}

/*
 * 
 */
function toggleShowDates(checkBox){
	CAMPAIGNCAL.ccPlanningViewController.toggleDisplayDates(
		$j(checkBox).is(':checked')
	,function(event, result){
		var showHide = '';
		var textdate = $j('.textDate'); //get all the textdate selectors on the 
		//page into a single list
		var length = textdate.length;
		var index = 0;
		
		if (!$j(checkBox).is(':checked')) {
			$j('.inlineTextDate').addClass('hidden');
			displayDates = false;
			var process = function(){
				$j('.inlineTextDate').addClass('hidden');
				for (; index < length; index++) {
					var toProcess = textdate[index];
					// Perform xml processing
					$j(toProcess).addClass('hidden');
					if (index + 1 < length && index % 25 == 0) {
						setTimeout(process, 5);
					}
				}
			};
		}
		else {
			var process = function(){
				displayDates = true;
				$j('.inlineTextDate').removeClass('hidden');
				for (; index < length; index++) {
					var toProcess = textdate[index];
					// Perform xml processing
					$j(toProcess).removeClass('hidden');
					if (index + 1 < length && index % 25 == 0) {
						setTimeout(process, 5);
					}
				}
			};
		}
		process();
	},{escape:true});
}
