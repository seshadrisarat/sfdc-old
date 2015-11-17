trigger WP_Deal on Deal__c (before update, after delete, after insert, after undelete, 
after update, before insert) {
    if (kjoDealReportController.bCheckingDealWriteability) return;
    string sEventType = '';
    Deal__c[] deals = null;
    if (Trigger.isDelete) {
        sEventType='DEL'; 
        deals = trigger.old;
    }  
    else if (Trigger.isUpdate ) 
        { 
            sEventType='UPD'; 
            deals = trigger.new;
        } 
        else if (Trigger.IsInsert) 
        {
            sEventType = 'INS';
            deals = trigger.new; 
        }
        else if (Trigger.isUnDelete) 
            {
                sEventType='INS';
                deals = trigger.new;
            }
            
    List<WP_Synch_Log__c> list_insert_wpsl = new List<WP_Synch_Log__c>();
     if (deals.size() < 149) {
    for (Deal__c dl : deals) {
        
     if (Trigger.isBefore)
        {
            
        if (sEventType=='INS')
		{
		
		if (dl.GUID__c == null || String.isBlank(dl.GUID__c))  
        	{ 
        	dl.GUID__c = WP_Guid_Util.NewGuid();
        	System.debug('---> before ins trigger guid is blank, created val is:' + dl.GUID__c  );
        	}
        		else 
			{
			System.debug('---> before ins trigger guid is not blank:' + dl.GUID__c  );
			}
		}
            
        if (sEventType=='UPD')
            {
            
            Deal__c dlOld = Trigger.oldMap.get(dl.ID);
            System.debug('---> before update trigger new:' + dl.GUID__c + ' old: ' + dlOld.GUID__c);
            // if both not null and not the same
            if 
            (
            (
            String.isNotBlank(dlOld.GUID__c)  &&
            String.isNotBlank(dl.GUID__c)  &&
            dlOld.GUID__c != dl.GUID__c
            )
            
            || (String.isNotBlank(dlOld.GUID__c)  &&String.isBlank(dl.GUID__c))
            || (String.isBlank(dlOld.GUID__c)  &&String.isNotBlank(dl.GUID__c))
            ) 
            
            {
                
            System.debug('---> before trigger update values are different');
            // if UPDATE is included in new guid, remove UPDATE and set new to removed version
            
            if (String.isNotBlank(dl.GUID__c) && dl.GUID__c.indexOf('UPDATE')!=-1)
            {
                string sNew = dl.GUID__c;//.replace()
                sNew = sNew.replace('UPDATE','');
                dl.GUID__c = sNew;
                System.debug('---> BEFORE TRIGGER setting to ' + sNew);
            }
            else // if UPDATE isn't included in new, set new to old
            {
                System.debug('---> BEFORE TRIGGER setting to old value ' + dlOld.GUID__c);
            dl.GUID__c = dlOld.GUID__c;
            }
            }
        } 
        }
            else 
        {
        string sObjId = '';
        string sRemoteId = '';
        //if (sEventType=='DEL') 
        sRemoteId = dl.GUID__c;
        
        sObjId = String.valueOf(dl.Id);
        /*if (sEventType!='DEL') s = String.valueOf(dl.Id);
        else    s = String.valueOf(dl.GUID__c);
        */
        
        
        boolean bFire=true;
        if (sEventType=='UPD')// we don't fire trigger on updates to guid__c
        {
            
            Deal__c dlOld = Trigger.oldMap.get(dl.ID);
            System.debug('---> AFTER update trigger new:' + dl.GUID__c + ' old: ' + dlOld.GUID__c);
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
        }
        System.debug('---> evttype:' + sEventType + '   id:' + sObjId + ' dealid:' + dl.Id );
        if (bFire) {
            WP_Synch_Log__c wpsl = WP_handler_Synch_Log.CreateSynchLogEvent(sEventType, 'Deal', sObjId,String.valueOf(dl.Id),sRemoteId); 
            if(wpsl!=null) list_insert_wpsl.add(wpsl);
        }
        }
        
    }
    if(list_insert_wpsl.size()>0)
      insert list_insert_wpsl;
}
}