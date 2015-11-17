/*Trigger on insert of Company_List_Member__c
* Trigger Name  : Company_List_Member__c 
* Created on    : 08/30/2013
* LastModifiedOn : 27/Jan/2015
* Modified by   : Sandeep
* Description   : Trigger for company list member 
*/

trigger SL_Trigger_Company_List_Member on Company_List_Member__c (before insert, after delete, after insert, after update, after undelete) 
{
	// Instantiating the handler class.
    SL_Company_List_Member_Handler objCmpLstMemberHandler = new SL_Company_List_Member_Handler();
    
    if(trigger.isBefore && trigger.isInsert)
    {
        objCmpLstMemberHandler .onBeforeInsert(trigger.new);
    }
    
    // Start - Sandeep
    if(Trigger.isAfter && Trigger.isInsert)
	{
		objCmpLstMemberHandler .onAfterInsert(Trigger.new); // Calling onAfterInsert method of Handler.
	}
	
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		objCmpLstMemberHandler .onAfterUpdate(Trigger.oldMap,Trigger.newMap); // Calling onAfterUpdate method of Handler.
	}
	
	if(Trigger.isAfter && Trigger.isDelete)
	{
		objCmpLstMemberHandler .onAfterDelete(Trigger.old); // Calling onAfterDelete method of Handler.
	}	
    
    if(Trigger.isAfter && Trigger.isUnDelete) 
	{
		objCmpLstMemberHandler.onAfterUnDelete(Trigger.New); // Calling onAfterDelete method of Handler
	}
    // End - Sandeep
    
}