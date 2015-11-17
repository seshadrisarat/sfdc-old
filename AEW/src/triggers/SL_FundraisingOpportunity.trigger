/**  
* \arg TriggerName      : SL_FundraisingOpportunity
* \arg JIRATicket       : AEW-5
* \arg CreatedOn        : 02/Jan/2015
* \arg LastModifiedOn   : 1/July/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Sandeep
* \arg Description      : Trigger is used to create record in Fundraising Opportunity Contact when an Fundraising Opportunity record is inserted.
*/
trigger SL_FundraisingOpportunity on Fundraising_Opportunity__c (after insert, before insert, before update) 
{ 
    //Creating instance of handler class.
    SL_FundraisingOpportunityHandler objFundraisingOppHandler = new SL_FundraisingOpportunityHandler();
    
    /*Added by Sandeep*/
    
    //If trigger is after insert
    if(trigger.isInsert )
    {
        if(Trigger.isAfter)
            objFundraisingOppHandler.onAfterInsert(Trigger.New);
        if(Trigger.isBefore && SL_RecursionHelper.getisInsert())
        {
            SL_FundraisingOpportunityHandler.onBeforeInsert(Trigger.new);
            SL_RecursionHelper.setisInsert(false);
        }
    }
    
    /*Added by Sandeep*/
    if(Trigger.isUpdate  )
    {
        if(Trigger.isBefore && SL_RecursionHelper.getisUpdate() && SL_RecursionHelper.getisInsert())
        {
            SL_FundraisingOpportunityHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            SL_RecursionHelper.setisUpdate(false);
            SL_RecursionHelper.setisUpdate(false);
        }
    }
}