/**
* @ClassName    : SL_SchedulerBatchOnRecentUpdates
* @JIRATicket   : Socint-281
* @CreatedOn    : 29/nov/2013
* @ModifiedBy   : SL
* @Description  : Schedular for SL_SchedulerBatchOnRecentUpdates batch
*/

/**
@Developer Name                         : Sruti
Percentage of best practices followed   : 100%
No of SOQL queries used                 : 0
No of collections used                  : 0
Exception Handling implemented          : Yes
Coding standards followed               : Yes
Naming conventions followed             : Yes
Third party integrations                : No
Maximum of No of records tested with    : 
Customer Approval                       : 
Last Modified Date                      : 
Approved by                             : 

*/
public with sharing class SL_BatchSchedule_DeleteRecentUpdates {
//This class calls Schedular
    public SL_BatchSchedule_DeleteRecentUpdates()
    {
        SL_SchedulerBatchOnRecentUpdates batchSchedule = new SL_SchedulerBatchOnRecentUpdates();
        String scheduleBatch = '0 0 10 * * ?';
        System.schedule('Delete Recent Updates', scheduleBatch, batchSchedule);
    }
}