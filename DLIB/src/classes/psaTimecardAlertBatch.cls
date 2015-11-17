/****************************************************************************************
Name            : psaTimecardAlertBatch
Author          : CLD
Created Date    : April 17, 2013
Description     : Contains methods for batch processing Timecard Alert functionality.
                : 
******************************************************************************************/
global class psaTimecardAlertBatch implements Database.Batchable<sObject>, Database.Stateful
{

    private Integer DAYS_TO_CALCULATE = 90;
    private date CURRENT_DATE = date.Today();
    public String query = 'SELECT id, name FROM Contact Where pse__Is_Resource__c = TRUE and pse__Is_Resource_Active__c = TRUE'; 

    /****************************************************************************
    * This method is required for batchable Apex.  
    * It's where we set the query that is used to get the Resource records... 
    * It sets up the Exectute() method
    ****************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        // Batch on all active PSA Resoruce records
        system.debug('**** psaTimecardAlertBatch executeBatch()');
        return Database.getQueryLocator(query);
    }
    
    /****************************************************************************
    * This method is REQUIRED for batchable Apex and is where we loop through the 
    * results of the query specified in the execte() method 
    *****************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        integer recordCount;
        system.debug('**** psaTimecardAlertBatch(scope): ' + scope);
        integer cntr = 1;
        for(Sobject s : scope)
        {
            System.debug('***** Calculating Timecard Hours for record #:  ' + cntr);
            cntr++;
            // Note: In order to use the Name field we need to cast the generic Sobject refernce to the 
            // Contact object that we queried in the Start() method
            Contact r = (Contact)s;
            system.debug('**** execute() START CALC -> Id: ' + r.Id + '  ' + r.name + ' ' + ' CURRENT_DATE: ' + CURRENT_DATE);
            recordCount = psaTimecardAlert.calculateResourceTimecardHours(CURRENT_DATE, r.Id);
            System.debug('***** calculating Timecard Hours for Resource: ' + r.Name);
            system.debug('**** execute() END CALC ->  recordCount: ' + recordCount);
        }
        
    }
    
    /****************************************************************************
    * This method is REQUIRED for batchable Apex... It puts some results in the log
    *
    *****************************************************************************/
    global void finish(Database.BatchableContext BC)
    {
       // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext. 
       // Query the AsyncApexJob object to retrieve the current job's information. 
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
    
       // log Apex job details
       system.debug('**** psaTimecardAlertBatch Finish()  status: ' + a.status + ' Total Jobs: ' + a.TotalJobItems + ' Errors: ' + a.NumberOfErrors);
     
    }
}