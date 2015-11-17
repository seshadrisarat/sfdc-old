/**
* \arg TriggerName      : SL_Note
* \arg JIRATicket       : HIL-4
* \arg CreatedOn        : 13/FEB/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : -
* \arg Description      : This trigger is used to create sharing records corresponding to Note__c object on after insert.
*/
trigger SL_Note on Note__c (after insert) 
{
	SL_NoteHandler objNoteHandler = new SL_NoteHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
		{
			objNoteHandler.onAfterInsert(Trigger.newMap);
		}
	}
}