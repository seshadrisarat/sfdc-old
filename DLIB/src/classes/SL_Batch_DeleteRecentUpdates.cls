/*
* Class Name    : SL_Batch_DeleteRecentUpdates
* JIRA Ticket   : Socint-281
* Created on    : 29/11/2013
* Created by    : Sruti
* Jira ticket   : http://silverline.jira.com/browse/Socint-281
* Description   : It deletes recent update records which are last modified before the Date given in Custom setting SL_NoOfDays_RecentUpdates__c
*/

global without sharing class SL_Batch_DeleteRecentUpdates implements Database.Batchable<Sobject>
{
    /*  Start : Constructor */
    public SL_Batch_DeleteRecentUpdates( )  
    {
    }

    /*
        @MethodName : start 
        @param      : Database.BatchableContext BC
        @Description: Queries Recent Updates records 
    */
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        //Getting pagination value for number of records needs to display per page for Recent Updates.
        List<SL_IntranetApplicationSetting__c> lstPagination = [SELECT Recent_Updates_Days_Threshold__c 
                                                                    FROM SL_IntranetApplicationSetting__c 
                                                                    where name = 'Default Settings' limit 1];
        
        Date deleteRecentDataAfter;// Date after which delete Recent records should be deleted
        
        if(lstPagination != null && !lstPagination.isEmpty())
            deleteRecentDataAfter = lstPagination[0].Recent_Updates_Days_Threshold__c != null? Date.today().addDays(- Integer.valueOf(lstPagination[0].Recent_Updates_Days_Threshold__c)) :  Date.today().addDays(-10);
        else
            deleteRecentDataAfter = Date.today().addDays(-10);
         
        string strQuery = 'SELECT Id, Last_Updated__c, Related_To__c FROM Recent_Updates__c '+
                                        'WHERE Last_Updated__c <= :deleteRecentDataAfter'; // Querying list of Recent Data records to delete 
        return Database.getQueryLocator(strQuery);
    }
    /*
        @MethodName : execute 
        @param      : Database.BatchableContext BC, List<Recent_Updates__c> lstRecentUpdates
        @Description: Processes the Recent Updates records recieved from the Start method in batches
    */
    global void execute(Database.BatchableContext BC, List<Recent_Updates__c> lstRecentUpdates)
    {
       if(lstRecentUpdates != null && !lstRecentUpdates.isEmpty())
            delete lstRecentUpdates;
    }

    
    /*
        @MethodName : finish 
        @param      : Database.BatchableContext BC
        @Description: Performs the post-execution steps
    */
    global void finish(Database.BatchableContext BC)
    {
        //Do nothing
    }
}