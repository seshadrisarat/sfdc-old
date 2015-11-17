/**  
* \arg TriggerName    : SL_MonthEndBalance
* \arg JIRATicket     : OAKHILL-15
* \arg CreatedOn      : 22/OCT/2014
* \arg LastModifiedOn : 22/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger is used to update the related account records with the corresponding most recent month end balance record value
*/
trigger SL_MonthEndBalance on Month_End_Balance__c (after delete, after insert, after undelete, 
after update) 
{
    SL_MonthEndBalanceHandler objMonthEndBalanceHandler = new SL_MonthEndBalanceHandler();
    //checking if trigger event is after
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            objMonthEndBalanceHandler.onAfterInsert(Trigger.new);//calling method to update records on after insert
        if(Trigger.isUpdate)
            objMonthEndBalanceHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);//calling method to update records on after update
        if(Trigger.isDelete)
            objMonthEndBalanceHandler.onAfterDelete(Trigger.old);//calling method to update records on after delete
        if(Trigger.isUnDelete)
            objMonthEndBalanceHandler.onAfterUndelete(Trigger.new);//calling method to update records on after undelete
    }
    
}