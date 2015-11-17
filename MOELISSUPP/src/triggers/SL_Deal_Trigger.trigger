/*Trigger on Ibanking_Project__c
* Trigger Name  : SL_Deal
* JIRA Ticket   : Moelis-115
* Created on    : 18/11/2013
* Created by    : Rahul Majumdar
* Jira ticket   :  http://silverline.jira.com/browse/Moelis-115
* Description   : When a Deal record is inserted, insert an Recent_Transaction_Announcements__c record . and When any of the following field is updated on Deal record , update the corresponding field in Recent_Transaction_Announcements__c record .
*/
trigger SL_Deal_Trigger on Ibanking_Project__c (after insert, after update, before delete) 
{
    // initialize the handler class Sl_Deal_Handler
    Sl_DealHandler handler = new Sl_DealHandler(Trigger.isExecuting, Trigger.size);
    
    // called on After Update of Deal record. 
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        if( SL_RecursionHelper.getisUpdate())
        {
            SL_RecursionHelper.setisUpdate(false);
            handler.onAfterUpdate( Trigger.newMap,Trigger.oldMap);
        }
    }
    
    // called on After Delete of Deal Record
    if(Trigger.isBefore && Trigger.isDelete)
    {
        if( SL_RecursionHelper.getisUpdate())
        {
            SL_RecursionHelper.setisUpdate(false);
            handler.onBeforeDelete(Trigger.oldMap);
        }   
    }
}