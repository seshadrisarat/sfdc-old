trigger WP_Account on Account (after delete, after insert, after undelete, 
after update) {
	/*
	string sEventType = '';
	Account[] recs = null;
	if (Trigger.isDelete) {
		sEventType='DEL'; 
		recs = trigger.old;
	}  
	else if (Trigger.isUpdate) 
		{ 
			sEventType='UPD'; 
			recs = trigger.new;
		} 
		else if (Trigger.IsInsert) 
		{
			sEventType = 'INS';
			recs = trigger.new; 
		}
		else if (Trigger.isUnDelete) 
			{
				sEventType='INS';
				recs = trigger.new;
			}
	for (Account recX : recs) {
		
		boolean bFire=true;
		if (sEventType=='UPD')// we don't fire trigger on updates to guid__c
		{
			//Account acOld = Trigger.oldMap.get(recX.ID);
			//if (
			//( String.isBlank( dlOld.GUID__c  ) && !String.isBlank(dl.GUID__c)  )
			//||
			//( !String.isBlank( dlOld.GUID__c  ) && String.isBlank(dl.GUID__c)  )
			//||
			//( !String.isBlank( dlOld.GUID__c  ) && !String.isBlank(dl.GUID__c) 
		//		&&
			//	dlOld.GUID__c != dl.GUID__c
			 //)
			//)
			bFire = false;
		}
		if (bFire)
		{
			List<Deal__c> deals = [select id from Deal__c where Company__c  = :recX.Id];
			for (Deal__c deal : deals)
			{		
        	WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'Company', String.valueOf(recX.Id),String.valueOf(deal.Id) );
			}
		} 
    }
*/

}