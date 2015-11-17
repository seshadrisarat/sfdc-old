/*
 * Provides Bracket Labs Campaign Calendar functionality and related
 * event handlers.
 *	Jordan, 9/28/11 - 	Added '.pageTitleIcon' URL set due to some unexpected behavior with
 *						the icon in Winter '12 Dev. preview. Also note, that unobfascated code
 *						may not contain some hotfixes that are present in obfascated packaged
 *						Javascript, when using this code until otherwise noted, be sure to 
 *						check for regression error.
 *						Moved jQuery shortcut from '$' to '$j'
 *						
 */
beenFocused = true;
var blccFilterId;
var lastFaultCode;
var dialog;
var loadText = 'Loading...';
var qtipTimeout;
var suspendTooltips = false;

/**
 * Load and render the calendar after page load
 */ 
var $j = jQuery.noConflict();
$j(document).ready(function() {
	if($j.cookie('apex__blccView') == 'planningView')
	{
		window.location = planningView;
	}
	
    if ($j('#blccCalendar').length > 0) {
        blccCalendar();
    }
    blccInitHandlers();	
	$j('.pageTitleIcon').attr('src',campaignCalendarIcon);
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
        aspectRatio: 1.4,
        disableDragging: disableDragging,
        weekMode: 'liquid',
        //firstDay: (blccStartOfWeek != null) ? blccStartOfWeek : 0,
        selectable: true,
        selectHelper: true,
        editable: true,
        loading: function(isLoading, view) {
            if (isLoading) {
                // Begin loading from SFDC
					$j('#blccCalendar').mask(loadText);
            }
          },
    	fetchDelay: 225,
    	refetchDateRange: false,
        events: $j.fullCalendar.sfdcEventFeed(),
        eventClick: function(event, jsEvent, view) {
            dialog = $j.FrameDialog.create({
                url: campaignEditPage + '?Id=' + event.id,
                buttons: false,
                height: 580,
                width: 835
            });
            $j('.ui-dialog-content').mask('Loading...');
            return false;
        },
       eventMouseover: function(event, jsEvent, view) {
        },

        eventDragStart: function(event, jsEvent, ui, view) {
            suspendTooltips = true;
        },
        eventDragStop: function(event, jsEvent, ui, view) {
            suspendTooltips = false;
        },
        /*
         * Changing to remote methods, changes the way we handle responses and errors, Jordan 2/7/2012
         */
        eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc, jsEvent, ui, view) {
            updateEventStartEndDate(event);	
        },
        eventResizeStart: function(event, jsEvent, ui, view) {
            suspendTooltips = true;
        },
        eventResizeStop: function(event, jsEvent, ui, view) {
            suspendTooltips = false;
        },
        eventResize: function(event, dayDelta, minuteDelta, revertFunc, jsEvent, ui, view) {
            updateEventStartEndDate(event);	
        },
        select: function(start, end, allDay) {
            dialog = $j.FrameDialog.create({
                url: campaignNewPage + '?startDate=' + start.getTime() + '&endDate=' + end.getTime(),
                buttons: false,
                height: 580,
                width: 835
            });
            $j('.ui-dialog-content').mask('Loading...');
            $j('#blccCalendar').fullCalendar('unselect');
        }
    });

    // Handle the previous month button
    $j('.campaignCalendarPrevButton').click(function() {
        $j('#blccCalendar').fullCalendar('prev');
        updateCalendarHeading();
        return false;
    });

    // Handle the next month button
    $j('.campaignCalendarNextButton').click(function() {
        $j('#blccCalendar').fullCalendar('next');
        updateCalendarHeading();
        return false;
    });
    
    // Current month button
    $j('.campaignCalendarThisMonthButton').click(function() {
        $j('#blccCalendar').fullCalendar('today');
        updateCalendarHeading();
        return false;
    });
    
    /*
     * Date field select
    *	Upgrade to @RemoteAction, encapsulate normalized date into the function
     */
    $j('#campaignCalendarDateField').change(function() {
        CAMPAIGNCAL.ccMonthViewController.getNormalizedDate($j(this).val(), function(e,result){
        	if(result.status == true){
	        	var myDate = new Date(parseInt(result.result));
	            loadText = 'Loading...';
	            $j('#blccCalendar').fullCalendar('gotoDate', myDate.getFullYear(), myDate.getMonth(), myDate.getDate());
	            updateCalendarHeading();
           }
        });
    });
}

