trigger WP_FundOwnership on Fund_Ownership__c (after delete, after insert, after undelete, 
after update) {
	string sEventType = '';
	Fund_Ownership__c[] recs = null;
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
	List<WP_Synch_Log__c> list_insert_wpsl = new List<WP_Synch_Log__c>();
	for (Fund_Ownership__c recX : recs) {
		
		boolean bFire=true;
		if (sEventType=='UPD')// we don't fire trigger on updates to deal guid__c
		{
			bFire=false;
			string dlGuidNew = recX.Deal__c != null ? recX.DealGUID__c : '' ;
			Fund_Ownership__c foOld = Trigger.oldMap.get(recX.ID);
			string dlGuidOld = foOld!=null &&  foOld.Deal__c != null ? foOld.DealGUID__c : '' ;
			if (foOld.Deal__c != recX.Deal__c || foOld.Fund__c != recX.Fund__c) bFire=true;
			
			//System.debug('new deal guid:' + dlGuidNew);
			//System.debug('old deal guid:' + dlGuidOld);
			//System.debug('bFire:' + bFire);
			
			/*
			if (
			( String.isBlank( dlOld.GUID__c  ) && !String.isBlank(dl.GUID__c)  )
			||
			( !String.isBlank( dlOld.GUID__c  ) && String.isBlank(dl.GUID__c)  )
			||
			( !String.isBlank( dlOld.GUID__c  ) && !String.isBlank(dl.GUID__c) 
				&&
				dlOld.GUID__c != dl.GUID__c
			 )
			)
			bFire = false;
			*/
		}
		if (bFire) {
        		WP_Synch_Log__c wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'Fund Ownership', String.valueOf(recX.Id), String.valueOf( recX.Deal__c) ); 
        		if(wpsl!=null) list_insert_wpsl.add(wpsl);
        	}
    }
    if(list_insert_wpsl.size()>0)
      insert list_insert_wpsl;
}