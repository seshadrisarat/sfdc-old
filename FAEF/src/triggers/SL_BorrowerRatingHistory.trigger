trigger SL_BorrowerRatingHistory on Borrower_Rating_History__c (before delete, after insert, after undelete, after update) 
{
	SL_BorrowerRatingHistoryHandler handler = new SL_BorrowerRatingHistoryHandler();
	
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert)
			handler.onAfterInsert(Trigger.newMap);
		if(Trigger.isUpdate)
			handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);  
		if(Trigger.isUnDelete)
			handler.onAfterUnDelete(Trigger.newMap);
	}
	else
	{
		if(Trigger.isDelete)
			handler.onBeforeDelete(Trigger.oldMap);
	}
}