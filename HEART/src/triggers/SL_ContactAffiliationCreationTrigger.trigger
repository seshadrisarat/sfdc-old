/**  
* \arg TriggerName    : SL_ContactAffiliationCreationTrigger
* \arg JIRATicket     : HEART-11
* \arg CreatedOn      : 11/Aug/2014
* \arg LastModifiedOn : 12/Oct/2015
* \arg CreatededBy    : Prakash
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : Trigger for SL_ContactAffiliationCreationHandler
*/

trigger SL_ContactAffiliationCreationTrigger on Contact (after insert, after update, before update) 
{
	// initialize the handler SL_ContactAffiliationCreationHandler
	SL_ContactAffiliationCreationHandler handler = new SL_ContactAffiliationCreationHandler( Trigger.isExecuting, Trigger.size );
	
	// fires on After Insert Of Contact Records
	if ( trigger.IsInsert ) 
	{
		if ( trigger.IsAfter )
		{
			handler.OnAfterInsert( Trigger.newMap );
		}
	}
	// fires on After update Of Contact Records
	else if ( trigger.IsUpdate )
	{
		if ( trigger.IsAfter )
		{
			handler.OnAfterUpdate( Trigger.oldMap,Trigger.newMap );
		}
		else if(Trigger.isBefore)
		{
		    handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
		}
	}
}