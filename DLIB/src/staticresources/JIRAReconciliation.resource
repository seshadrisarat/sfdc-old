
Visualforce.remoting.timeout = 120000; 

var res_size = 0;
var ind = 0;
function refresh() {
        res_size = 0;
        ind = 0;
        jQuery('.actionstatus').css('display','block');
        var startdate = formatDate(jQuery('.startdate').val());
        var origdate = new Date(jQuery('.startdate').val());
        var enddate = new Date(jQuery('.startdate').val());
        enddate.setDate(enddate.getDate() + 7);
        enddate = formatDate(enddate);
        console.log('---startdate='+startdate);
        console.log('---enddate='+enddate);
        var jqlSearchString = 'issue in workedIssues(' + startdate + ', ' + enddate + ', developers)';
        var sumHours = 0;
        
         SL_JIRAReconciliationScreenController.getWorklogInfo(
            startdate, enddate,
            function(results, event){
                if (typeof results === 'undefined') {
                    jQuery('.actionstatus').css('display','none');
                    alert('Unable to connect to the server (transaction aborted: timeout)');
                    return;
               }
               res_size = results.length;
                for(var w = 0; w < results.length; w++) {
                    worklog = results[w];
                    sumHours = jQuery('.'+worklog.milestonecontact).text()*1.00;
                    sumHours = sumHours + worklog.timeSpentHours*1.00;
                    jQuery('.'+worklog.milestonecontact).text(sumHours);
                }
                checkRemoteFinish();

    });
}

function submitTS() {
    var tr = jQuery('.tblResult').find('tr');
    var jiraHours = 0;
    var timecardHours = 0;
    var diff = 0;
    var a = new SObjectModel.timecards();
    jQuery.each(tr, function(index, item) {

        var chbApproved = jQuery(this).find('input[type="checkbox"]');
        console.log(chbApproved.attr('checked'));
        if (chbApproved.attr("disabled")!=true && chbApproved.attr('checked') == "checked") {

            var Id = chbApproved.parentElement.parentElement.parentElement.children[0].getAttribute('data-value');
            a.update(Id,{Id: Id, pse__submitted__c: true, pse__status__c: 'Submitted'});
        }
    });
}

function checkRemoteFinish() {
    jQuery('.actionstatus').css('display','none');
    checkIsEnabledApprove();
}
    
function checkIsEnabledApprove() {
    var tr = jQuery('.tblResult').find('tr');
    var jiraHours = 0;
    var timecardHours = 0;
    var diff = 0;
    var chbApproved;
    jQuery.each(tr, function(index, item) {
        chbApproved = jQuery(this).find('input[type="checkbox"]');
        if (chbApproved.attr("disabled")!=true) chbApproved.attr("disabled", true);
        var tds = jQuery(this).find('td');
            try {
                jQuery.each(tds, function(index, item) {
                    if (index==3) jiraHours = jQuery(this).find('span').text();
                    if (index==5) timecardHours = item.innerHTML;
                });
                diff = timecardHours - jiraHours;
                if (diff==0 && chbApproved.attr("checked")!='checked')  chbApproved.removeAttr("disabled");
            } catch (e) {
            }
        });
}
    
function formatDate(dateObject) {
    var d = new Date(dateObject);
    var day = d.getDate();
    var month = d.getMonth() + 1;
    var year = d.getFullYear();
    if (day < 10) {
        day = "0" + day;
    }
    if (month < 10) {
        month = "0" + month;
    }
    var date = year + "-" + month + "-" + day + 'T00:00:00';
    return date;
};