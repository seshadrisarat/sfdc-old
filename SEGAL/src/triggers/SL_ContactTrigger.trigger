/**
*  Trigger Name   : SL_ContactTrigger
*  JIRATicket     : SEGAL-11
*  CreatedOn      : 23/APR/2015
*  ModifiedBy     : Pradeep
*  Description    : Trigger to ensure when user merges the contacts then the address which matches the Selected Mailing address in 'Select the values to retain' step should be selected as primary and all the remaining addresses for contact should be marked as unprimary. 
*/

trigger SL_ContactTrigger on Contact(after update,after delete,before update) 
{
	// Creating object for handler class
	SL_ContactTriggerHandler objContactHandler = new SL_ContactTriggerHandler();
	
	if(trigger.isAfter && trigger.isDelete)
	{
	   // Setting isMergeDelete value to true as delete operation will fire before updation of master record while merging so that we will get to know if update on contact is happened as a part of merge operation.
	   SL_RecursionHelper.setisMergeDelete(true);
	}   
		
	// Calling handler class method on after update of Contact record as a part of merge operation.
	if(trigger.isAfter && trigger.isUpdate && SL_RecursionHelper.getisMergeDelete() && SL_RecursionHelper.getisAfterUpdate())
	{	
		SL_RecursionHelper.setisAfterUpdate(false);
		objContactHandler.onAfterupdate(trigger.newMap);
	}	 	
}