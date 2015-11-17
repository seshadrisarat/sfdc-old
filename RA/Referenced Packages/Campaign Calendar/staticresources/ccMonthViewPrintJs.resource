/*
 * Provides Bracket Labs Campaign Calendar functionality and related
 * event handlers.
 */

beenFocused = true;
var blccFilterId;
var lastFaultCode;
var dialog;
var loadText = 'Loading...';
var qtipTimeout;
var suspendTooltips = false;
var calendarContentHeight = 900;

/**
 * Load and render the calendar after page load
 */
var $j = jQuery.noConflict();
$j(document).ready(function() {
	$j('#blccCalendar').addClass('calendarPrintPortrait');
    if ($j('#blccCalendar').length > 0) {
        blccCalendar();
			// remove non-needed formatting to make calendar presentable for formatting
		SetToDate(); 
    }
	
	/* Jordan, Bracket Labs, 
	 *	4/14/2011 -	Set the height *AFTER* the calendar has rendered on initial 
	 * 				page load, this 'removes' whitespace on non-filled weeks.
	 */
	$j('#blccCalendar').fullCalendar('option', 'contentHeight', 100);
});

/**
 * Construct the calendar view and render it into the document page.
 */
function blccCalendar() {
    $j('#blccCalendar').fullCalendar({
        theme: true,
        header: '',
    	columnFormat: {
    		month: 'dddd'
		},
		//contentHeight: calendarContentHeight,
		aspectRatio: 1.4,
        weekMode: 'liquid',
		disableDragging: true,
        selectable: true,
        selectHelper: true,
        editable: true,
        loading: function(isLoading, view) {
            if (isLoading) {
                // Begin loading from SFDC
                $j('#blccCalendar').mask(loadText);
            } else {
                // End loading from SFDC
                $j('#blccCalendar').unmask();
                if (blccFilterId == null || blccFilterId == '') {
                    // No list view selected
                    showMaskMessage('Please select a list view above', '#blccCalendar', 'loadmask-warning', 0);
                }
            }
        },
    	fetchDelay: 225,
    	refetchDateRange: false,
        events: $j.fullCalendar.sfdcEventFeed(),
        eventClick: function() {
            return false;
        },
        eventMouseover: function() {
			return false;
        },
        eventDragStart: function() {
            return false;
        },
        eventDragStop: function() {
            suspendTooltips = false;
        },
        eventDrop: function() {
            return false;
        },
        eventResizeStart: function() {
            return false;
        },
        eventResizeStop: function() {
            return false;
        },
        eventResize: function() {
            return false;
        },
        select: function() {
            return false;
        }
    });
}

/**
 * Update the calendar heading.
 */
function updateCalendarHeading() {
    var myDate = $j('#blccCalendar').fullCalendar('getDate');
    $j('.pageDescription').html($j.fullCalendar.formatDate(myDate, 'MMMM yyyy'));
}

/**
 * Reload the campaign data.
 */
function updateCalendar(filterId) {
    blccFilterId = filterId;
    $j('#blccCalendar').unmask();
    $j('#blccCalendar').removeClass('loadmask-warning loadmask-error');
    loadText = 'Loading...';
    $j('#blccCalendar').fullCalendar('refetchEvents');
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

function SetToDate() {
	var urlParams = {};
	(function () {
		var e,
			a = /\+/g,  // Regex for replacing addition symbol with a space
			r = /([^&=]+)=?([^&]*)/g,
			d = function (s) { return decodeURIComponent(s.replace(a, " ")); },
			q = window.location.search.substring(1);
	
		while (e = r.exec(q))
		   urlParams[d(e[1])] = d(e[2]);
	})();
	var monthMap = {"January": 0, "February": 1, "March": 2, "April":3, "May":4, "June":5, "July":6, "August":7, "September":8, "October":9, "November":10, "December":11};
	$j("#blccCalendar").fullCalendar("gotoDate", urlParams.pCalYear, monthMap[urlParams.pCalMonth], "1"); //advance the calandar to the correct date
	updateCalendarHeading()
	//$j("#blccCalendar").fullCalendar("refetchEvents")
}; 


//We will use querystrings to advance the calendar and set the page to the right place when the printview opens.
function getParameterByName( name )
{
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}


/*  Jordan, Bracket Labs
 *	4/14/2011- 	Set the calendar height *AFTER* the calendar has finished rendering incase
 * 				of a large amount of events without rolling onto two pages 
 */ 
function setPageOrientation(){
		// Landscape -> Portrait
		if( $j('#blccCalendar').hasClass('calendarPrintPortrait') )
		{
			$j('#CampaignCalendarPrint').css('width','33.5cm');
			$j('.printTableHeader').css('width','33.5cm');
			$j('#blccCalendar').removeClass('calendarPrintPortrait');
			$j('#blccCalendar').addClass('calendarPrintLandscape');
			$j('#blccCalendar').fullCalendar('rerender');
			$j('#blccCalendar').fullCalendar('option', 'contentHeight', 100);	
		}
		// Portrait -> Landscape
		else if( $j('#blccCalendar').hasClass('calendarPrintLandscape'))
		{
			$j('#CampaignCalendarPrint').css('width','25cm');
			$j('.printTableHeader').css('width','25cm');			
			$j('#blccCalendar').removeClass('calendarPrintLandscape');
			$j('#blccCalendar').addClass('calendarPrintPortrait');
			$j('#blccCalendar').fullCalendar('rerender');
			$j('#blccCalendar').fullCalendar('option', 'contentHeight', 100);		
		}
}
