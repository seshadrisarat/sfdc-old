/**
*  Trigger Name   : SL_Commitment
*  CreatedOn      : 30/04/2015
*  ModifiedBy     : Sandeep
*  ModifiedDate   : 
*  Description    : This is the Commitment__c trigger 
*/
trigger SL_Commitment on Commitment__c (after insert, after update, after delete) 
{
	//intialize the handler
	SL_CommitmentHandler handler = new SL_CommitmentHandler();
	//call the handler method based on respective events
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			handler.onAfterInsert(Trigger.newMap);
		if(Trigger.isUpdate)
			handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
		if(Trigger.isDelete)
			handler.onAfterDelete(Trigger.oldMap);
	}
}