/**
 * Initialize extra calendar handlers.
 */
function blccInitHandlers() {
    // Handle the new campaign button lightbox
    $j('.newCampaignButton').click(function() {
        dialog = $j.FrameDialog.create({
            url: campaignNewPage,
            buttons: false,
            height: 580,
            width: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;
    });

    // Handle the campaign calendar settings button lightbox
    $j('.colorSettingsButton').click(function() {
        dialog = $j.FrameDialog.create({
            url: colorSettingsPage,
            buttons: false,
            height: 580,
            width: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;
    });

    // Handle the feedback button lightbox
    $j('.bracketLabsFeedbackButton').click(function() {
        dialog = $j.FrameDialog.create({
            url: feedbackPage,
            buttons: false,
            height: 580,
            width: 835
        });
        $j('.ui-dialog-content').mask('Loading...');
        return false;
    });
	
	/**
	 *	Manage URL Parameters necessary to print the calendar
	 */
	 
	$j('.campaignCalendarPrintButton').click(function(e){
		e.preventDefault();
		var myDate = $j('#blccCalendar').fullCalendar('getDate');
		var myDateString = $j.fullCalendar.formatDate(myDate, 'MMMM yyyy');
		var querystring = new Array();
		querystring = myDateString.split(' ');
		var url = calendarPage + '?pCalMonth=' + querystring[0] + '&pCalYear=' + querystring[1] + '&filterId=' + blccFilterId;
		var printWindow = window.open(url,'','scrollbars=1,status=0,width=1000,height=900'); 
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
	$j('#blccCalendar').mask(loadText);
	$j('#blccCalendar').removeClass('loadmask-warning');
	$j("#blccCalendar").fullCalendar("refetchEvents")
}

/**
 * Call out to Salesforce-based web service to update a single
 * event's start and stop dates.
 */ 
function updateEventStartEndDate(event) {
	var startDate = event.start.getFullYear()+"-"+event.start.getMonth()+"-"+event.start.getDate();
	var endDate = (event.end != null) ? event.end.getFullYear()+"-"+event.end.getMonth()+"-"+event.end.getDate() : startDate;
    var result;
    // hit the @RemoteAction to update the event
    CAMPAIGNCAL.ccMonthViewController.updateCampaignStartEndDate(event.id,startDate,endDate, function(e,result){
    	/* 
    	 *	Error handling 
    	 */
    	if(result.status != true){
		    revertFunc();
			errorArray.push(result);
    		showMaskMessage('Failed to update the campaign start/end dates, please ensure you are logged in and connected to the Internet.</br></br> Would you like to send an error report to Bracket Labs?</br></br><input class="btn" onclick="$j(\'.bracketLabsFeedbackButton\').click();" value="Report An Error" style="width:100px; text-align: center;"/>&nbsp;&nbsp;<input class="btn" onclick="$j(\'#blccCalendar\').unmask();" value="Dismiss" style="width:100px; text-align: center;">', '#blccCalendar', 'loadmask-top loadmask-error', 0);	
    	}
    });
}

/**
 * Update a user's chatter status.
 * Update to @RemoteAction, Jordan 2/7/2012
 */
function updateChatterStatus() {
	CAMPAIGNCAL.ccMonthViewController.updateChatterStatus($j('#campaignCalendarPublisherField').val(),function(e,result){
		if(result.status == true){
			var statusField = $j('#campaignCalendarPublisherField');
		    statusField.val('');
    		statusField.blur();
		    showMaskMessage('Your chatter status has been updated.', 'body', 'loadmask-top loadmask-warning', 2500);
		}
		else{
			errorArray.push(result);
			showMaskMessage('The Chatter status update failed, please ensure you are logged in and connected to the Internet.</br></br> Would you like to send an error report to Bracket Labs?</br></br><input class="btn" onclick="$j(\'.bracketLabsFeedbackButton\').click();" value="Report An Error" style="width:100px; text-align: center;"/>&nbsp;&nbsp;<input class="btn" onclick="$j(\'#blccCalendar\').unmask();" value="Dismiss" style="width:100px; text-align: center;">', '#blccCalendar', 'loadmask-top loadmask-error', 0);	
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
