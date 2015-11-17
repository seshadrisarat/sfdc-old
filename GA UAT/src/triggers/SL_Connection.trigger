/**
*  Trigger Name   : SL_Connection
*  CreatedOn      : 19/FEB/2015
*  ModifiedBy     : Pradeep Maddi
*  Description    : Connection trigger used to create inverse connection records for inserted or updated connections
*/

trigger SL_Connection on Connection__c (after insert, after update, after delete, after undelete, before insert, before update) {

    SL_ConnectionHandler objConnectionHandler = new SL_ConnectionHandler();
    
    // Handler Method called on after insert of connection record to perform business logic 
    if(Trigger.IsAfter && Trigger.IsInsert && SL_RecursionHelper.getIsAfterInsert() && SL_RecursionHelper.getIsAfterUpdate()) 
    {
    	// Method called to prevent recursion
		SL_RecursionHelper.setIsAfterInsert(false);
        objConnectionHandler.OnAfterInsert(Trigger.newMap);
    }
    // Handler Method called on after update of connection record to perform business logic
    else if(Trigger.IsAfter && trigger.IsUpdate ) 
    {
    	if(SL_RecursionHelper.getIsAfterInsert() && SL_RecursionHelper.getisAfterUpdate())
		{
			// Method called to prevent recursion
			SL_RecursionHelper.setisAfterUpdate(false);
        	objConnectionHandler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
		}	
    } 
    // Handler Method called on after delete of connection record to perform business logic
    else if(Trigger.IsAfter && trigger.isDelete) 
    {
    	if(SL_RecursionHelper.getisAfterUpdate() && SL_RecursionHelper.getisAfterDelete())
		{
			// Method called to prevent recursion
			SL_RecursionHelper.setisAfterDelete(false);
			objConnectionHandler.OnAfterDelete(Trigger.oldMap);
		}		
    }
    // Handler Method called on after undelete of connection record to perform business logic
    else if(Trigger.IsAfter && trigger.isUnDelete) 
    {
    	// Method called to prevent recursion
		SL_RecursionHelper.setIsAfterInsert(false);
        objConnectionHandler.OnAfterUnDelete(Trigger.newMap);
    }
    // Handler Method called on before insert
    else if(Trigger.IsBefore && trigger.IsInsert ) 
    {
    	objConnectionHandler.onBeforeInsert(Trigger.new);
    } 
    
    // Handler Method called on before update
    else if(Trigger.IsBefore && trigger.IsUpdate ) 
    {
    	objConnectionHandler.onBeforeUpdate(Trigger.newMap, trigger.oldMap);
    } 
    
    
}