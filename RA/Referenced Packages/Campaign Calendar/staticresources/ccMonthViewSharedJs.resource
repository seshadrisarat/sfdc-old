/* 
 * sfdcEventFeed
 * JQuery Extension to invoke @RemoteAction method and return events array
 * to the fullCalendar plugin. 
 * This function was previously in it's own file, but has been moved here in an effort to
 * expedite development in the process of refactoring for Javascript remoting from
 * the previously used 'WebService' annotation. 
 * 
 * Added some shared variables for error array to this file - Jordan, 2/28/2012
 */

var errorArray = [];	//array for storing error messages from the server

(function($) {
    $.fullCalendar.sfdcEventFeed = function(options) {
        options = options || {};

    return function(start, end, callback) {
        // Retrieve the campaigns for the dates being displayed
        if (blccFilterId == null || blccFilterId == '') {
                    // No list view selected
                    showMaskMessage('Please select a list view above', '#blccCalendar', 'loadmask-warning', 0);
		}
		else{
       	CAMPAIGNCAL.ccMonthViewController.getCampaigns(blccFilterId, function(e,result){
			if(result.status == true){	
	           	var events = [];
	            $.each(result.result, function(i, event) {
			event.name=$j('<div/>').html(event.name).text();
	                events.push({
	                    id: event.id,
	                    title: event.name,
	                    start: new Date(event.startYear, event.startMonth-1, event.startDay, 0, 0, 0, 0),
	                    end: new Date(event.endYear, event.endMonth-1, event.endDay, 0, 0, 0, 0),
	                    allDay: true,
	                    type: event.campaignType,
	                    status: event.campaignStatus,
	                    ownerPhoto: event.ownerPhoto,
	                    ownerName: event.ownerName,
	                    numberOfLeads: event.numberOfLeads,
	                    numberOfContacts: event.numberOfContacts,
	                    numberOfOpportunities: event.numberOfOpportunities,
	                    AmountAllOpportunities: event.AmountAllOpportunities,
	                    textColor: event.textColor,
	                    backgroundColor: event.color,
	                    borderColor: event.borderColor,
	                    className: options.className,
	                    editable: options.editable || true,
	                    total: event.total
	                });
	            });
	            $j('#blccCalendar').unmask();
            	if(events.length >= 2000){
            			showMaskMessage('Some campaigns may be not be shown.<br />Please select a list view that contains less than 2,000 campaigns.', '#blccCalendar', 'loadmask-warning', 5000);
            	}
            	callback(events);	
	           }
	           else{
   		            $j('#blccCalendar').unmask();
		           	errorArray.push(result);
		           	if(!isPrintView){
		           		showMaskMessage('An error occured fetching information from the server.</br></br> Would you like to send an error report to Bracket Labs?</br></br><input class="btn" onclick="$j(\'.bracketLabsFeedbackButton\').click();" value="Report An Error" style="width:100px; text-align: center;"/>&nbsp;&nbsp;<input class="btn" onclick="$j(\'#blccCalendar\').unmask();" value="Dismiss" style="width:100px; text-align: center;">', '#blccCalendar', 'loadmask-top loadmask-error', 0);
		           	}
		           	else{
		           		showMaskMessage('An error occured fetching information from the server. </br></br>Please close this pop-up, and try refreshing your list view.','body', 'loadmask-top loadmask-error', 0);
		           	}
	           }
           	});
           }
    	}
	}
})(jQuery);
