/**
* @ClassName    : SL_SchedulerBatchOnRecentUpdates
* @JIRATicket   : Socint-281
* @CreatedOn    : 29/nov/2013
* @ModifiedBy   : SL
* @Description  : Schedular for SL_BatchOnRecentUpdates batch
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
global without sharing class SL_SchedulerBatchOnRecentUpdates implements Schedulable
{
    //This Class calls Batch class
    global void execute(SchedulableContext sc)
    {
        // An instance of a SL_Batch_DeleteRecentUpdates Class created  
        SL_Batch_DeleteRecentUpdates objBatch = new SL_Batch_DeleteRecentUpdates();
        // Database.executeBatch method called to begin a batch job.
        Database.executeBatch(objBatch, 100);
            
    }
}