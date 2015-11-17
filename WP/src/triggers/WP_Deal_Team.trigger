trigger WP_Deal_Team on Deal_Team__c (after delete, after insert, after undelete, 
after update) {
string sEventType = '';
	Deal_Team__c[] recs = null;
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
	for (Deal_Team__c recX : recs) {
        	WP_Synch_Log__c wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'Deal Team', String.valueOf(recX.Id), String.valueOf(recX.Deal__c) ); 
        	if(wpsl!=null) list_insert_wpsl.add(wpsl);
    }
    if(list_insert_wpsl.size()>0)
      insert list_insert_wpsl;
}