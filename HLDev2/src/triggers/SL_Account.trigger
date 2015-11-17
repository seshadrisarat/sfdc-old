/**  
* \arg TriggerName    : SL_Account
* \arg JIRATicket     : HL-23
* \arg CreatedOn      : 05/AUG/2014
* \arg LastModifiedOn : 05/AUG/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Ultimate Parent Account Trigger
*/
trigger SL_Account on Account (after delete, after update, before insert, before delete) 
{
	//Creating instance of handler class.
	SL_AccountHandler objSL_AccountHandler = new SL_AccountHandler(Trigger.isExecuting, Trigger.size);
	
	//If trigger is before insert
	if(Trigger.isBefore && Trigger.isInsert)
    {
        objSL_AccountHandler.onBeforeInsert(Trigger.new);
    }
	
	//If trigger is after update
    if(Trigger.isAfter && Trigger.isUpdate)   
    {
    	objSL_AccountHandler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }   
    
    //If trigger is before delete
    if(Trigger.isBefore && Trigger.isDelete)   
    {
    	objSL_AccountHandler.onBeforeDelete(Trigger.oldMap);
    }
    //If trigger is after delete
    if(Trigger.isAfter && Trigger.isDelete)   
    {
    	objSL_AccountHandler.onAfterDelete(Trigger.oldMap);
    }
}